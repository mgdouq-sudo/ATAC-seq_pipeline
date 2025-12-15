process DEBUG_TSS_MATRIX {
    
    label 'process_low'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/TSS_Debug", mode: 'copy'

    input:
    tuple val(celltype), path(matrix)

    output:
    path("${celltype}_debug.txt")

    script:
    """
    #!/usr/bin/env python3
    import numpy as np
    import gzip
    
    with gzip.open('${matrix}', 'rt') as f:
        all_lines = f.readlines()
    
    # Find where data starts
    header_lines = [i for i, line in enumerate(all_lines) if line.startswith('@')]
    
    with open('${celltype}_debug.txt', 'w') as out:
        out.write(f"Total lines: {len(all_lines)}\\n")
        out.write(f"Header lines (starting with @): {len(header_lines)}\\n")
        out.write(f"Data starts at line: {max(header_lines)+1 if header_lines else 0}\\n\\n")
        
        # Show first data line
        data_start = max(header_lines)+1 if header_lines else 0
        out.write("First data line (column headers):\\n")
        out.write(all_lines[data_start][:200] + "...\\n\\n")
        
        # Show second data line (first actual data)
        if len(all_lines) > data_start + 1:
            out.write("Second data line (first data row):\\n")
            parts = all_lines[data_start + 1].strip().split('\\t')
            out.write(f"Total columns: {len(parts)}\\n")
            out.write(f"First 6 columns (metadata): {parts[:6]}\\n")
            out.write(f"Number of data columns: {len(parts[6:])}\\n")
            out.write(f"First 10 data values: {parts[6:16]}\\n")
            out.write(f"Middle 10 data values: {parts[len(parts)//2-5:len(parts)//2+5]}\\n")
            out.write(f"Last 10 data values: {parts[-10:]}\\n\\n")
        
        # Parse and analyze all data
        data = []
        for line in all_lines[data_start+1:]:
            values = line.strip().split('\\t')[6:]
            data.append([float(x) if x != 'nan' else 0 for x in values])
        
        data = np.array(data)
        out.write(f"\\nData shape: {data.shape} (rows x columns)\\n")
        out.write(f"Mean of all values: {np.mean(data):.3f}\\n")
        out.write(f"Max value: {np.max(data):.3f}\\n")
        out.write(f"Min value: {np.min(data):.3f}\\n")
        
        # Check each column's average
        n_bins = data.shape[1]
        out.write(f"\\nBin-wise averages (first 20, middle 20, last 20):\\n")
        out.write(f"First 20 bins avg: {np.mean(data[:, :20]):.3f}\\n")
        out.write(f"Middle 20 bins avg: {np.mean(data[:, n_bins//2-10:n_bins//2+10]):.3f}\\n")
        out.write(f"Last 20 bins avg: {np.mean(data[:, -20:]):.3f}\\n")
    """
}