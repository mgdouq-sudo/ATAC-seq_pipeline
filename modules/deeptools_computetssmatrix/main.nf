#!/usr/bin/env nextflow

process COMPUTE_TSS_MATRIX {
    
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/ComputeTSSMatrix", mode: 'copy'

    input:
    tuple val(celltype) 
    path(bw) 
    path(tss) 

    output:
    tuple val(celltype), path('*.gz')

    script:
    """
    computeMatrix reference-point --referencePoint TSS \
        -S ${bw} \
        -R ${tss} \
        -b 2000 -a 2000 \
        --skipZeros \
        -p ${task.cpus} \
        -o ${celltype}_matrix.gz
    """

    stub:
    """
    touch ${celltype}_matrix.gz
    """
}