class: CommandLineTool
label: MuSE
cwlVersion: v1.0
baseCommand: [/opt/bin/muse.py, -w, ./, --muse, MuSEv1.0rc]
requirements:
  - class: "DockerRequirement"
    dockerPull: "quay.io/pancancer/pcawg-muse:standard-output-names"
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
  coreNum:
    type: int?
    inputBinding:
      prefix: -n
  run-id:
    type: string?
    inputBinding:
      prefix: -O


outputs:
  somatic_snv_mnv_vcf_gz:
    type: File
    outputBinding:
      glob: '*.somatic.snv_mnv.vcf.gz'
    secondaryFiles:
    - .md5
    - .tbi
    - .tbi.md5


doc: |
    PCAWG MuSE variant calling workflow is developed by MD Anderson Cancer Center
    (http://bioinformatics.mdanderson.org/main/MuSE), it consists of software component calling structural
    variants using uniformly aligned tumor / normal WGS sequences. The workflow has been dockerized and
    packaged using CWL workflow language, the source code is available on GitHub
    at: https://github.com/ICGC-TCGA-PanCancer/pcawg-muse.


    ## Run the workflow with your own data

    ### Prepare compute environment and install software packages
    The workflow has been tested in Ubuntu 16.04 Linux environment with the following hardware and software
    settings.

    #### Hardware requirement (assuming 30X coverage whole genome sequence)
    - CPU core: 16
    - Memory: 64GB
    - Disk space: 1TB

    #### Software installation
    - Docker (1.12.6): follow instructions to install Docker https://docs.docker.com/engine/installation
    - CWL tool
    ```
    pip install cwltool==1.0.20170217172322
    ```

    ### Prepare input data
    #### Input aligned tumor / normal BAM files

    The workflow uses a pair of aligned BAM files as input, one BAM for tumor, the other for normal,
    both from the same donor. For improved calling result we pre-process the aligned BAMs using PCAWG GATK
    Co-cleaning workflow, see [here](https://dockstore.org/workflows/ICGC-TCGA-PanCancer/pcawg-gatk-cocleaning)
    for more information how to run it.

    Here we assume aligned pre-processed BAMs are *tumor_sample.bam* and *normal_sample.bam*,
    and are under *bams* subfolder.

    #### Reference data files

    The workflow also uses two reference files as input, both can be downloaded from the ICGC Data Portal:
    - reference genome sequence *genome.fa.gz* under https://dcc.icgc.org/releases/PCAWG/reference_data/pcawg-bwa-mem
    - known dbSNP entries *dbsnp_132_b37.leftAligned.vcf.gz* under https://dcc.icgc.org/releases/PCAWG/reference_data/pcawg-muse

    We assume the reference files are under *reference* subfolder.

    #### Job JSON file for CWL

    Finally, we need to prepare a JSON file with input, reference files specified. Please replace the
    *tumor* and *normal* parameters with your real BAM files.

    Name the JSON file: *pcawg-muse-variant-caller.job.json*
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

    ### Run the workflow
    #### Option 1: Run with CWL tool
    - Download CWL workflow definition file
    ```
    wget -O pcawg-muse-variant-caller.cwl "https://raw.githubusercontent.com/ICGC-TCGA-PanCancer/pcawg-muse/0.1.2/muse.cwl"
    ```

    - Run `cwltool` to execute the workflow
    ```
    nohup cwltool --debug --non-strict pcawg-muse-variant-caller.cwl pcawg-muse-variant-caller.job.json > pcawg-muse-variant-caller.log 2>&1 &
    ```

    #### Option 2: Run with the Dockstore CLI
    See the *Launch with* section below for details.
