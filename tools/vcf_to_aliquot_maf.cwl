
cwlVersion: v1.0
class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/aliquot-maf-tools:{{ aliquot_maf_tools }}"
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: InitialWorkDirRequirement
    listing: |
      ${
        var listing = []
        listing.push(inputs.reference_fasta)
        listing.push(inputs.reference_fasta_index)
        return listing
      }
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMax: $(size_from_input_object(inputs))
    outdirMax: $(size_from_input_object(inputs))

inputs:
  input_vcf:
    type: File
    doc: Tabix-indexed VEP annotated VCF file
    inputBinding:
      prefix: --input_vcf
      position: 0
    secondaryFiles:
      - ".tbi"

  output_filename:
    type: string
    doc: basename of output MAF file
    inputBinding:
      prefix: --output_maf
      position: 1

  maf_schema:
    type: string
    default: gdc-2.0.0-aliquot
    doc: the schema to use for the maf
    inputBinding:
      position: 2

  tumor_only:
    type: boolean?
    default: False
    doc: Is this a tumor-only VCF?
    inputBinding:
      position: 3
      prefix: --tumor_only

  tumor_vcf_id:
    type: string?
    doc: Name of the tumor sample in the VCF, typically 'TUMOR'
    inputBinding:
      position: 4
      prefix: --tumor_vcf_id

  normal_vcf_id:
    type: string?
    doc: Name of the normal sample in the VCF, typically 'NORMAL'
    inputBinding:
      position: 5
      prefix: --normal_vcf_id

  caller_id:
    type: string
    doc: Name of the caller used to detect mutations
    inputBinding:
      position: 6
      prefix: --caller_id

  src_vcf_uuid:
    type: string
    doc: The UUID of the src VCF file
    inputBinding:
      position: 7
      prefix: --src_vcf_uuid

  case_uuid:
    type: string
    doc: Sample case UUID
    inputBinding:
      position: 8
      prefix: --case_uuid

  tumor_submitter_id:
    type: string
    doc: Tumor sample aliquot submitter ID
    inputBinding:
      position: 9
      prefix: --tumor_submitter_id

  tumor_aliquot_uuid:
    type: string
    doc: Tumor sample aliquot UUID
    inputBinding:
      position: 10
      prefix: --tumor_aliquot_uuid

  tumor_bam_uuid:
    type: string
    doc: Tumor sample bam UUID
    inputBinding:
      position: 11
      prefix: --tumor_bam_uuid

  normal_submitter_id:
    type: string?
    doc: Normal sample aliquot submitter ID
    inputBinding:
      position: 12
      prefix: --normal_submitter_id

  normal_aliquot_uuid:
    type: string?
    doc: Normal sample aliquot UUID
    inputBinding:
      position: 13
      prefix: --normal_aliquot_uuid

  normal_bam_uuid:
    type: string?
    doc: Normal sample bam UUID
    inputBinding:
      position: 14
      prefix: --normal_bam_uuid

  sequencer:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --sequencer
    default: null
    doc: The sequencer used
    inputBinding:
      position: 15

  maf_center:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --maf_center
    doc: The sequencing center
    inputBinding:
      position: 16

  biotype_priority_file:
    type: File
    doc: Biotype priority JSON
    inputBinding:
      position: 17
      prefix: --biotype_priority_file

  effect_priority_file:
    type: File
    doc: Effect priority JSON
    inputBinding:
      position: 18
      prefix: --effect_priority_file

  custom_enst:
    type: File?
    doc: Optional custom ENST overrides
    inputBinding:
      position: 19
      prefix: --custom_enst

  reference_fasta:
    type: File
    doc: Reference fasta file
    inputBinding:
      position: 21
      prefix: --reference_fasta
      valueFrom: $(self.basename)

  reference_fasta_index:
    type: File
    doc: Reference fasta fai file
    inputBinding:
      position: 22
      prefix: --reference_fasta_index
      valueFrom: $(self.basename)

  reference_context_size:
    type: int
    default: 5
    doc: Number of BP to add both upstream and downstream from variant for reference context
    inputBinding:
      position: 23
      prefix: --reference_context_size

  cosmic_vcf:
    type: File?
    doc: Optional COSMIC VCF for annotating
    inputBinding:
      position: 24
      prefix: --cosmic_vcf
    secondaryFiles:
      - ".tbi"

  hotspot_tsv:
    type: File?
    doc: Optional hotspot TSV
    inputBinding:
      position: 26
      prefix: --hotspot_tsv

  gdc_blacklist:
    type: File?
    doc: The file containing the blacklist tags and tumor aliquot uuids to apply them to.
    inputBinding:
      position: 28
      prefix: --gdc_blacklist

  min_n_depth:
    type: int?
    doc: Flag variants where normal depth is <= INT as ndp [7].
    inputBinding:
      position: 29
      prefix: --min_n_depth

  gdc_pon_vcf:
    type: File?
    doc: The tabix-indexed panel of normals VCF for applying the gdc pon filter
    inputBinding:
      position: 30
      prefix: --gdc_pon_vcf
    secondaryFiles:
      - ".tbi"

  nonexonic_intervals:
    type: File?
    doc: Flag variants outside of this tabix-indexed bed file as NonExonic
    inputBinding:
      position: 31
      prefix: --nonexonic_intervals
    secondaryFiles:
      - ".tbi"

  target_intervals:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --target_intervals
    default: null
    doc: Flag variants outside of these tabix-indexed bed files as off_target. Use one or more times.
    inputBinding:
      position: 32
    secondaryFiles:
      - ".tbi"

  gnomad_noncancer_vcf:
    type: File
    inputBinding:
      position: 33
      prefix: --gnomad_noncancer_vcf
    secondaryFiles:
      - ".tbi"

  gnomad_af_cutoff:
    type: float
    inputBinding:
      position: 34
      prefix: --gnomad_af_cutoff
    default: 0.001

  entrez_gene_id_json:
    type: File
    doc: JSON file used to look up entrez IDs given HGNC symbols or gencode IDs
    inputBinding:
      prefix: --entrez_gene_id_json
      position: 35

outputs:
  output_maf:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)

baseCommand: [aliquotmaf, VcfToAliquotMaf]
