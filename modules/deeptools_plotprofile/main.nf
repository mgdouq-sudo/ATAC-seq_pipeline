#!/usr/bin/env nextflow

process PLOTPROFILE {

    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/plotProfile", mode: 'copy'

    
    input:
    
    path(matrix)

    output:

    path('*')

    script:
    def prefix = matrix.baseName
    """
    plotProfile -m $matrix -o ${prefix}_singal_coverage.png
    """

    stub:
    """
    touch ${sample_id}_signal_coverage.png
    """
}