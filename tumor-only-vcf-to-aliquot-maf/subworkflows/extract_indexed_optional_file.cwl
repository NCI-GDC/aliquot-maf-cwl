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
  indexed_file: ../../tools/schemas.cwl#optional_file_uuid

outputs:
  output_indexed_optional_file:
    type: ../../tools/schemas.cwl#optional_file 
    outputSource: make_optional/output 

steps:
  extract_file:
    run: ./extract_file_with_index.cwl 
    in:
      bioclient_config: bioclient_config
      file_uuid:
        source: indexed_file
        valueFrom: $(self.uuid) 
      index_uuid:
        source: indexed_file
        valueFrom: $(self.index_uuid)
    out: [ output_indexed_file ]

  make_optional:
    run: ../../tools/make_optional_file.cwl
    in:
      file_key:
        source: indexed_file 
        valueFrom: $(self.key)
      main_file: extract_file/output_indexed_file
    out: [ output ]
