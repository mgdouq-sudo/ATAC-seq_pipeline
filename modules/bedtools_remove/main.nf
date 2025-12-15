#!/usr/bin/env nextflow

process BEDTOOLS_REMOVE {

    label 'process_medium'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir "${params.outdir}/filtered_peaks", mode:'copy'
   
    input:
    tuple val(sample), path(peaks)
    path(blacklist)

    output:
    tuple val(sample), path("${sample}_filtered.bed")

    script:
    """
    bedtools intersect -a ${peaks} -b ${blacklist} -v > ${sample}_filtered.bed
    """
    
    stub:
    """
    touch ${sample}_filtered.bed
    """
}