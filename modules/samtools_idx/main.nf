#!/usr/bin/env nextflow

process SAMTOOLS_IDX {
    
    label 'process_low'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir "${params.outdir}/IDX", mode: 'copy'

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path(bam), path("*.bai"), emit: index

    script:
    """
    samtools index --threads $task.cpus $bam
    """

    stub:
    """
    touch ${sample}.sorted.bam.bai
    """
}