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
  experimental_strategy: string
  aliquot_maf_uuid_list:
    type:
      type: array
      items: ../tools/schemas.cwl#optional_file_uuid
  min_n_depth:
    type: int
    default: 7
  min_callers:
    type: int
    default: 2
  maf_merge_schema:
    type: string
    default: gdc-2.0.0-aliquot-merged
  maf_mask_schema:
    type: string
    default: gdc-2.0.0-aliquot-merged-masked

outputs:
  aliquot_merged_raw_maf_uuid:
    type: string
    outputSource: emit_merged_raw_maf/output
  aliquot_merged_masked_maf_uuid:
    type: string
    outputSource: emit_merged_masked_maf/output
  aliquot_maf_metrics_uuid:
    type: string
    outputSource: emit_maf_metrics/output

steps:
  stage_data:
    run: ./subworkflows/stage_data_workflow.ensemble_mafs.cwl
    in:
      bioclient_config: bioclient_config
      aliquot_maf_uuids: aliquot_maf_uuid_list
    out: [ maf_files ]

  get_file_prefix:
    run: ../tools/make_file_prefix.cwl
    in:
      job_uuid: job_uuid
      experimental_strategy: experimental_strategy
    out: [ output ]

  make_merged_raw_maf:
    run: ../tools/merge_aliquot_mafs.cwl
    in:
      output_filename:
        source: get_file_prefix/output
        valueFrom: $(self + '.aliquot_ensemble_raw.maf.gz')
      min_n_depth: min_n_depth
      maf_schema: maf_merge_schema
      mutect2_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "MuTect2");
             return f.length == 0 ? null : f[0];
           }
      muse_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "MuSE");
             return f.length == 0 ? null : f[0];
           }
      vardict_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "VarDict");
             return f.length == 0 ? null : f[0];
           }
      varscan2_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "VarScan2");
             return f.length == 0 ? null : f[0];
           }
      somaticsniper_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "SomaticSniper");
             return f.length == 0 ? null : f[0];
           }
      pindel_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "Pindel");
             return f.length == 0 ? null : f[0];
           }
      caveman_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "CaVEMan");
             return f.length == 0 ? null : f[0];
           }
      sanger-pindel_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "Sanger Pindel");
             return f.length == 0 ? null : f[0];
           }
      gatk4-mutect2-pair_maf:
        source: stage_data/maf_files
        valueFrom: |
          ${
             var f = lookup_optional_file(self, "GATK4 MuTect2 Pair");
             return f.length == 0 ? null : f[0];
           }

    out: [ output_merged_maf ]

  mask_merged_raw_maf:
    run: ../tools/mask_merged_aliquot_maf.cwl
    in:
      output_stats_filename:
        source: get_file_prefix/output
        valueFrom: $(self + '.aliquot_ensemble_maf_metrics.json')
      input_maf: make_merged_raw_maf/output_merged_maf
      output_filename:
        source: get_file_prefix/output
        valueFrom: $(self + '.aliquot_ensemble_masked.maf.gz')
      min_callers: min_callers
      maf_schema: maf_mask_schema
    out: [ output_masked_merged_maf, output_stats_json ]

  upload_merged_raw_maf:
    run: ../tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [ job_uuid, make_merged_raw_maf/output_merged_maf ]
        valueFrom: $(self[0] + '/' + self[1].basename)
      input: make_merged_raw_maf/output_merged_maf
    out: [ output ]

  upload_merged_masked_maf:
    run: ../tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [ job_uuid, mask_merged_raw_maf/output_masked_merged_maf ]
        valueFrom: $(self[0] + '/' + self[1].basename)
      input: mask_merged_raw_maf/output_masked_merged_maf
    out: [ output ]

  upload_maf_metrics:
    run: ../tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [ job_uuid, mask_merged_raw_maf/output_stats_json ]
        valueFrom: $(self[0] + '/' + self[1].basename)
      input: mask_merged_raw_maf/output_stats_json
    out: [ output ]

  emit_merged_raw_maf:
    run: ../tools/emit_json_value.cwl
    in:
      input: upload_merged_raw_maf/output
      key:
        default: 'did'
    out: [ output ]

  emit_merged_masked_maf:
    run: ../tools/emit_json_value.cwl
    in:
      input: upload_merged_masked_maf/output
      key:
        default: 'did'
    out: [ output ]

  emit_maf_metrics:
    run: ../tools/emit_json_value.cwl
    in:
      input: upload_maf_metrics/output
      key:
        default: 'did'
    out: [ output ]
