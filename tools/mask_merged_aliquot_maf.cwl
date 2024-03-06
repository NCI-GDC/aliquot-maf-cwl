#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/aliquot-maf-tools:{{ aliquot-maf-tools }}"

  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMax: $(size_from_input_object(inputs))
    outdirMax: $(size_from_input_object(inputs))

inputs:
  output_stats_filename:
    type: string
    doc: capture stdout to this json filename

  input_maf:
    type: File
    doc: input raw merged MAF to filter
    inputBinding:
      prefix: --input_maf
      position: 0

  output_filename:
    type: string
    doc: basename of output MAF file
    inputBinding:
      prefix: --output_maf
      position: 1

  maf_schema:
    type: string
    default: gdc-1.0.0-aliquot-merged-masked
    doc: the schema to use for the maf
    inputBinding:
      position: 2

  reference_fasta_index:
    type: File?
    doc: path to the reference fasta fai file if the input MAF is not sorted
    inputBinding:
      prefix: --reference_fasta_index
      position: 3

  min_callers:
    type: int
    default: 2
    doc: minimum number of callers required to keep
    inputBinding:
      prefix: --min_callers
      position: 4
  
  tumor_only:
    type: boolean?
    default: False
    inputBinding:
      prefix: --tumor_only
      position: 5

outputs:
  output_masked_merged_maf:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
  output_stats_json:
    type: stdout

stdout: $(inputs.output_stats_filename)

baseCommand: [MaskMergedAliquotMaf]
