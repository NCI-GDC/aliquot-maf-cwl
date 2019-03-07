#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/aliquot-maf-tools:6f3666bc0b1b758fa5df33e2048bcaf8af800d99
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

outputs:
  output_masked_merged_maf:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)

baseCommand: [/usr/local/bin/aliquot-maf-tools, MaskMergedAliquotMaf]
