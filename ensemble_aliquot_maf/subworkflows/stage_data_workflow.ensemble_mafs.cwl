cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../../tools/schemas.cwl

inputs:
  bioclient_config: File
  aliquot_maf_uuids: 
    type:
      type: array
      items: ../../tools/schemas.cwl#optional_file_uuid

outputs:
  maf_files:
    type:
      type: array
      items: ../../tools/schemas.cwl#optional_file
    outputSource: extract_single_files/output_single_file 

steps:
  extract_single_files:
    run: ./extract_single_optional_file.cwl
    scatter: single_file
    in:
      bioclient_config: bioclient_config
      single_file: aliquot_maf_uuids  
    out: [ output_single_file ]
