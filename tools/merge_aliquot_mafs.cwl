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
  output_filename:
    type: string
    doc: basename of output MAF file
    inputBinding:
      prefix: --output_maf
      position: 0

  maf_schema:
    type: string
    default: gdc-1.0.0-aliquot-merged
    doc: the schema to use for the maf
    inputBinding:
      position: 1

  mutect2_maf:
    type: File?
    doc: MuTect2 aliquot MAF file
    inputBinding:
      position: 2
      prefix: --mutect2

  muse_maf:
    type: File?
    doc: MuSE aliquot MAF file
    inputBinding:
      position: 3
      prefix: --muse

  vardict_maf:
    type: File?
    doc: VarDict aliquot MAF file
    inputBinding:
      position: 4
      prefix: --vardict

  varscan2_maf:
    type: File?
    doc: VarScan2 aliquot MAF file
    inputBinding:
      position: 5
      prefix: --varscan2

  somaticsniper_maf:
    type: File?
    doc: SomaticSniper aliquot MAF file
    inputBinding:
      position: 6
      prefix: --somaticsniper

  pindel_maf:
    type: File?
    doc: Pindel aliquot MAF file
    inputBinding:
      position: 7
      prefix: --pindel

  caveman_maf:
    type: File?
    doc: CaVEMan aliquot MAF file
    inputBinding:
      position: 8
      prefix: --caveman

  sanger-pindel_maf:
    type: File?
    doc: Sanger Pindel aliquot MAF file
    inputBinding:
      position: 9
      prefix: --sanger-pindel

  gatk4-mutect2-pair_maf:
    type: File?
    doc: GATK4 MuTect2 Pair aliquot MAF file
    inputBinding:
      position: 10
      prefix: --gatk4-mutect2-pair
  
  gatk4-mutect2_maf:
    type: File?
    doc: GATK4 MuTect2 aliquot MAF file
    inputBinding:
      position: 12
      prefix: --gatk4-mutect2

  min_n_depth:
    type: int?
    doc: Min N depth filtering to apply after averaged depths
    inputBinding:
      position: 20
      prefix: --min_n_depth
  
  tumor_only:
    type: boolean?
    doc: Sets tumor-only mode
    inputBinding:
      position: 21
      prefix: --tumor_only

outputs:
  output_merged_maf:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)

baseCommand: [MergeAliquotMafs]
