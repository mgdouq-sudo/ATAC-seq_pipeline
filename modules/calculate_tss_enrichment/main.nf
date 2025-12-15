process CALCULATE_TSS_ENRICHMENT {
    
    label 'process_low'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/TSS_Enrichment", mode: 'copy'

    input:
    tuple val(celltype), path(matrix)

    output:
    tuple val(celltype), path("${celltype}_tss_enrichment.txt")

    script:
    """
    #!/usr/bin/env python3
    import numpy as np
    import gzip
    
    # Load matrix
    with gzip.open('${matrix}', 'rt') as f:
        lines = [line for line in f if not line.startswith('@')]
    
    # Parse data
    data = []
    for line in lines[1:]:  # Skip column header
        values = line.strip().split('\\t')[6:]  # Skip metadata columns
        data.append([float(x) if x != 'nan' else 0 for x in values])
    
    data = np.array(data)
    n_total_cols = data.shape[1]
    
    # Determine number of samples
    # computeMatrix with -b 2000 -a 2000 creates 400 bins per sample
    bins_per_sample = 400
    n_samples = n_total_cols // bins_per_sample
    
    print(f"Total columns: {n_total_cols}")
    print(f"Bins per sample: {bins_per_sample}")
    print(f"Number of samples: {n_samples}")
    
    # Open output file
    with open('${celltype}_tss_enrichment.txt', 'w') as out:
        out.write("Sample\\tTSS_Enrichment\\tTSS_Signal\\tBackground_Signal\\n")
        
        # Calculate enrichment for each sample
        for sample_idx in range(n_samples):
            start_col = sample_idx * bins_per_sample
            end_col = (sample_idx + 1) * bins_per_sample
            
            sample_data = data[:, start_col:end_col]
            
            # TSS region: center ±50bp (bins 190-210 out of 400)
            center_start = 190
            center_end = 210
            
            # Flanking regions: first and last 20 bins (~200bp each)
            flank_bins = 20
            
            tss_signal = np.mean(sample_data[:, center_start:center_end])
            flank_signal = np.mean([
                np.mean(sample_data[:, :flank_bins]),
                np.mean(sample_data[:, -flank_bins:])
            ])
            
            enrichment = tss_signal / flank_signal if flank_signal > 0 else 0
            
            sample_name = f"${celltype}_sample{sample_idx+1}"
            out.write(f"{sample_name}\\t{enrichment:.3f}\\t{tss_signal:.3f}\\t{flank_signal:.3f}\\n")
            print(f"{sample_name}: TSS Enrichment = {enrichment:.3f}")
        
        # Calculate overall average
        all_tss = []
        all_flank = []
        for sample_idx in range(n_samples):
            start_col = sample_idx * bins_per_sample
            end_col = (sample_idx + 1) * bins_per_sample
            sample_data = data[:, start_col:end_col]
            
            all_tss.append(np.mean(sample_data[:, 190:210]))
            all_flank.append(np.mean([
                np.mean(sample_data[:, :20]),
                np.mean(sample_data[:, -20:])
            ]))
        
        avg_enrichment = np.mean(all_tss) / np.mean(all_flank)
        out.write(f"${celltype}_average\\t{avg_enrichment:.3f}\\t{np.mean(all_tss):.3f}\\t{np.mean(all_flank):.3f}\\n")
        print(f"${celltype} Average: TSS Enrichment = {avg_enrichment:.3f}")
    """

    stub:
    """
    echo -e "Sample\\tTSS_Enrichment\\tTSS_Signal\\tBackground_Signal" > ${celltype}_tss_enrichment.txt
    echo -e "${celltype}_sample1\\t10.5\\t25.3\\t2.4" >> ${celltype}_tss_enrichment.txt
    echo -e "${celltype}_sample2\\t11.2\\t26.1\\t2.3" >> ${celltype}_tss_enrichment.txt
    """
}