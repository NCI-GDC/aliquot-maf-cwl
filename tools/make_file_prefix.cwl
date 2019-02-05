cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  project_id:
    type: string?

  caller_id:
    type: string?

  job_uuid:
    type: string

  experimental_strategy:
    type: string

outputs:
  output:
    type: string

expression: |
  ${
     var exp = inputs.experimental_strategy.toLowerCase().replace(/[\-]/g, " ").replace(/\s+/g, '_');
     var pid = inputs.project_id ? inputs.project_id + '.': '';
     var cid = inputs.caller_id ? '.' + inputs.caller_id.replace(/[\-]/g, " ").replace(/\s+/g, '_') : '';
     var pfx = pid + inputs.job_uuid + '.' + exp + cid; 
     return {'output': pfx};
   }
