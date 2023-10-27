cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../../tools/schemas.cwl

inputs:
  bioclient_config: File
  single_file: ../../tools/schemas.cwl#optional_file_uuid

outputs:
  output_single_file:
    type: ../../tools/schemas.cwl#optional_file
    outputSource: make_optional/output 

steps:
  extract_file:
    run: ../../tools/bioclient_download.cwl
    in:
      config_file: bioclient_config
      download_handle:
        source: single_file
        valueFrom: $(self.uuid) 
    out: [ output ]

  make_optional:
    run: ../../tools/make_optional_file.cwl
    in:
      file_key:
        source: single_file
        valueFrom: $(self.key)
      main_file: extract_file/output
    out: [ output ]
