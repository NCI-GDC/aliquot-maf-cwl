cwlVersion: v1.0

requirements:
  InlineJavascriptRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ./schemas/optional_file.yaml

class: ExpressionTool

inputs:
  file_key: string
  main_file: File

outputs:
  output: ./schemas/optional_file.yaml#optional_file
  
expression: |
  ${
     return {"output": {"key": inputs.file_key, "file": inputs.main_file}};
   }
