---
author: "Tommi M&auml;klin"
title: "Local alignment with kbo"
date: "2024-11-15"
draft: true
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
https://github.com/tmaklin/kbo (written in Rust btw).

kbo comes with some interesting algorithmic developments related to converting
plain location-discarding _k_-mer matching into local alignments by looking at
the longest common prefix length of the match (see [the
preprint](https://www.biorxiv.org/content/10.1101/2024.02.19.580943v1) by
colleagues from Helsinki). These are desribed in the [crate
documentation](https://docs.rs/kbo) and will be turned into a pre-print in early
2025.

This post contains a guide and examples for the two main use cases I have in
mind for kbo. You can replicate them using the [kbo command-line
interface](https://github.com/tmaklin/kbo-cli) or the browser
version at [https://maklin.fi/kbo](https://maklin.fi/kbo).

## Finding genes of interest in a query

Assume you have sequenced and assembled a bacterial genome and are interested in
knowing whether the assembly contains some gene of interest or not. Typically,
this would be a task for blast, but we want to use `kbo find`.

Setup:
- A database containing 19 interesting genes from [GitHub](https://raw.githubusercontent.com/tmaklin/clbtype/refs/heads/main/db/db.fasta).
- A genome which has variants of these genes from the [ENA](https://www.ebi.ac.uk/ena/browser/view/GCA_000013265.1).

Run the following to see where the genes are located in the query
```
kbo find -r db.fasta GCA_000013265.1.fasta.gz
```

This will produce the output

<details>
<summary>
This replaces the query.contig column with the name of the contig (click to expand)
</summary>

Add output

</details>

Note that the output doesn't tell _which_ genes were found, only where in the
query there are matches in the reference. If this is inconvenient for you, add the `--detailed` flag which performs the analysis gene-by-gene at the cost of some extra runtime:

```
kbo find --detailed --threads 4 -r db.fasta GCA_000013265.1.fasta.gz
```

<details>
<summary>
This replaces the query.contig column with the name of the contig (click to expand)
</summary>

Add output

</details>

`kbo` isn't massively better for this task than blast in neither runtime nor
accuracy, but I believe the command-line syntax is somewhat easier to
memorize. And you can easily run your own queries on a custom database.

My internal roadmap intends to add an option to bundle small databases with the
browser distributable, so that you could easily host your own version with your
own database ready to go for analyses that you or colleagues run often.

## Reference-based alignment

Next, we have the case of generating a reference-based alignment of two
bacterial genome assemblies. For me, this was the main motivation to write
`kbo`, as the existing tools are either somewhat slow
([snippy](https://github.com/tseemann/snippy)) or require some megabytes of
temporary disk space per query (snippy and
[ska2](https://github.com/bacpop/ska.rust)). Both factors become somewhat
inconvenient when running reference-based alignment for tens of thousands of
genomes, as I recently did in a paper of mine (TODO colibactin paper)[].

Setup
- A genome from the [ENA](https://www.ebi.ac.uk/ena/browser/view/GCA_000013265.1).
- Another genome from the [ENA](https://www.ebi.ac.uk/ena/browser/view/GCA_000333215.1).

With the genomes downloaded, run
```
kbo map -r GCA_000013265.1.fasta.gz GCA_000333215.1.fasta.gz > alignment.fasta
  
```

The file `alignment.fasta` will contain an alignment of GCA\_000333215 against
GCA\_000013265. If you need the nucleotide sequence of the reference in the
file, you need to add it to the file first in the same format that kbo will
output
```
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

## Acknowledgements

Thanks to Jarno Alanko and Simon Puglisi from the University of Helsinki for
introducing me to _k_-bounded matching statistics and especially Jarno for
writing the [sbwt Rust crate](https://docs.rs/sbwt) that I used within kbo.

Some papers if you are interested in the internals:
- [_k_-mer matching with the SBWT data structure](https://epubs.siam.org/doi/abs/10.1137/1.9781611977714.20).
- [Longest common suffix/prefix arrays](https://link.springer.com/chapter/10.1007/978-3-031-43980-3_1).
- [_k_-bounded matching statistics](https://www.biorxiv.org/content/10.1101/2024.02.19.580943v1).
