// Include your modules here
include {DOWNLOAD} from './modules/download'
include {FASTQC} from './modules/fastqc'
include {TRIM} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {REMOVE_MITO} from './modules/remove_mito'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {MULTIQC} from './modules/multiqc'
include {BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include {MULTIBWSUMMARY} from './modules/deeptools_multibwsummary'
include {PLOTCORRELATION} from './modules/deeptools_plotcorrelation'
include {CALLPEAKS} from './modules/macs3_callpeaks'
include {BEDTOOLS_REMOVE} from './modules/bedtools_remove'
include {MERGE_REPLICATE_PEAKS} from './modules/merge_peaks'
include {ANNOTATE} from './modules/homer_annotatepeaks'
include {COMPUTEMATRIX as COMPUTEMATRIX_CDC1} from './modules/deeptools_computematrix'
include {COMPUTEMATRIX as COMPUTEMATRIX_CDC2} from './modules/deeptools_computematrix'
include {COMPUTE_TSS_MATRIX as COMPUTE_TSS_MATRIX_CDC1} from './modules/deeptools_computetssmatrix'
include {COMPUTE_TSS_MATRIX as COMPUTE_TSS_MATRIX_CDC2} from './modules/deeptools_computetssmatrix'
include {PLOTHEATMAP as PLOTHEATMAP_CDC1} from './modules/deeptools_plotheatmap'
include {PLOTHEATMAP as PLOTHEATMAP_CDC2} from './modules/deeptools_plotheatmap'
include {PLOTPROFILE as PLOTPROFILE_CDC1} from './modules/deeptools_plotprofile'
include {PLOTPROFILE as PLOTPROFILE_CDC2} from './modules/deeptools_plotprofile'
include {CALCULATE_TSS_ENRICHMENT as CALCULATE_TSS_ENRICHMENT_CDC1} from './modules/calculate_tss_enrichment'
include {CALCULATE_TSS_ENRICHMENT as CALCULATE_TSS_ENRICHMENT_CDC2} from './modules/calculate_tss_enrichment'
include {DEBUG_TSS_MATRIX as DEBUG_TSS_MATRIX_CDC1} from './modules/debug_tss_matrix'
include {DEBUG_TSS_MATRIX as DEBUG_TSS_MATRIX_CDC2} from './modules/debug_tss_matrix'
include {FIND_MOTIFS_GENOME} from './modules/homer_findmotifsgenome'
include {CALCULATE_FRIP} from './modules/calculate_frip'

workflow {

    
    //Here we construct the initial channels we need
    
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map{ row -> tuple( row.sample, row.ftp) }
    | view()
    | set { sample_ch }

    DOWNLOAD(sample_ch)
    FASTQC(DOWNLOAD.out)
    TRIM(DOWNLOAD.out, params.adapter_fa)
    BOWTIE2_BUILD(params.genome)
    BOWTIE2_ALIGN(TRIM.out.gz, BOWTIE2_BUILD.out)
    REMOVE_MITO(BOWTIE2_ALIGN.out)
    SAMTOOLS_SORT(REMOVE_MITO.out)
    SAMTOOLS_IDX(SAMTOOLS_SORT.out)
    SAMTOOLS_FLAGSTAT(REMOVE_MITO.out)

    FASTQC.out.zip.map { it[1] }.collect()
        | set { fastqc_ch }

    TRIM.out.log.map { it[1] }.collect()
        | set { trim_ch }

    SAMTOOLS_FLAGSTAT.out.map { it[1] }.collect()
        | set { flagstat_ch }

    fastqc_ch.mix(trim_ch).mix(flagstat_ch).flatten().collect()
        | set { multiqc_ch }

    MULTIQC(multiqc_ch)
    BAMCOVERAGE(SAMTOOLS_IDX.out)
    CALLPEAKS(SAMTOOLS_SORT.out)
    BEDTOOLS_REMOVE(CALLPEAKS.out, params.blacklist)

    SAMTOOLS_SORT.out
    .join(BEDTOOLS_REMOVE.out)
    .view()
    .set { bam_and_peaks }

    CALCULATE_FRIP(bam_and_peaks)

    merged_peaks = BEDTOOLS_REMOVE.out
        .map { name, bed -> 
            def celltype = (name =~ /cDC\d/)[0]
            def condition = (name =~ /WT|KO/)[0]
            tuple("${celltype}_${condition}", bed)
        }
        .groupTuple()  // Combine reps within same celltype+condition
    merged_peaks.view()

    MERGE_REPLICATE_PEAKS(merged_peaks)
    
    ANNOTATE(MERGE_REPLICATE_PEAKS.out, params.genome, params.gtf)
    FIND_MOTIFS_GENOME(MERGE_REPLICATE_PEAKS.out, params.genome)

    BAMCOVERAGE.out.map { sample, bw -> bw }.collect()
    | set { bw_ch }

    MULTIBWSUMMARY(bw_ch)
    PLOTCORRELATION(MULTIBWSUMMARY.out.npz)

    // Split bigWigs by cell type
    BAMCOVERAGE.out
        .branch { sample, bw ->
            cDC1: sample.contains('cDC1')
                return tuple(sample, bw)
            cDC2: sample.contains('cDC2')
             return tuple(sample, bw)
     }
        .set { bw_by_celltype }

    // Collect bigWigs for each cell type
    bw_by_celltype.cDC1
        .map { sample, bw -> bw }
        .collect()
        .view()
        .set { cDC1_bw }

    bw_by_celltype.cDC2
        .map { sample, bw -> bw }
        .collect()
        .view()
        .set { cDC2_bw }

    // Run compute matrix separately for each cell type
    COMPUTEMATRIX_CDC1('cDC1', cDC1_bw, params.cdc1_lost_peaks, params.cdc1_gained_peaks)
        .set { cDC1_matrix }

    COMPUTEMATRIX_CDC2('cDC2', cDC2_bw, params.cdc2_lost_peaks, params.cdc2_gained_peaks)
        .set { cDC2_matrix }

    COMPUTE_TSS_MATRIX_CDC1('cDC1', cDC1_bw, params.TSS)
        .set { cDC1_TSS_matrix }
    
    COMPUTE_TSS_MATRIX_CDC2('cDC2', cDC2_bw, params.TSS)
        .set { cDC2_TSS_matrix }

    // Calculate TSS enrichment scores
    CALCULATE_TSS_ENRICHMENT_CDC1(cDC1_TSS_matrix)
    CALCULATE_TSS_ENRICHMENT_CDC2(cDC2_TSS_matrix)

    // After COMPUTE_TSS_MATRIX
    DEBUG_TSS_MATRIX_CDC1(cDC1_TSS_matrix)
    DEBUG_TSS_MATRIX_CDC2(cDC2_TSS_matrix)
    
    // Plot separately with labels
    PLOTHEATMAP_CDC1(cDC1_matrix.map { celltype, matrix -> matrix })
    PLOTHEATMAP_CDC2(cDC2_matrix.map { celltype, matrix -> matrix })
    PLOTPROFILE_CDC1(cDC1_TSS_matrix.map { celltype, matrix -> matrix })
    PLOTPROFILE_CDC2(cDC2_TSS_matrix.map { celltype, matrix -> matrix })

}