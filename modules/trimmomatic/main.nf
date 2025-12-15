#!/usr/bin/env nextflow

process TRIM {

    label 'process_low'
    container 'ghcr.io/bf528/trimmomatic:latest'
    // publishDir "${params.outdir}/trimmomatic_full", mode: "copy"

    input:
    tuple val(sample), path(read)
    path(adapters)

    output:
    tuple val(sample), path("${sample}_trimmed.fastq.gz"), emit: gz
    tuple val(sample), path("${sample}_trimmomatic.log"), emit: log

    script:
    """
    trimmomatic SE -threads $task.cpus \
        ${read} ${sample}_trimmed.fastq.gz \
        ILLUMINACLIP:${adapters}:2:30:10 \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
        2> ${sample}_trimmomatic.log
    """

    stub:
    """
    touch ${sample}_stub_trim.log
    touch ${sample}_stub_trimmed.fastq.gz
    """
}
