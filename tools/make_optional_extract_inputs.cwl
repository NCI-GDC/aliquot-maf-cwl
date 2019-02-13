cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ./schemas.cwl

class: ExpressionTool

inputs:
  custom_enst_uuid: string?
  dbsnp_priority_db_uuid: string?
  cosmic_vcf_uuid: string?
  cosmic_vcf_index_uuid: string?
  non_tcga_exac_vcf_uuid: string?
  non_tcga_exac_vcf_index_uuid: string?
  hotspot_tsv_uuid: string?
  gdc_blacklist_uuid: string?
  gdc_pon_vcf_uuid: string?
  gdc_pon_vcf_index_uuid: string?
  nonexonic_intervals_uuid: string?
  nonexonic_intervals_index_uuid: string?
  target_intervals_record:
    type:
      type: array
      items: ./schemas.cwl#indexed_file

outputs:
  single_output:
    type:
      type: array
      items: ./schemas.cwl#optional_file_uuid
  indexed_output:
    type:
      type: array
      items: ./schemas.cwl#optional_file_uuid
  
expression: |
  ${
     var single_output = [];
     var indexed_output = [];
     var singles = [
       "custom_enst_uuid", "dbsnp_priority_db_uuid", "hotspot_tsv_uuid", "gdc_blacklist_uuid"
     ];
     var pairs = [
       ["cosmic_vcf_uuid", "cosmic_vcf_index_uuid"],
       ["non_tcga_exac_vcf_uuid", "non_tcga_exac_vcf_index_uuid"],
       ["gdc_pon_vcf_uuid", "gdc_pon_vcf_index_uuid"],
       ["nonexonic_intervals_uuid", "nonexonic_intervals_index_uuid"],
     ];

     for(var i = 0; i<singles.length; i++) {
       var k = singles[i];
       if (inputs[k] != null) {
         single_output.push({"key": k, "uuid": inputs[k], "index_uuid": null}); 
       }
     }

     for(var i = 0; i<pairs.length; i++) {
       var kf = pairs[i][0];
       var ki = pairs[i][1];
       if (inputs[kf] != null) {
         indexed_output.push({"key": kf, "uuid": inputs[kf], "index_uuid": inputs[ki]}); 
       }
     }

     for(var i = 0; i<inputs.target_intervals_record.length; i++) {
       var res = inputs.target_intervals_record[i];
       indexed_output.push({"key": "target_intervals", "uuid": res.main_file_uuid, "index_uuid": res.index_file_uuid}); 
     }

     return {"single_output": single_output, "indexed_output": indexed_output};
   }
