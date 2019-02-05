cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: schemas.cwl

class: ExpressionTool

inputs:
  input_a:
    type:
      type: array
      items: schemas.cwl#optional_file

  input_b:
    type:
      type: array
      items: schemas.cwl#optional_file

outputs:
  output:
    type:
      type: array
      items: schemas.cwl#optional_file 

expression: |
  ${
    var output = [];

    for (var i = 0; i < inputs.input_a.length; i++) {
      var curr = inputs.input_a[i];
      output.push(curr);
    }

    for (var i = 0; i < inputs.input_b.length; i++) {
      var curr = inputs.input_b[i];
      output.push(curr);
    }

    return {'output': output}
  }
