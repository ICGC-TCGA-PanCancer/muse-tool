class: CommandLineTool
label: MuSE
cwlVersion: v1.0
baseCommand: [/opt/bin/muse.py, -O, muse.vcf, -w, ./, --muse, MuSEv1.0rc]
requirements:
  - class: "DockerRequirement"
    dockerPull: "quay.io/pancancer/pcawg-muse:0.1.2"
inputs:
  tumor:
    type: File
    inputBinding:
      prefix: --tumor-bam
    secondaryFiles:
      - .bai
  normal:
    type: File
    inputBinding:
      prefix: --normal-bam
    secondaryFiles:
      - .bai
  reference:
    type: File
    inputBinding:
      prefix: -f
  known:
    type: File
    inputBinding:
      prefix: -D
  mode:
    type: {"type": "enum", "name": "Mode", "symbols": ["wgs", "wxs"]}
    inputBinding:
      prefix: --mode
outputs:
  mutations:
    type: File
    outputBinding:
      glob: muse.vcf
      
doc: |
  PCAWG MuSE variant calling workflow is developed by MD Anderson Cancer Center ([http://bioinformatics.mdanderson.org/main/MuSE](http://bioinformatics.mdanderson.org/main/MuSE)), it consists of software components calling structural variants using uniformly aligned tumor / normal WGS sequences. The workflow has been dockerized and packaged using CWL workflow language, the source code is available on GitHub at: [https://github.com/ICGC-TCGA-PanCancer/pcawg-muse](https://github.com/ICGC-TCGA-PanCancer/pcawg-muse). The workflow is also registered in Dockstore at: [https://dockstore.org/containers/quay.io/pancancer/pcawg-muse](https://dockstore.org/containers/quay.io/pancancer/pcawg-muse).


    ## Run the workflow with your own data
    
    ### Prepare compute environment and install software packages
    The workflow has been tested in Ubuntu 16.04 Linux environment with the following hardware and software settings.
    
    1. Hardware requirement (assuming X30 coverage whole genome sequence)
    - CPU core: 16
    - Memory: 64GB
    - Disk space: 1TB
    
    2. Software installation
    - Docker (1.12.6): follow instructions to install Docker https://docs.docker.com/engine/installation
    - CWL tool
    ```
    pip install cwltool==1.0.20170217172322
    ```
    
    ### Prepare input data
    1. Input aligned tumor / normal BAM files
    
    The workflow uses a pair of aligned BAM files as input, one BAM for tumor, the other for normal, both from the same donor. Here we assume file names are `tumor_sample.bam` and `normal_sample.bam`, and both files are under `bams` subfolder.
    
    2. Reference data files
    
    The workflow also uses two reference files as input, both can be downloaded from the ICGC Data Portal:
    - reference genome sequence `genome.fa.gz` under [https://dcc.icgc.org/releases/PCAWG/reference_data/pcawg-bwa-mem](https://dcc.icgc.org/releases/PCAWG/reference_data/pcawg-bwa-mem).
    - known dbSNP entries `dbsnp_132_b37.leftAligned.vcf.gz` under [https://dcc.icgc.org/releases/PCAWG/reference_data/pcawg-muse](https://dcc.icgc.org/releases/PCAWG/reference_data/pcawg-muse)
    
    We assume the reference files are under `reference` subfolder.
    
    3. Job JSON file for CWL
    
    Finally, we need to prepare a JSON file with input, reference files specified. Please replace the `tumor` and `normal` parameters with your real BAM files.
    
    Name the JSON file: `pcawg-muse-variant-caller.job.json`
    ```
    {
        "mode": "wgs",
        "tumor": {
             "class": "File",
             "location": "bams/tumor_sample.bam"
         },
         "normal": {
            "class": "File",
            "location": "bams/normal_sample.bam"
        },
        "reference": {
            "class": "File",
            "location": "reference/genome.fa.gz"
        },
        "known": {
            "class": "File",
            "location": "reference/dbsnp_132_b37.leftAligned.vcf.gz"
        }
    }
    ```
