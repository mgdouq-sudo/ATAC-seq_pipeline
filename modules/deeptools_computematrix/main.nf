#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/ComputeMatrix", mode: 'copy'

    input:
    tuple val(celltype) 
    path(bw) 
    path(lost_bed) 
    path(gained_bed)

    output:
    tuple val(celltype), path('*.gz')

    script:
    """
    computeMatrix reference-point --referencePoint center \
        -S ${bw} \
        -R ${lost_bed} ${gained_bed} \
        -a 1500 -b 1500 \
        --skipZeros \
        -p ${task.cpus} \
        -o ${celltype}_matrix.gz
    """

    stub:
    """
    touch ${celltype}_matrix.gz
    """
}