#!/usr/bin/env nextflow

process MERGE_REPLICATE_PEAKS {
    
    label 'process_medium'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir "${params.outdir}/merged_peaks", mode:'copy'
    
    input:
    tuple val(group), path(beds)

    output:
    tuple val(group), path("${group}_merged.bed")

    script:
    """
    # Concatenate all replicate peaks
    cat ${beds.join(' ')} > combined.bed
    
    # Sort combined peaks
    bedtools sort -i combined.bed > combined_sorted.bed
    
    # Merge overlapping peaks
    bedtools merge -i combined_sorted.bed > ${group}_merged.bed
    
    # Report statistics
    echo "Original peaks: \$(cat combined.bed | wc -l)" > ${group}_merge_stats.txt
    echo "Merged peaks: \$(cat ${group}_merged.bed | wc -l)" >> ${group}_merge_stats.txt
    """

    stub:
    """
    touch ${group}_merged.bed
    """
}