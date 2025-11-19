---
title: "Publications"
date: 2023-02-28T15:32:43Z
draft: false
---

My research interests encompass bioinformatics software development,
genomic epidemiology of Enterobacteriaceae, strain-level metagenomics, and
statistical modelling related to these.

I am currently working on the following projects:
- Ecology and evolution of [colibactin production in _E. coli_](https://doi.org/10.1101/2025.11.17.686825).
- Carriage and global diversity of _E. coli_ in gut microbiome data.
- Algorithms based on _k_-bounded matching statistics: [alignment](https://doi.org/10.1101/2025.05.19.654936) and [compression](https://github.com/tmaklin/ntcomp).
- Scaling up pseudoalignment and sweep metagenomics with [better formats](https://github.com/tmaklin/ahda).
- Long-read metagenomics at the strain-level (mSWEEP-2).

I also like fixing small bugs in other people's research software that I use.

## Publication highlights
View the full list in my [resume](/academic-cv/#publications).
### 2025
__Co-evolution between colibactin production and resistance is linked to clonal expansions in _Escherichia coli___  
[pre-print available at bioRxiv](https://doi.org/10.1101/2025.11.17.686825 ), 2025

We looked into evolution of colibactin production in _E. coli_ and found that multi-drug resistant, colibactin non-producing lineages that are endemic in high-income countries have co-evolved with endemic colibactin producers by acquiring colibactin resistance genes before undergoing clonal expansions. Our study shows that the colibactin production genes are similarly derived from a mobile element origin, and are under strong purifying and balancing selection that maintains two conserved majority-minority variants of colibactin in the _E. coli_ population.

__Sequence alignment with _k_-bounded matching statistics__  
[pre-print available at bioRxiv](https://doi.org/10.1101/2025.05.19.654936), 2025

We introduce the [kbo](https://github.com/tmaklin/kbo) method for performing assembly-to-assembly variant calling, reference-based mapping, and gene finding. Kbo scales easily to tens-hundreds of thousands of query sequences by leveraging the [spectral Burrows-Wheeler transform](https://epubs.siam.org/doi/abs/10.1137/1.9781611977714.20) data structure to efficiently perform _k_-mer matching and compute the longest common suffix lengths of each match. This information is then transformed into an alignment using statistical denoising and a translation algorithm introduced in kbo.

### 2024
__Geographical variation in the incidence of colorectal cancer and urinary tract cancer is associated with population exposure to colibactin-producing _Escherichia coli___  
[Lancet Microbe](https://doi.org/10.1016/j.lanmic.2024.101015), 2024

We show that the geographical variation in population prevalence of colibactin-producing _E. coli_ lineages ST95 and ST73 in healthy carriage largely explains the variation in colorectal cancer incidence globally. Since ST95 and ST73 are are also major causes of UTIs, a similar link might also exist in some urinary tract cancers via exposure to colibactin during infection. Our study provides a potential vaccine target for reducing the burden from colibactin associated cancers by pinpointing the exact _E. coli_ lineages responsible in humans.

__Deep sequencing of _Escherichia coli_ exposes colonisation diversity and impact of antibiotics in Punjab, Pakistan__  
[Nature Communications](https://dx.doi.org/10.1038/s41467-024-49591-5), 2024

We investigated the impact of antimicrobial usage on the diversity of _E. coli_ strain carriage in a cross-sectional cohort from the Punjab province of Pakistan. Our results highlight notable differences in _E. coli_ competition and carriage compared to genomic cohorts from western and northen Europe. In particular the European-endemic non-MDR clinical strains ST73 and ST95 are nearly completely absent in Pakistan, and the prevalence of the MDR clinical strains ST69 and ST131 is highly reduced and modulated by recent antibiotic intake.

### 2023
__Themisto: a scalable colored k-mer index for sensitive pseudoalignment against hundreds of thousands of bacterial genomes__  
[Bioinformatics](https://academic.oup.com/bioinformatics/article/39/Supplement_1/i260/7210444), 2023

[Themisto](https://github.com/algbio/themisto) is a method for both building and querying colored de Bruijn graphs that was originally introduced in my [mGEMS paper](https://www.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000691) in 2021. The 2023 version of Themisto implements an order of magnitude faster build and query algorithms than the state-of-the-art at the time, and introduces a new hybrid method of pseudoalignment that combines ideas from existing algorithms.

### 2022
__Strong pathogen competition in neonatal gut colonisation__  
[Nature Communications](https://www.nature.com/articles/s41467-022-35178-5), 2022

We applied the mSWEEP and mGEMS methods to study colonization dynamics of _Escherichia coli_, _Klebsiella pneumoniae_, and _Enterococcus faecalis_ at the lineage-level. Our results highlighted a strong competitive advantage for the first strain to colonize the gut of a newborn but found no selection for hospital-adapted or disease-associated lineages. For more information, please see the [press release](https://www.sanger.ac.uk/news_item/healthy-newborns-in-the-uk-are-not-colonised-by-multi-drug-resistant-hospital-bacteria/) by the Wellcome Sanger Institute.

### 2021
__Bacterial genomic epidemiology with mixed samples__  
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
[Wellcome Open Research](https://wellcomeopenresearch.org/articles/5-14/v2), 2021

This article describes the [mSWEEP
method](https://github.com/PROBIC/mSWEEP) for estimating the relative
abundances of lineages of a bacterial species in a set of short-read
sequencing data. mSWEEP is closely tied with the mGEMS tool and the
two are typically used together.
