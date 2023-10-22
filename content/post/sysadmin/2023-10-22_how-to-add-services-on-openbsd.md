---
author: "Tommi M&auml;klin"
title: "How to cleanly add services on OpenBSD"
date: "2023-10-22"
draft: false
description: "You can either add daemons on OpenBSD in a clean or a hackish way. This describes what I think is the former."
category: "sysadmin"
tags: [
	"openbsd"
]
---

Adapted from [https://www.tumfatig.net/2023/self-hosted-searxng-instance-on-openbsd/](https://www.tumfatig.net/2023/self-hosted-searxng-instance-on-openbsd/), this post documents how to add daemons that run services on OpenBSD in a way that I find cleaner and easier to maintain than what I used to before. I'm writing this for future-me to use as reference and credit for the setup goes to Joel Carnat.

The commands in this post were originally tested on [OpenBSD 7.4](https://www.openbsd.org/74.html), which was released on 16 October 2023.

## Setting up daemon users
Set up a new daemon user called `_service`:
```
useradd -g =uid -c "I am a service that does stuff." -L daemon -s /sbin/nologin -d /home/service -m _service
```
We'll store the service in their homedir `/home/service` (don't pollute `/var`, [it's meant for logging, temporaries & transients, and spool files](https://man.openbsd.org/hier)), so the `-m` option needs to be given to create it.

## Installing a service as the daemon user
Run
```
doas -u _service /bin/ksh -l
```
to log in as the daemon user. The above will work even though we disabled logging in with the `_service` user with the `-s /sbin/nologin` flag.

### Python services (optional)
Services that have many python dependencies are annoying because of bloating the installed packages. Luckily these can be handed nicely with venvs strategically placed in the `/home/service` directory. We'll use the server back-end of the end-to-end encrypted CalDAV [etesync](https://github.com/etesync/server) as an example.

Assuming the `_etebase` was created as instructed above, we'll install the etebase backend in `/home/etebase`:
```
doas -u _etebase /bin/ksh -l

git clone https://github.com/etesync/server.git ~/src
```
Create a virtual environment in the service home directory and make the daemon automatically activate it:
```
python3 -m venv ~/pyenv
echo ". ~/pyenv/bin/activate" >> ~/.profile
^D
```

Now let's install the server:
```
doas -u _etebase /bin/ksh -l

cd ~/src
pip install -r requirements.txt
```

## Configuration files for git-based installations
Since etebase is installed and updated through git, we'll need to place the configuration file and secrets in $HOME to avoid them being overridden during updates:
```
doas -u _etebase /bin/ksh -l

sed -i 's/"secret.txt"/"..\/secrets.txt"/g' etebase_server/settings.py
sed -i 's/"db.sqlite3"/"..\/db.sqlite3"/g' etebase_server/settings.py
sed -i 's/ALLOWED_HOSTS = [[][]]/ALLOWED_HOSTS = [[] \"ete.maklin.fi\" []]/g' etebase_server/settings.py

```
Setup the server with:
```
./manage.py migrate
```
and you're ready to go.

## Setting up a daemon
Create the daemon script in `/etc/rc.d/etebase`:
```
#!/bin/ksh

daemon_execdir="/home/etebase/src"
daemon_logfile="/var/log/etebase"
daemon="/home/etebase/pyenv/bin/uvicorn"
daemon_flags="etebase_server.asgi:application --host 159.100.247.89 --port 8000"
daemon_user="_etebase"

. /etc/rc.d/rc.subr

rc_bg=YES
rc_reload=NO

pexp="/home/etebase/pyenv/bin/python3 ${daemon} ${daemon_flags}"

rc_start() {
        rc_exec ". ~/.profile; ${daemon} ${daemon_flags} >> ${daemon_logfile} 2>&1"
}

rc_cmd $1
```

Change permissions to r-xr-xr-x:
```
chmod 0555 /etc/rc.d/searxng
```

Enable the daemon and that's it:
```
rcctl -d enable searxng
rcctl -d start searxng
```

## Updating the service
Create a `update` script in `/home/service/update`:
```
doas -u _service /bin/ksh -l

vi ~/update
cd ~/src
git fetch origin "HEAD"
git reset --hard "origin/HEAD"
:wq!
```
for Python based services also add the following:
```
pip install -U pip
pip install -U setuptools
pip install -U wheel
pip install -U pyyaml
pip install -U -e .
:wq!
```
Change permissions to something sensible:
```
chmod 0750 ~/update
^D
```
... and create a cronjob that runs the update:
```
doas -u _service ksh -l ~_searxng/update

diff -U2 ./src/searx/settings.yml settings.yml

rcctl restart service
```

that's all.
