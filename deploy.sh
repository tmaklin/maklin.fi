#!/bin/sh
#
# Script to generate a static content package from the site sources
#
# Args
## $1: email address to include in the resume.
## $2: phone number to inckude in the resume.

set -euo pipefail

sitename="maklin.fi"

## Convert the resume markdown page to a pdf
md_in=tmp-in.md
echo "# Tommi M&auml;klin" > $md_in
echo "## Postdoctoral researcher" >> $md_in
echo -e "\n------\n" >> $md_in
sed '1,7d' content/resume.md | sed 's/[&]ZeroWidthSpace[;]//g' >> $md_in
sed -i "s/<script src=\"\/js\/contact_me.js\"><\/script><noscript>[[]Turn on JavaScript to see my email address.[]]<\/noscript>/$1/g" $md_in
sed -i "s/<script src=\"\/js\/call_me.js\"><\/script><noscript>[[]Turn on JavaScript to see my phone number.[]]<\/noscript>/$2/g" $md_in
##sed -i "s/<br><br>//g" $md_in
sed -i "s/$2.*$/$2/g" $md_in
sed -i "s/Heldata/<br>Heldata/g" $md_in

resume_filename=resume_tommi_maklin_$(date +%Y_%m_%d)

docker run --user $(id -u $(whoami)):$(id -g $(whoami)) \
       -it -v $(pwd):/resume there4/markdown-resume \
       md2resume pdf --template readable -o resume_tommi_maklin_$(date +%Y_%m_%d) $md_in static/documents/ > /dev/null

## Update the download link in content/resume.md
sed -i "s/resume_placeholder.pdf/$resume_filename.pdf/g" content/resume.md

## Convert the academic CV to a pdf
md_in=tmp-in.md
echo "# Tommi M&auml;klin" > $md_in
sed '1,7d' content/academic-cv.md | sed 's/[&]ZeroWidthSpace[;]//g' >> $md_in
sed -i 's/^[>]//g' $md_in
sed -i "s/<script src=\"\/js\/contact_me.js\"><\/script><noscript>[[]Turn on JavaScript to see my email address.[]]<\/noscript>/$1/g" $md_in
sed -i "s/<script src=\"\/js\/call_me.js\"><\/script><noscript>[[]Turn on JavaScript to see my phone number.[]]<\/noscript>/$2/g" $md_in
##sed -i "s/<br><br>//g" $md_in
sed -i "s/$2.*$/$2/g" $md_in
sed -i "s/Heldata/<br>Heldata/g" $md_in

docker run --user $(id -u $(whoami)):$(id -g $(whoami)) \
       -it -v $(pwd):/resume there4/markdown-resume \
       md2resume pdf --template unstyled -o academic_cv_tommi_maklin_$(date +%Y_%m_%d) $md_in static/documents/ > /dev/null

cv_filename=academic_cv_tommi_maklin_$(date +%Y_%m_%d)

## Update the download link in content/academic-cv.md
sed -i "s/academic_cv_placeholder.pdf/$cv_filename.pdf/g" content/academic-cv.md

hugo

mv public $sitename

## Create the output folder if it doesn't exist
mkdir -p static/documents

if command -v tigz > /dev/null; then
    tar --use-compress-program="tigz -12" -cvf $sitename".tar.gz" $sitename
else
    tar -zcvf $sitename".tar.gz" $sitename
fi
