#!/usr/bin/env nextflow

process CALCULATE_FRIP {
    
    label 'process_medium'
    container 'ghcr.io/bf528/bedtools_samtools:latest'
    publishDir "${params.outdir}/frip", mode: 'copy'
    
    input:
    tuple val(sample), path(bam), path(peaks)
    
    output:
    tuple val(sample), path("${sample}_frip.txt"), emit: txt
    path("${sample}_frip.csv"), emit: csv
    
    script:
    """
    # Count total reads
    total_reads=\$(samtools view -c -F 260 ${bam})
    
    # Count reads in peaks
    reads_in_peaks=\$(bedtools intersect -a ${bam} -b ${peaks} -u -f 0.20 | samtools view -c)
    
    # Calculate FRiP with awk (no bc needed)
    frip=\$(echo "\$reads_in_peaks \$total_reads" | awk '{printf "%.4f", \$1/\$2}')
    
    # Output
    echo "Sample: ${sample}" > ${sample}_frip.txt
    echo "Total reads: \$total_reads" >> ${sample}_frip.txt
    echo "Reads in peaks: \$reads_in_peaks" >> ${sample}_frip.txt
    echo "FRiP: \$frip" >> ${sample}_frip.txt
    
    echo "${sample},\$total_reads,\$reads_in_peaks,\$frip" > ${sample}_frip.csv
    """
    
    stub:
    """
    touch ${sample}_frip.txt
    touch ${sample}_frip.csv
    """
}