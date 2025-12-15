#!/usr/bin/env nextflow

process SAMTOOLS_SORT {
    label 'process_medium'
    container 'ghcr.io/bf528/samtools:latest'
    // publishDir "${params.outdir}/samtools_sort_full", mode: 'copy'

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("*sorted.bam"), emit: sorted

    script:
    """
    samtools sort -@ 8 $bam > ${sample}.sorted.bam
    """

    stub:
    """
    touch ${sample}.sorted.bam
    """
}