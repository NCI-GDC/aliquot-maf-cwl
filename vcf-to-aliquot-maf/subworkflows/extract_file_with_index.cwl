cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  bioclient_config: File
  file_uuid: string
  index_uuid: string

outputs:
  output_indexed_file:
    type: File
    outputSource: make_secondary/output 

steps:
  extract_file:
    run: ../../tools/bioclient_download.cwl
    in:
      config-file: bioclient_config
      download_handle: file_uuid
    out: [ output ]

  extract_index:
    run: ../../tools/bioclient_download.cwl
    in:
      config-file: bioclient_config
      download_handle: index_uuid
    out: [ output ]

  make_secondary:
    run: ../../tools/make_secondary.cwl
    in:
      parent_file: extract_file/output
      children:
        source: extract_index/output
        valueFrom: |
          ${
             var ret = [self];
             return ret
           }
    out: [ output ]
