#!/usr/bin/env nextflow

process SAMTOOLS_FLAGSTAT {
    
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir "${params.outdir}/flagstat", mode:'copy'

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("*.flagstat.txt")

    script:
    """
    samtools flagstat ${bam} > ${bam.baseName}.flagstat.txt
    """

    stub:
    """
    touch ${bam}_flagstat.txt
    """
}