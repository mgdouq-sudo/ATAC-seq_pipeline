#!/usr/bin/env nextflow

process BAMCOVERAGE {

    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/bw", mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai)

    output:
    tuple val(sample), path('*.bw'), emit: bigwig

    script:
    """
    bamCoverage -b $bam -o ${sample}.bw -p 8
    """

    stub:
    """
    touch ${sample}.bw
    """

}