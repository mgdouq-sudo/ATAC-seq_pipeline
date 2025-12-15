#!/usr/bin/env nextflow

process REMOVE_MITO {
    
    label 'process_high'
    container 'ghcr.io/bf528/samtools:latest'
    // publishDir "${params.outdir}/bam_no_mito", mode: 'copy'

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("${sample}.no_mito.bam")

    script:
    """
    samtools view -@ $task.cpus -h $bam | \
        grep -v chrM | \
        samtools view -b - > ${sample}.no_mito.bam
    """

    stub:
    """
    touch ${sample}.no_mito.bam
    """
}