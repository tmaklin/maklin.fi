---
title: "Publications"
date: 2023-02-28T15:32:43Z
draft: false
---

View all of my publications on [Google Scholar](https://scholar.google.com/citations?user=snMrAPkAAAAJ&hl=en&oi=ao).

## Highlights
### 2023
__Themisto: a scalable colored k-mer index for sensitive pseudoalignment against hundreds of thousands of bacterial genomes__

Jarno N Alanko, Jaakko Vuohtoniemi, __Tommi M&auml;klin__, and Simon Puglisi

preprint, [bioRxiv](https://www.biorxiv.org/content/10.1101/2023.02.24.529942v1), 2023

[Themisto](https://github.com/algbio/themisto) is a method for both building and querying colored de Bruijn graphs that was originally introduced in my [mGEMS paper](https://www.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000691) in 2021. The 2023 version of Themisto implements an order of magnitude faster build and query algorithms than the state-of-the-art at the time, and introduces a new hybrid method of pseudoalignment that combines ideas from existing algorithms.

### 2022
__Strong pathogen competition in neonatal gut colonisation__

__Tommi M&auml;klin__, Harry A Thorpe, Anna K P&ouml;ntinen, Rebecca A Gladstone, Yan Shao, Maiju Pesonen, Alan McNally, P&aring;l J Johnsen, &Oslash;rjan Samuelsen, Trevor D Lawley, Antti Honkela, and Jukka Corander

[Nature Communications](https://www.nature.com/articles/s41467-022-35178-5), 2022

We applied the mSWEEP and mGEMS methods to study colonization dynamics of _Escherichia coli_, _Klebsiella pneumoniae_, and _Enterococcus faecalis_ at the lineage-level. Our results highlighted a strong competitive advantage for the first strain to colonize the gut of a newborn but found no selection for hospital-adapted or disease-associated lineages. For more information, please see the [press release](https://www.sanger.ac.uk/news_item/healthy-newborns-in-the-uk-are-not-colonised-by-multi-drug-resistant-hospital-bacteria/) by the Wellcome Sanger Institute.

### 2021
__Bacterial genomic epidemiology with mixed samples__

__Tommi M&auml;klin__, Teemu Kallonen, Jarno N Alanko, &Oslash;rjan Samuelsen, Kristin Hegstad, Veli M&auml;kinen, Jukka Corander, Eva Heinz, and Antti Honkela

[Microbial Genomics](https://www.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000691), 2021

This article introduces the [mGEMS
pipeline](https://github.com/PROBIC/mGEMS) for deconvoluting
short-read sequencing data from samples containing multiple lineages
of the same bacterial species. mGEMS assigns each read to one or more
reference lineage(s) and produces an assignment of the reads that can
replace isolate sequencing data in standard epidemiological analyses
applied to metagenomic data. mGEMS has been used in study of [within-host diversity of _Streptococcus pneumoniae_](
https://www.nature.com/articles/s41564-022-01238-1) and [Enterobacteriaceae colonization dynamics](https://www.nature.com/articles/s41467-022-35178-5).

__High-resolution sweep metagenomics using fast probabilistic inference__

__Tommi M&auml;klin__, Teemu Kallonen, Sophia David, Christine J Boinett, Ben Pascoe, Guillaume M&eacute;ric, David M Aanensen, Edward J Feil, Stephen Baker, Julian Parkhill, Samuel K Sheppard, Jukka Corander, and Antti Honkela

[Wellcome Open Research](https://wellcomeopenresearch.org/articles/5-14/v2), 2021

This article describes the [mSWEEP
method](https://github.com/PROBIC/mSWEEP) for estimating the relative
abundances of lineages of a bacterial species in a set of short-read
sequencing data. mSWEEP is closely tied with the mGEMS tool and the
two are typically used together.
