#!/usr/bin/env nextflow

process BOWTIE2_BUILD {

    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir params.outdir, mode:'copy'

    input:
    path(consensus)

    output:
    tuple val("${consensus.baseName}"), path("bowtie2_index/")

    script:
    """ 
    mkdir bowtie2_index
    bowtie2-build --threads 32 $consensus bowtie2_index/${consensus.baseName}
    """

    stub:
    """
    mkdir bowtie2_index
    """
}