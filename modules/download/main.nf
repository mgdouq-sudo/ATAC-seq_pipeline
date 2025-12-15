#!/usr/bin/env nextflow

process DOWNLOAD {

    label 'process_low'
    publishDir "${params.outdir}/raw_reads", mode:'copy'
    
    input:

    tuple val(sample), val(ftp)

    output:

    tuple val(sample), path("${sample}.fastq.gz")

    script:
    """
    wget -O ${sample}.fastq.gz $ftp
    """

}