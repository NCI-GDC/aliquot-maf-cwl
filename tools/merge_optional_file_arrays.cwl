cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ./schemas/optional_file.yaml

class: ExpressionTool

inputs:
  input_a:
    type:
      type: array
      items: ./schemas/optional_file.yaml#optional_file

  input_b:
    type:
      type: array
      items: ./schemas/optional_file.yaml#optional_file

outputs:
  output:
    type:
      type: array
      items: schemas/optional_file.yaml#optional_file 

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
