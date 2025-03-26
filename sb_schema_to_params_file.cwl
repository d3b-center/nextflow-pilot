cwlVersion: v1.2
class: CommandLineTool
id: sb_schema_to_params_file
requirements:
-   class: InlineJavascriptRequirement
-   class: ShellCommandRequirement
-   class: ResourceRequirement
    ramMin: 16000
    coresMin: 8
-   class: DockerRequirement
    dockerPull: 'ubuntu:22.04'
-   class: InitialWorkDirRequirement
    listing:
    - entryname: input_params.json
      entry: |
        ${
            var out = {};
            for (var x in inputs) {
                if (inputs[x] === null) {
                    out[x] = '';
                } else if (inputs[x].constructor.name === 'Array') {
                    out[x] = inputs[x].map(function(e) { return (e.class === 'File' ? e.path : e)});
                } else {
                    out[x] = (inputs[x].class === 'File' ? inputs[x].path : inputs[x]);
                }
            }
            return JSON.stringify(out);
        }
baseCommand: [echo, done]
inputs:
-   id: input_bam_list
    type: File[]?
-   id: input_pe_reads_list
    type: File[]?
-   id: input_pe_mates_list
    type: File[]?
-   id: input_pe_rgs_list
    type: string[]?
-   id: input_se_reads_list
    type: File[]?
-   id: input_se_rgs_list
    type: string[]?
-   id: reference_tar
    type: File
    sbg:suggestedValue: {class: File, path: 5f4ffff4e4b0370371c05153, name: Homo_sapiens_assembly38.tgz}
-   id: cram_reference
    type: File?
-   id: biospecimen_name
    type: string?
-   id: output_basename
    type: string
-   id: dbsnp_vcf
    type: File?
    sbg:suggestedValue: {class: File, path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}
-   id: dbsnp_idx
    type: File?
    sbg:suggestedValue: {class: File, path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}
-   id: knownsites
    type: File[]
    sbg:suggestedValue:
    - {class: File, path: 6063901e357c3a53540ca835, name: 1000G_omni2.5.hg38.vcf.gz}
    - {class: File, path: 6063901c357c3a53540ca80f, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz}
    - {class: File, path: 60639017357c3a53540ca7d0, name: Homo_sapiens_assembly38.known_indels.vcf.gz}
    - {class: File, path: 6063901a357c3a53540ca7f3, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz}
-   id: knownsites_indexes
    type: File[]?
    sbg:suggestedValue:
    - {class: File, path: 60639016357c3a53540ca7b1, name: 1000G_omni2.5.hg38.vcf.gz.tbi}
    - {class: File, path: 6063901e357c3a53540ca845, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi}
    - {class: File, path: 6063901c357c3a53540ca80d, name: Homo_sapiens_assembly38.known_indels.vcf.gz.tbi}
    - {class: File, path: 6063901c357c3a53540ca806, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi}
-   id: contamination_sites_bed
    type: File?
    sbg:suggestedValue: {class: File, path: 6063901e357c3a53540ca833, name: Homo_sapiens_assembly38.contam.bed}
-   id: contamination_sites_mu
    type: File?
    sbg:suggestedValue: {class: File, path: 60639017357c3a53540ca7cd, name: Homo_sapiens_assembly38.contam.mu}
-   id: contamination_sites_ud
    type: File?
    sbg:suggestedValue: {class: File, path: 6063901f357c3a53540ca84f, name: Homo_sapiens_assembly38.contam.UD}
-   id: wgs_calling_interval_list
    type: File?
    sbg:suggestedValue: { class: File, path: 60639018357c3a53540ca7df, name: wgs_calling_regions.hg38.interval_list}
-   id: wgs_coverage_interval_list
    type: File?
    sbg:suggestedValue: {class: File, path: 6063901c357c3a53540ca813, name: wgs_coverage_regions.hg38.interval_list}
-   id: wgs_evaluation_interval_list
    type: File?
    sbg:suggestedValue: {class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}
-   id: wxs_bait_interval_list
    type: File?
-   id: wxs_target_interval_list
    type: File?
-   id: hla_dna_ref_seqs
    type: File?
    sbg:suggestedValue: {class: File, path: 6669ac8127374715fc3ba3c4, name: hla_v3.43.0_gencode_v39_dna_seq.fa}
-   id: hla_dna_gene_coords
    sbg:suggestedValue: {class: File, path: 6669ac8127374715fc3ba3c2, name: hla_v3.43.0_gencode_v39_dna_coord.fa}
    type: File?
-   id: t1k_abnormal_unmap_flag
    type: boolean?
-   id: cutadapt_r1_adapter
    type: string?
-   id: cutadapt_r2_adapter
    type: string?
-   id: cutadapt_min_len
    type: int?
-   id: cutadapt_quality_base
    type: int?
-   id: cutadapt_quality_cutoff
    type: string?
-   id: min_alignment_score
    type: int?
-   id: precalculated_contamination
    type: float?
-   id: run_hs_metrics
    type: boolean?
-   id: run_wgs_metrics
    type: boolean?
-   id: run_agg_metrics
    type: boolean?
-   id: run_sex_metrics
    type: boolean?
-   id: run_gvcf_processing
    type: boolean?
-   id: run_t1k
    type: boolean?
-   id: wgs_or_wxs
    type:
    - 'null'
    - name: wgs_or_wxs
      symbols:
      - WGS
      - WXS
      type: enum
outputs:
-   id: params_file
    outputBinding:
      glob: 'input_params.json'
    type: File
