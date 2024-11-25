---
author: "Tommi M&auml;klin"
title: "Local alignment with kbo"
date: "2024-11-19"
draft: false
description: "How I implemented local alignment on top of SBWT."
category: "bioinformatics"
tags: [
	"bioinformatics",
	"rust",
	"genomics",
	"software",
]
---

I like to create new tools to solve already solved problems. This time I've
created a new tool for reference-based alignment of bacterial genomes, and
computation of sequence identity and coverage of some reference gene sequences
in a query assembly. The tool is called `kbo` and is available from
https://github.com/tmaklin/kbo (written in Rust).

kbo comes with some interesting algorithmic bioinformatics that converts plain
_k_-mer matching between a database and a query sequence into local alignments
by looking at the longest common prefix length in each _k_-mer and its best
match in a database (see [the
preprint](https://www.biorxiv.org/content/10.1101/2024.02.19.580943v1) by
colleagues from Helsinki).

## Overview
The basic idea is that if the longest common prefix length -- a _k_-bounded
matching statistic -- of each _k_-mer match and their order in the query are
known, then the following events are identifiable by looking at the (ordered)
matching statistic vector:

- Matching region between query and reference: matching statistic has a high value.
- Region in query not present in reference: matching statistic has random value drawn from noise distribution.
- Single character mismatch or insertion in query: matching statistic decreases
  linearly from _k_ to 0 and immediately goes back to a high value.
- Insertion in reference or jump from one region in query to another: matching
  statistic decreases linearly from _k_ to 1 and immediately goes back to a
  high value.
  
These are described in documentation for the
[derandomize](https://docs.rs/kbo/latest/kbo/derandomize/index.html) and
[translate](https://docs.rs/kbo/latest/kbo/translate/index.html) modules, the
[kbo crate documentation](https://docs.rs/kbo), and will be turned into a
pre-print in early 2025.

This post contains a guide and examples for the two main use cases I have in
mind for kbo. You can replicate them using the [kbo command-line
interface](https://github.com/tmaklin/kbo-cli).

## Installation
### Run in browser

An in-browser demo version is available at
[maklin.fi/kbo](https://maklin.fi/kbo/).

You can find the source code for the
browser version in a separate [git
repository](https://github.com/tmaklin/kbo-gui).

### Run locally
Download a precompiled binary from [here](https://github.com/tmaklin/kbo-cli/releases), or install the command-line interface using cargo:
```text
cargo install kbo-cli
```
and then call `kbo` to run the tool.

I am also developing a browser version at
[https://github.com/tmaklin/kbo-gui](https://github.com/tmaklin/kbo-gui) which
will hopefully be available soon.

## Finding genes of interest in a query
Assume you have sequenced and assembled a bacterial genome and are interested in
knowing whether the assembly contains some gene of interest or not. Typically,
this would be a task for blast, but we want to use `kbo find`.

Setup:
- A database containing 19 interesting genes from [GitHub](https://raw.githubusercontent.com/tmaklin/clbtype/refs/heads/main/db/db.fasta).
- A genome which has variants of these genes from the [ENA](https://www.ebi.ac.uk/ena/browser/view/GCA_000013265.1).

Run the following to see where the genes are located in the query
```text
kbo find -r db.fasta GCA_000013265.1.fasta.gz
```

This will produce the output

<details>
<summary>
This replaces the query.contig column with the name of the contig (click to expand)
</summary>

```text
query	ref	q.start	q.end	strand	length	mismatches	gap_opens	identity	coverage	query.contig	ref.contig
GCA_000013265.1.fasta.gz	db.fasta	56646	57164	+	519	0	0	100.00	1.03	ENA|CP000244|CP000244.1 Escherichia coli UTI89 plasmid pUTI89, complete sequence.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2165476	2166423	+	948	0	0	100.00	1.88	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2900668	2910288	-	9621	0	0	100.00	19.06	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2910329	2912929	-	2601	0	0	100.00	5.15	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2912939	2913808	-	870	0	0	100.00	1.72	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2913838	2914086	-	249	0	0	100.00	0.49	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2914090	2916485	-	2396	0	0	100.00	4.75	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2916533	2921329	-	4797	1	0	99.98	9.50	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2921379	2924411	-	3033	0	0	100.00	6.01	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2924455	2930955	-	6501	0	0	100.00	12.88	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2930966	2938886	-	7921	0	0	100.00	15.69	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2938948	2944751	-	5804	0	0	100.00	11.50	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2944782	2947241	-	2460	0	0	100.00	4.87	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2947254	2949483	-	2230	0	0	100.00	4.42	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
GCA_000013265.1.fasta.gz	db.fasta	2949518	2950030	-	513	0	0	100.00	1.02	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	db.fasta
```

</details>

Note that the output doesn't tell _which_ genes were found, only where in the
query there are matches in the reference. If this is inconvenient for you, add the `--detailed` flag which performs the analysis gene-by-gene at the cost of some extra runtime:

```text
kbo find --detailed --threads 4 -r db.fasta GCA_000013265.1.fasta.gz
```

<details>
<summary>
This replaces the query.contig column with the name of the contig (click to expand)
</summary>

```text
query	ref	q.start	q.end	strand	length	mismatches	gap_opens	identity	coverage	query.contig	ref.contig
GCA_000013265.1.fasta.gz	db.fasta	56646	57164	+	519	00	100.00	100.00	ENA|CP000244|CP000244.1 Escherichia coli UTI89 plasmid pUTI89, complete sequence.	clbS-like_4ce09a
GCA_000013265.1.fasta.gz	db.fasta	2165476	2165688	+	213	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbR|locus_tag=ECOK1_RS11410|product="colibactin biosynthesis LuxR family transcriptional regulator ClbR"|protein_id=WP_000357141.1
GCA_000013265.1.fasta.gz	db.fasta	2165689	2166423	+	735	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbA|locus_tag=ECOK1_RS11415|product="colibactin biosynthesis phosphopantetheinyl transferase ClbA"|protein_id=WP_001217110.1
GCA_000013265.1.fasta.gz	db.fasta	2900668	2910288	-	9621	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbB|locus_tag=ECOK1_RS11405|product="colibactin hybrid non-ribosomal peptide synthetase/type I polyketide synthase ClbB"|protein_id=WP_001518711.1
GCA_000013265.1.fasta.gz	db.fasta	2910329	2912929	-	2601	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbC|locus_tag=ECOK1_RS11400|product="colibactin polyketide synthase ClbC"|protein_id=WP_001297908.1
GCA_000013265.1.fasta.gz	db.fasta	2912939	2913808	-	870	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbD|locus_tag=ECOK1_RS11395|product="colibactin biosynthesis dehydrogenase ClbD"|protein_id=WP_000982270.1
GCA_000013265.1.fasta.gz	db.fasta	2913838	2914086	-	249	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbE|locus_tag=ECOK1_RS11390|product="colibactin biosynthesis aminomalonyl-acyl carrier protein ClbE"|protein_id=WP_001297917.1
GCA_000013265.1.fasta.gz	db.fasta	2914090	2915220	-	1131	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbF|locus_tag=ECOK1_RS11385|product="colibactin biosynthesis dehydrogenase ClbF"|protein_id=WP_000337350.1
GCA_000013265.1.fasta.gz	db.fasta	2915217	2916485	-	1269	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbG|locus_tag=ECOK1_RS11380|product="colibactin biosynthesis acyltransferase ClbG"|protein_id=WP_000159201.1
GCA_000013265.1.fasta.gz	db.fasta	2916533	2921329	-	4797	10	99.98	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbH|locus_tag=ECOK1_RS11375|product="colibactin non-ribosomal peptide synthetase ClbH"|protein_id=WP_001304254.1
GCA_000013265.1.fasta.gz	db.fasta	2921379	2924411	-	3033	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbI|locus_tag=ECOK1_RS11370|product="colibactin polyketide synthase ClbI"|protein_id=WP_000829570.1
GCA_000013265.1.fasta.gz	db.fasta	2924455	2930955	-	6501	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbJ|locus_tag=ECOK1_RS11365|product="colibactin non-ribosomal peptide synthetase ClbJ"|protein_id=WP_001468003.1
GCA_000013265.1.fasta.gz	db.fasta	2929045	2930331	-	1287	20	99.84	19.91	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbK|locus_tag=ECOK1_RS11360|product="colibactin hybrid non-ribosomal peptide synthetase/type I polyketide synthase ClbK"|protein_id=WP_000222467.1
GCA_000013265.1.fasta.gz	db.fasta	2930966	2937430	-	6465	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbK|locus_tag=ECOK1_RS11360|product="colibactin hybrid non-ribosomal peptide synthetase/type I polyketide synthase ClbK"|protein_id=WP_000222467.1
GCA_000013265.1.fasta.gz	db.fasta	2934698	2935984	-	1287	20	99.84	19.80	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbJ|locus_tag=ECOK1_RS11365|product="colibactin non-ribosomal peptide synthetase ClbJ"|protein_id=WP_001468003.1
GCA_000013265.1.fasta.gz	db.fasta	2937423	2938886	-	1464	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbL|locus_tag=ECOK1_RS11355|product="colibactin biosynthesis amidase ClbL"|protein_id=WP_001297937.1
GCA_000013265.1.fasta.gz	db.fasta	2938948	2940387	-	1440	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbM|locus_tag=ECOK1_RS11350|product="precolibactin export MATE transporter ClbM"|protein_id=WP_000217768.1
GCA_000013265.1.fasta.gz	db.fasta	2940384	2944751	-	4368	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbN|locus_tag=ECOK1_RS11345|product="colibactin non-ribosomal peptide synthetase ClbN"|protein_id=WP_001327259.1
GCA_000013265.1.fasta.gz	db.fasta	2944782	2947241	-	2460	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbO|locus_tag=ECOK1_RS11340|product="colibactin polyketide synthase ClbO"|protein_id=WP_001029878.1
GCA_000013265.1.fasta.gz	db.fasta	2947254	2948768	-	1515	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbP|locus_tag=ECOK1_RS11335|product="precolibactin peptidase ClbP"|protein_id=WP_002430641.1
GCA_000013265.1.fasta.gz	db.fasta	2948761	2949483	-	723	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbQ|locus_tag=ECOK1_RS11330|product="colibactin biosynthesis thioesterase ClbQ"|protein_id=WP_000065646.1
GCA_000013265.1.fasta.gz	db.fasta	2949518	2950030	-	513	00	100.00	100.00	ENA|CP000243|CP000243.1 Escherichia coli UTI89, complete genome.	clbS|locus_tag=ECOK1_RS11325|product="colibactin self-protection protein ClbS"|protein_id=WP_000290498.1
```

</details>

kbo isn't massively better for this task than blast but I believe the
command-line syntax is somewhat easier to memorize. And it's interesting that we
can extract local alignments from pure _k_-mer matching by adding the
_k_-bounded matching statistics.

My internal roadmap thinks of this as the main use case for the eventual browser
version, which could support things like bundling databases with the executable
to distribute analyses you need to run often.

## Reference-based alignment
Next, we have the case of generating a reference-based alignment of two
bacterial genome assemblies. For me, this was the original motivation to write
kbo, as the existing tools are either somewhat slow
([snippy](https://github.com/tseemann/snippy)) or require some megabytes of
temporary disk space per query (snippy and
[ska2](https://github.com/bacpop/ska.rust)). Both factors scale poorly when
running reference-based alignment for tens of thousands of genomes, although
it's still possible with the exisintg tools.

kbo can handle this task very easily, and takes a few seconds to run the
alignment with no indexing step or temporary disk space required.

Setup
- A genome from the [ENA](https://www.ebi.ac.uk/ena/browser/view/GCA_000013265.1).
- Another genome from the [ENA](https://www.ebi.ac.uk/ena/browser/view/GCA_000333215.1).

With the genomes downloaded, run
```text
kbo map -r GCA_000013265.1.fasta.gz GCA_000333215.1.fasta.gz > alignment.fasta
```

The file `alignment.fasta` will contain an alignment of GCA\_000333215 against
GCA\_000013265. If you need the nucleotide sequence of the reference in the
file, you need to add it to the file first in the same format that kbo will
output
```text
echo ">GCA_000013265.1.fasta.gz" > alignment.fasta
gunzip -c GCA_000013265.1.fasta.gz | grep -v ">" | tr -d '\n' | sed 's/$/\n/g' >> alignment.fasta

kbo map -r GCA_000013265.1.fasta.gz GCA_000333215.1.fasta.gz > alignment.fasta
```
This will be added as an option to the command-line interface and the browser
version in the future.

The main use case for `kbo map` is to generate reference-based alignments of
large numbers of queries to build a phylogeny since kbo only takes ~a second per
genome comparison and uses no disk space. You _can_ use the file to extract
SNPs but some quirks in the algorithm mean that the bases are not always called
correctly, so ska or snippy should be preferred if this is important to you (and
compare different approaches first).

## TODO list

- Finish the browser version (more cumbersome than it seems).
- Write up the algorithmic parts and put it out as a pre-print.

If you want to contribute code, documentation, or something else feel free to do
so in the GitHub repos:
- [kbo](https://github.com/tmaklin/kbo)
- [kbo-cli](https://github.com/tmaklin/kbo-cli)
- [kbo-gui](https://github.com/tmaklin/kbo-gui)

## Reading

Thanks to Jarno Alanko and Simon Puglisi from the University of Helsinki for
introducing me to _k_-bounded matching statistics and especially Jarno for
writing the [sbwt Rust crate](https://docs.rs/sbwt) that I used within kbo.

Some papers if you are interested in the internals:
- [_k_-mer matching with the SBWT data structure](https://epubs.siam.org/doi/abs/10.1137/1.9781611977714.20).
- [Longest common suffix/prefix arrays](https://link.springer.com/chapter/10.1007/978-3-031-43980-3_1).
- [_k_-bounded matching statistics](https://www.biorxiv.org/content/10.1101/2024.02.19.580943v1).
