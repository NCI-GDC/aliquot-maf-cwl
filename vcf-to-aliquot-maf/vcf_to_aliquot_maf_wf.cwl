cwlVersion: v1.0
class: Workflow

requirements:
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ../tools/util_lib.cwl
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../tools/schemas.cwl

inputs:
  bioclient_config: File
  upload_bucket: string
  job_uuid: string
  annotated_vcf_uuid: string
  annotated_vcf_index_uuid: string
  gnomad_noncancer_vcf_uuid: string
  gnomad_noncancer_vcf_index_uuid: string
  entrez_gene_id_json_uuid: string
  biotype_priority_uuid: string
  effect_priority_uuid: string
  custom_enst_uuid: string?
  reference_fasta_uuid: string
  reference_fasta_index_uuid: string
  cosmic_vcf_uuid: string?
  cosmic_vcf_index_uuid: string?
  hotspot_tsv_uuid: string?
  gdc_blacklist_uuid: string?
  gdc_pon_vcf_uuid: string?
  gdc_pon_vcf_index_uuid: string?
  nonexonic_intervals_uuid: string?
  nonexonic_intervals_index_uuid: string?
  target_intervals_record:
    type:
      type: array
      items: ../tools/schemas.cwl#indexed_file
  case_uuid: string
  experimental_strategy: string
  tumor_submitter_id: string
  tumor_aliquot_uuid: string
  tumor_bam_uuid: string
  normal_submitter_id: string?
  normal_aliquot_uuid: string?
  normal_bam_uuid: string?
  sequencer:
    type:
      type: array
      items: string
    default: null
  maf_center: string[]
  context_size:
    type: int
    default: 5
  gnomad_af_cutoff:
    type: float?
    default: 0.001
  min_n_depth:
    type: int
    default: 7
  caller_id: string
  maf_aliquot_schema:
    type: string
    default: gdc-2.0.0-aliquot

outputs:
  aliquot_maf_uuid:
    type: string
    outputSource: upload_aliquot_maf/uuid

steps:
  stage_data:
    run: ./subworkflows/stage_data_workflow.vcf_to_aliquot_maf.cwl
    in:
      bioclient_config: bioclient_config
      annotated_vcf_uuid: annotated_vcf_uuid
      annotated_vcf_index_uuid: annotated_vcf_index_uuid
      biotype_priority_uuid: biotype_priority_uuid
      effect_priority_uuid: effect_priority_uuid
      custom_enst_uuid: custom_enst_uuid
      reference_fasta_uuid: reference_fasta_uuid
      reference_fasta_index_uuid: reference_fasta_index_uuid
      cosmic_vcf_uuid: cosmic_vcf_uuid
      cosmic_vcf_index_uuid: cosmic_vcf_index_uuid
      gnomad_noncancer_vcf_uuid: gnomad_noncancer_vcf_uuid
      gnomad_noncancer_vcf_index_uuid: gnomad_noncancer_vcf_index_uuid
      entrez_gene_id_json_uuid: entrez_gene_id_json_uuid
      hotspot_tsv_uuid: hotspot_tsv_uuid
      gdc_blacklist_uuid: gdc_blacklist_uuid
      gdc_pon_vcf_uuid: gdc_pon_vcf_uuid
      gdc_pon_vcf_index_uuid: gdc_pon_vcf_index_uuid
      nonexonic_intervals_uuid: nonexonic_intervals_uuid
      nonexonic_intervals_index_uuid: nonexonic_intervals_index_uuid
      target_intervals_record: target_intervals_record
    out:
      - annotated_vcf
      - biotype_priority
      - effect_priority
      - reference_fasta
      - reference_fasta_index
      - gnomad_noncancer_vcf
      - entrez_gene_id_json
      - optional_files

  get_file_prefix:
    run: ../tools/make_file_prefix.cwl
    in:
      caller_id: caller_id
      job_uuid: job_uuid
      experimental_strategy: experimental_strategy
    out: [ output ]

  make_aliquot_maf:
    run: ../tools/vcf_to_aliquot_maf.cwl
    in:
      input_vcf: stage_data/annotated_vcf
      output_filename:
        source: get_file_prefix/output
        valueFrom: $(self + '.aliquot.maf.gz')
      caller_id: caller_id
      src_vcf_uuid: annotated_vcf_uuid
      case_uuid: case_uuid
      tumor_submitter_id: tumor_submitter_id
      tumor_aliquot_uuid: tumor_aliquot_uuid
      tumor_bam_uuid: tumor_bam_uuid
      normal_submitter_id: normal_submitter_id
      normal_aliquot_uuid: normal_aliquot_uuid
      normal_bam_uuid: normal_bam_uuid
      sequencer: sequencer
      maf_center: maf_center
      biotype_priority_file: stage_data/biotype_priority
      effect_priority_file: stage_data/effect_priority
      reference_fasta: stage_data/reference_fasta
      reference_fasta_index: stage_data/reference_fasta_index
      reference_context_size: context_size
      gnomad_noncancer_vcf: stage_data/gnomad_noncancer_vcf
      entrez_gene_id_json: stage_data/entrez_gene_id_json
      gnomad_af_cutoff: gnomad_af_cutoff
      min_n_depth: min_n_depth
      maf_schema: maf_aliquot_schema
      custom_enst:
        source: stage_data/optional_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "custom_enst_uuid");
             return f.length == 0 ? null : f[0];
           }
      cosmic_vcf:
        source: stage_data/optional_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "cosmic_vcf_uuid");
             return f.length == 0 ? null : f[0];
           }
      hotspot_tsv:
        source: stage_data/optional_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "hotspot_tsv_uuid");
             return f.length == 0 ? null : f[0];
           }
      gdc_blacklist:
        source: stage_data/optional_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "gdc_blacklist_uuid");
             return f.length == 0 ? null : f[0];
           }
      gdc_pon_vcf:
        source: stage_data/optional_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "gdc_pon_vcf_uuid");
             return f.length == 0 ? null : f[0];
           }
      nonexonic_intervals:
        source: stage_data/optional_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "nonexonic_intervals_uuid");
             return f.length == 0 ? null : f[0];
           }
      target_intervals:
        source: stage_data/optional_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "target_intervals");
             return f.length == 0 ? null : f;
           }
    out: [ output_maf ]

  upload_aliquot_maf:
    run: ../tools/bioclient_upload_pull_uuid.cwl
    in:
      config-file: bioclient_config
      upload-bucket: upload_bucket
      upload-key:
        source: [ job_uuid, make_aliquot_maf/output_maf ]
        valueFrom: $(self[0] + '/' + self[1].basename)
      input: make_aliquot_maf/output_maf
    out: [ output, uuid ]
