#!/usr/bin/env nextflow

process MULTIBWSUMMARY {

    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/bwsum", mode: 'copy'

    input:
    path(bw)

    output:
    path("bw_all.npz"), emit: npz
    path("bw_all.tab"), emit: tab

    script:
    """
    multiBigwigSummary bins -b $bw -o bw_all.npz --outRawCounts bw_all.tab
    """
    stub:
    """
    touch bw_all.npz
    """
}