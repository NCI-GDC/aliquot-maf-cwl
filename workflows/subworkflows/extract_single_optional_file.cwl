cwlVersion: v1.0

class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../../tools/schemas/optional_file_uuid.yaml
      - $import: ../../tools/schemas/optional_file.yaml

inputs:
  bioclient_config: File
  single_file: ../../tools/schemas/optional_file_uuid.yaml#optional_file_uuid

outputs:
  output_single_file:
    type: ../../tools/schemas/optional_file.yaml#optional_file
    outputSource: make_optional/output 

steps:
  extract_file:
    run: ../../tools/bioclient_download.cwl
    in:
      config-file: bioclient_config
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
