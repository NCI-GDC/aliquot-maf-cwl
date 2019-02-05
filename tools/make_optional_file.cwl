cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ./schemas.cwl

class: ExpressionTool

inputs:
  file_key: string
  main_file: File

outputs:
  output: ./schemas.cwl#optional_file
  
expression: |
  ${
     return {"output": {"key": inputs.file_key, "file": inputs.main_file}};
   }
