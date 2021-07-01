cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../../tools/schemas/indexed_file.yaml
      - $import: ../../tools/schemas/optional_file.yaml
      - $import: ../../tools/schemas/optional_file_uuid.yaml

inputs:
  bioclient_config: File
  annotated_vcf_uuid: string
  annotated_vcf_index_uuid: string
  biotype_priority_uuid: string
  effect_priority_uuid: string
  reference_fasta_uuid: string
  reference_fasta_index_uuid: string
  custom_enst_uuid: string?
  dbsnp_priority_db_uuid: string?
  cosmic_vcf_uuid: string?
  cosmic_vcf_index_uuid: string?
  non_tcga_exac_vcf_uuid: string?
  non_tcga_exac_vcf_index_uuid: string?
  hotspot_tsv_uuid: string?
  gdc_blacklist_uuid: string?
  gdc_pon_vcf_uuid: string?
  gdc_pon_vcf_index_uuid: string?
  nonexonic_intervals_uuid: string?
  nonexonic_intervals_index_uuid: string?
  target_intervals_record:
    type:
      type: array
      items: ../../tools/schemas/indexed_file.yaml#indexed_file

outputs:
  annotated_vcf:
    type: File
    outputSource: extract_vcf/output_indexed_file

  biotype_priority:
    type: File
    outputSource: extract_biotype/output

  effect_priority:
    type: File
    outputSource: extract_effect/output

  reference_fasta:
    type: File
    outputSource: extract_ref/output

  reference_fasta_index:
    type: File
    outputSource: extract_ref_index/output

  optional_files:
    type:
      type: array
      items: ../../tools/schemas/optional_file.yaml#optional_file
    outputSource: run_merge_arrays/output

steps:
  extract_vcf:
    run: ./extract_file_with_index.cwl 
    in:
      bioclient_config: bioclient_config
      file_uuid: annotated_vcf_uuid
      index_uuid: annotated_vcf_index_uuid
    out: [ output_indexed_file ]

  extract_biotype:
    run: ../../tools/bioclient_download.cwl
    in:
      config-file: bioclient_config
      download_handle: biotype_priority_uuid 
    out: [ output ]

  extract_effect:
    run: ../../tools/bioclient_download.cwl
    in:
      config-file: bioclient_config
      download_handle: effect_priority_uuid 
    out: [ output ]

  extract_ref:
    run: ../../tools/bioclient_download.cwl
    in:
      config-file: bioclient_config
      download_handle: reference_fasta_uuid 
    out: [ output ]

  extract_ref_index:
    run: ../../tools/bioclient_download.cwl
    in:
      config-file: bioclient_config
      download_handle: reference_fasta_index_uuid 
    out: [ output ]

  get_optional_arrays:
    run: ../../tools/make_optional_extract_inputs.cwl
    in:
      custom_enst_uuid: custom_enst_uuid
      dbsnp_priority_db_uuid: dbsnp_priority_db_uuid
      cosmic_vcf_uuid: cosmic_vcf_uuid
      cosmic_vcf_index_uuid: cosmic_vcf_index_uuid
      non_tcga_exac_vcf_uuid: non_tcga_exac_vcf_uuid
      non_tcga_exac_vcf_index_uuid: non_tcga_exac_vcf_index_uuid
      hotspot_tsv_uuid: hotspot_tsv_uuid
      gdc_blacklist_uuid: gdc_blacklist_uuid
      gdc_pon_vcf_uuid: gdc_pon_vcf_uuid
      gdc_pon_vcf_index_uuid: gdc_pon_vcf_index_uuid
      nonexonic_intervals_uuid: nonexonic_intervals_uuid
      nonexonic_intervals_index_uuid: nonexonic_intervals_index_uuid
      target_intervals_record: target_intervals_record
    out: [ single_output, indexed_output ]

  extract_single_files:
    run: ./extract_single_optional_file.cwl
    scatter: single_file
    in:
      bioclient_config: bioclient_config
      single_file: get_optional_arrays/single_output
    out: [ output_single_file ]

  extract_indexed_files:
    run: ./extract_indexed_optional_file.cwl
    scatter: indexed_file
    in:
      bioclient_config: bioclient_config
      indexed_file: get_optional_arrays/indexed_output
    out: [ output_indexed_optional_file ]

  run_merge_arrays:
    run: ../../tools/merge_optional_file_arrays.cwl
    in:
      input_a: extract_single_files/output_single_file
      input_b: extract_indexed_files/output_indexed_optional_file
    out: [ output ]
