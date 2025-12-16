## ATAC-seq Analysis Pipeline
Overview

This repository contains a Nextflow-based ATAC-seq analysis pipeline for comparing chromatin accessibility between WT and KO conditions in cDC1 and cDC2 dendritic cells.

## The pipeline performs:

Raw FASTQ download from EBI FTP server (SRA data)

Quality control (FastQC, MultiQC)

Adapter trimming (Trimmomatic)

Alignment to mouse genome (Bowtie2)

Removal of mitochondrial reads

BAM sorting, indexing, and alignment QC

Peak calling (MACS3)

Blacklist filtering

FRiP score calculation

Replicate peak merging

Peak annotation and motif analysis (HOMER)

Signal visualization (bigWig, deepTools)

Correlation analysis between samples

Integration with DiffBind (ATAC-seq) and DESeq2 (RNA-seq)

## The workflow is designed to run using Singularity containers.

## Input Data
Sample Sheet

The pipeline expects a CSV file with the following format:

sample,ftp
ATAC_cDC1_WT_1,ftp://...
ATAC_cDC1_KO_1,ftp://...
...


sample: Unique sample ID (must encode cell type and condition)

ftp: FTP path to gzipped FASTQ file (single-end)

This file is specified via:

--samplesheet samplesheet.csv

## Reference Files

The following reference files are required (paths defined in nextflow.config):

Mouse genome FASTA (GRCm39)

GTF annotation (GENCODE)

ENCODE blacklist BED

TSS BED file

Adapter FASTA (TruSeq)

These are not downloaded automatically and must exist before running the pipeline.

## All tools are executed via containerized images from ghcr.io/bf528/*.

Running the Pipeline
1. Load Nextflow

On BU SCC:

conda activate nextflow_latest

2. Run on SCC
nextflow run main.nf \
  -profile singularity,cluster \
  -resume


This uses:

SGE scheduler

Project allocation bf528

Automatically mounts SCC directories

Process-specific CPU allocation via labels

3. Run Locally (small tests only)  (Not recommended for full datasets.)
nextflow run main.nf \
  -profile singularity,local


## Key Pipeline Steps

# Quality Control:

FastQC on raw reads

MultiQC summary of FastQC, Trimmomatic, and alignment stats

# Alignment:

Bowtie2 alignment to mouse genome

# Mitochondrial reads removed

# Sorted and indexed BAM files

# Peak Calling:

MACS3 narrowPeak calling

# Blacklist filtering using BEDTools

# FRiP Score

Fraction of Reads in Peaks computed per sample

Outputs per-sample .txt and .csv files

Downstream R script summarizes FRiP by condition and cell type

# Peak Merging

Replicates merged by:

Cell type (cDC1 / cDC2)

Condition (WT / KO)

# Merged peaks used for annotation and motif analysis

Annotation & Motifs

HOMER annotatePeaks.pl

findMotifsGenome.pl for TF motif enrichment

# Signal Visualization

bigWig generation (bamCoverage)

# deepTools:

multiBigwigSummary

plotCorrelation

computeMatrix

plotHeatmap

plotProfile

## Separate analyses are performed for cDC1 and cDC2.

Differential Accessibility (ATAC-seq)

Differential accessibility is performed outside Nextflow using DiffBind (edgeR):

WT vs KO contrasts

Significant peaks: p < 0.01

Gained vs lost accessibility exported as BED files

Annotated using ChIPseeker

One peak per gene selected (closest to TSS) for RNA integration

# Outputs:

Annotated peak tables

BED files for gained/lost accessibility

Labeled peak sets for visualization

## Differential Expression (RNA-seq)

RNA-seq analysis is performed using DESeq2:

Raw count matrices

Design: ~ condition

Low-count filtering

Significance threshold: FDR < 0.05

# Outputs:

Differential expression tables

Lists of up/downregulated genes per cell type

ATAC–RNA Integration

For each cell type:

## ATAC log2FC vs RNA log2FC merged by gene

Genes classified into quadrants:

Up–Up

Down–Down

Discordant

Concordant genes highlighted

Correlation plots saved as PNG

# Output Directory

All results are written to:

results/


## Notes

Pipeline is single-end ATAC-seq

Genome build: mm39

Designed for BU BF528 final project

Resume mode enabled by default

Modular design allows easy extension

## Author

Mohammad Gharandouq
M.S. Bioinformatics, Boston University