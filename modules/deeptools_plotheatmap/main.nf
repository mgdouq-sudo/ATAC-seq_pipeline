#!/usr/bin/env nextflow

process PLOTHEATMAP {

    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/plotHeatmap", mode: 'copy'

    input:
    path(matrix)

    output:
    path('*.png')

    script:
    def prefix = matrix.baseName
    """
    plotHeatmap -m $matrix -o ${prefix}_heatmap.png --sortRegions descend --regionsLabel "Loss" "Gain"
    """

    stub:
    """
    touch heatmap.png
    """
}