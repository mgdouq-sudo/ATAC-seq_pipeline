#!/usr/bin/env nextflow

process ANNOTATE {

    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/annotations", mode:'copy'

    input:
    tuple val(group), path(peaks)
    path(genome)
    path(gtf)

    output:
    tuple val(group), path("${group}_annotated.txt")

    script:
    """
    annotatePeaks.pl $peaks $genome -gtf $gtf > ${group}_annotated.txt
    """
    
    stub:
    """
    touch ${group}_annotated.txt
    """
}



