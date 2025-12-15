#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME {

label 'process_high'
container 'ghcr.io/bf528/homer_samtools:latest'
publishDir "${params.outdir}/findmotifs", mode:'copy'

input:

tuple val(merge), path(peaks)
path(genome)

output:
tuple val(merge), path("${merge}_motifs/")

script:
"""
findMotifsGenome.pl $peaks $genome ${merge}_motifs -size 200 -mask -p $task.cpus
"""

stub:
"""
mkdir ${merge}_motifs
"""
}


