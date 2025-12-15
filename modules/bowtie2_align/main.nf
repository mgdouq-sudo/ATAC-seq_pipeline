#!/usr/bin/env nextflow

process BOWTIE2_ALIGN {
   
    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    // publishDir "${params.outdir}/bwtalign_full", mode:'copy'

    input:
    tuple val(name), path(read)
    tuple val(consensus), path(index)

    output:
    tuple val(name), path("*.bam")

    script:
    """ 
    bowtie2 --very-sensitive -p 32 -x bowtie2_index/${consensus} -U $read | samtools view -bS - > ${name}.bam
    """

    stub:
    """
    touch ${name}.bam
    """
}