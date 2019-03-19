# aliquot-maf-cwl
CWL tools and workflows for generating and processing aliquot-MAF

## Convert annotated VCF to an aliquot MAF

Workflow: `workflows/vcf_to_aliquot_maf_wf.cwl`

**Inputs**

| Input | Type | Description |
| ----- | ---- | ----------- |
| annotated_vcf_uuid | uuid | input vcf uuid |
| annotated_vcf_index_uuid | uuid | input vcf index uuid |
| bioclient_config | file | bioclient config file |
| biotype_priority_uuid | uuid | biotype priority json uuid |
| caller_id | string | variant caller id |
| case_uuid | uuid | case uuid |
| context_size | int | reference context size (_5_) |
| cosmic_vcf_uuid | uuid | cosmic vcf uuid |
| cosmic_vcf_index_uuid | uuid | cosmic vcf index uuid|
| custom_enst_uuid | uuid | custom transcript overloads file uuid |
| dbsnp_priority_db_uuid | uuid | dbSNP priority sqlite uuid |
| effect_priority_uuid | uuid | effect prioty json uuid |
| exac_freq_cutoff | float | non-tcga exac frequency filter cutoff (_0.001_) |
| experimental_strategy | string | experimental strategy |
| gdc_blacklist_uuid | uuid | blacklist uuid if doing blacklist filter |
| gdc_pon_vcf_uuid | uuid | panel of normals vcf uuid |
| gdc_pon_vcf_index_uuid | uuid | panel of normals vcf index uuid |
| hotspot_tsv_uuid | uuid | hotspot tsv uuid |
| job_uuid | uuid | uuid of the workflow job |
| maf_center | string[] | list of sequencing centers |
| min_n_depth | int | normal depth filtering cutoff (_7_) |
| non_tcga_exac_vcf_uuid | uuid | Non-TCGA ExAC vcf uuid |
| non_tcga_exac_vcf_index_uuid | uuid | Non-TCGA ExAC vcf index uuid |
| nonexonic_intervals_uuid | uuid | Exonic regions bed uuid|
| nonexonic_intervals_index_uuid | uuid | Exonic regions bed tabix index uuid |
| normal_aliquot_uuid | uuid | normal aliquot uuid |
| normal_bam_uuid | uuid | normal sample's bam uuid |
| normal_submitter_id | string | normal aliquot's submitted id |
| reference_fasta_index_uuid | uuid | main chromosome reference fai uuid |
| reference_fasta_uuid | uuid | main chromosome reference fasta uuid |
| sequencer | string[] | list of sequencers used |
| target_intervals_record | indexed_file[]| list of targeted sequencing `indexed_file` objects |
| tumor_aliquot_uuid | uuid | tumor aliquot uuid |
| tumor_bam_uuid | uuid | tumor aliquot's bam uuid |
| tumor_submitter_id | string | tumor aliquot's submitter id |
| upload_bucket | string | upload bucket uri |

An `indexed_file` object id defined as:

```
{
  "main_file_uuid": "<UUID>",
  "index_file_uuid": "<UUID>"
}
```

**Outputs**

* `aliquot_maf_uuid` - the UUID of the generated aliquot MAF file

## Aggregate/merge aliquot MAF from different callers

Workflow: `workflows/ensemble_aliquot_maf_wf.cwl`

**Inputs**

| Input | Type | Description |
| ----- | ---- | ----------- |
| aliquot_maf_uuid_list | optional_file_uuid[] | input list of `optional_file_uuid` objects |
| bioclient_config | file | bioclient config file |
| experimental_strategy | string | experimental strategy |
| job_uuid | uuid | uuid of the workflow job |
| min_callers | int | minimum number of callers supporting the variant for masked merged maf file (_2_) |
| min_n_depth | float | minimal Normal depth cutoff after averaging (_7_) |
| upload_bucket | string | upload bucket uri |

An `optional_file_uuid` object
