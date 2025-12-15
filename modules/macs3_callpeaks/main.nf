#!/usr/bin/env nextflow

process CALLPEAKS {
    label 'process_high'
    container 'ghcr.io/bf528/macs3:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path('*narrowPeak')

    script:
    """
    macs3 callpeak -t $bam -f BAM -g mm -n $sample -B -q 0.01 --nomodel --keep-dup auto --extsize 147
    """

    stub:
    """
    touch ${sample}_peaks.narrowPeak
    """
}