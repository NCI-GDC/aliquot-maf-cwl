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
      - $import: ../tools/schemas/optional_file_uuid.yaml

inputs:
  bioclient_config: File
  upload_bucket: string
  job_uuid: string
  experimental_strategy: string
  aliquot_maf_uuid_list:
    type:
      type: array
      items: ../tools/schemas/optional_file_uuid.yaml#optional_file_uuid
  min_n_depth:
    type: int
    default: 7
  min_callers:
    type: int
    default: 2

outputs:
  aliquot_merged_raw_maf_uuid:
    type: string 
    outputSource: upload_merged_raw_maf/uuid
  aliquot_merged_masked_maf_uuid:
    type: string 
    outputSource: upload_merged_masked_maf/uuid
  aliquot_maf_metrics_uuid:
    type: string 
    outputSource: upload_maf_metrics/uuid

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
    out: [ output_masked_merged_maf, output_stats_json ]

  upload_merged_raw_maf:
    run: ../tools/bioclient_upload_pull_uuid.cwl
    in:
      config-file: bioclient_config
      upload-bucket: upload_bucket 
      upload-key:
        source: [ job_uuid, make_merged_raw_maf/output_merged_maf ]
        valueFrom: $(self[0] + '/' + self[1].basename)
      input: make_merged_raw_maf/output_merged_maf 
    out: [ output, uuid ]

  upload_merged_masked_maf:
    run: ../tools/bioclient_upload_pull_uuid.cwl
    in:
      config-file: bioclient_config
      upload-bucket: upload_bucket 
      upload-key:
        source: [ job_uuid, mask_merged_raw_maf/output_masked_merged_maf ]
        valueFrom: $(self[0] + '/' + self[1].basename)
      input: mask_merged_raw_maf/output_masked_merged_maf 
    out: [ output, uuid ]

  upload_maf_metrics:
    run: ../tools/bioclient_upload_pull_uuid.cwl
    in:
      config-file: bioclient_config
      upload-bucket: upload_bucket 
      upload-key:
        source: [ job_uuid, mask_merged_raw_maf/output_stats_json ]
        valueFrom: $(self[0] + '/' + self[1].basename)
      input: mask_merged_raw_maf/output_stats_json
    out: [ output, uuid ]
