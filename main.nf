#!/usr/bin/env nextflow

include { GATK4_INDEXFEATUREFILE } from './modules/nf-core/gatk4/indexfeaturefile/main'
include { UNTAR } from './modules/nf-core/untar/main'
include { SAMTOOLS_SPLIT } from './modules/local/samtools/split/main'
include { SAMTOOLS_VIEW as SAMTOOLS_VIEW_RG } from './modules/nf-core/samtools/view/main'
include { BIOBAMBAM_BAMTOFASTQ } from './modules/local/biobambam/bamtofastq/main'
include { CUTADAPT as CUTADAPT_INTERLEAVE_PEFQ  } from './modules/nf-core/cutadapt/main'
include { CUTADAPT as CUTADAPT_SINGLE } from './modules/nf-core/cutadapt/main'
include { CUTADAPT as CUTADAPT_PAIRED } from './modules/nf-core/cutadapt/main'
include { SPLIT_FASTQ } from './modules/local/split/fastq/main'
include { BWA_MEM } from './modules/local/bwa/mem/main'
include { SAMBAMBA_MERGE } from './modules/local/sambamba/merge/main'
include { PYTHON_CREATESEQUENCEGROUPS } from './modules/local/python/createsequencegroups/main'
include { GATK4_BASERECALIBRATOR } from './modules/nf-core/gatk4/baserecalibrator/main'
include { GATK4_GATHERBQSRREPORTS } from './modules/nf-core/gatk4/gatherbqsrreports/main'
include { GATK4_APPLYBQSR } from './modules/nf-core/gatk4/applybqsr/main'
include { PICARD_GATHERBAMFILES } from './modules/local/picard/gatherbamfiles/main'
include { PICARD_COLLECTALIGNMENTSUMMARYMETRICS } from './modules/local/picard/collectalignmentsummarymetrics/main'
include { PICARD_COLLECTGCBIASMETRICS } from './modules/local/picard/collectgcbiasmetrics/main'
include { PICARD_COLLECTINSERTSIZEMETRICS } from './modules/local/picard/collectinsertsizemetrics/main'
include { PICARD_COLLECTSEQUENCINGARTIFACTMETRICS } from './modules/local/picard/collectsequencingartifactmetrics/main'
include { PICARD_QUALITYSCOREDISTRIBUTION } from './modules/local/picard/qualityscoredistribution/main'
include { PICARD_COLLECTWGSMETRICS } from './modules/local/picard/collectwgsmetrics/main'
include { PICARD_COLLECTHSMETRICS } from './modules/local/picard/collecthsmetrics/main'
include { SAMTOOLS_IDXSTATS } from './modules/nf-core/samtools/idxstats/main'
include { SAMTOOLS_IDXSTATS_XY } from './modules/local/samtools/idxstats_xy/main'
include { SAMTOOLS_VIEW as SAMTOOLS_VIEW_CRAM } from './modules/nf-core/samtools/view/main'
include { VERIFYBAMID_VERIFYBAMID2 } from './modules/nf-core/verifybamid/verifybamid2/main'
include { GATK4_INTERVALLISTTOOLS } from './modules/nf-core/gatk4/intervallisttools/main'
include { GATK4_HAPLOTYPECALLER } from './modules/local/gatk/haplotypecaller/main'
include { PICARD_MERGEVCFS_RENAMESAMPLE } from './modules/local/picard/mergevcfs_renamesample/main'
include { GATK4_MERGEVCFS } from './modules/nf-core/gatk4/mergevcfs/main'
include { PICARD_RENAMESAMPLEINVCF } from './modules/nf-core/picard/renamesampleinvcf/main'
include { PICARD_COLLECTVARIANTCALLINGMETRICS } from './modules/local/picard/collectvariantcallingmetrics/main'
include { TABIX_TABIX } from './modules/nf-core/tabix/tabix/main'
include { TABIX_TABIX as TABIX_TABIX_GVCF } from './modules/nf-core/tabix/tabix/main'

workflow {
    input_aligned_reads = params.input_bam_list ? Channel.fromPath(params.input_bam_list.class == String ? params.input_bam_list.split(',') as List : params.input_bam_list).map { file -> [["inbam": file.getBaseName()], file] } : Channel.empty()
    input_pe_reads = params.input_pe_reads_list ? Channel.fromPath(params.input_pe_reads_list.class == String ? params.input_pe_reads_list.split(',') as List : params.input_pe_reads_list) : Channel.empty()
    input_pe_mates = params.input_pe_mates_list ? Channel.fromPath(params.input_pe_mates_list.class == String ? params.input_pe_mates_list.split(',') as List : params.input_pe_mates_list) : Channel.empty()
    input_pe_rgs = params.input_pe_rgs_list ? Channel.fromList(params.input_pe_rgs_list.class == String ? params.input_pe_rgs_list.split(',') as List : params.input_pe_rgs_list) : Channel.empty()
    input_pe_rgs.view{ "INPUT PE RG: $it" }
    input_se_reads = params.input_se_reads_list ? Channel.fromPath(params.input_se_reads_list.class == String ? params.input_se_reads_list.split(',') as List : params.input_se_reads_list) : Channel.empty()
    input_se_rgs = params.input_se_rgs_list ? Channel.fromList(params.input_se_rgs_list.class == String ? params.input_se_rgs_list.split(',') as List : params.input_se_rgs_list) : Channel.empty()
    input_se_rgs.view{ "INPUT SE RG: $it" }
    cram_reference = params.cram_reference ? Channel.fromPath(params.cram_reference).first() : Channel.value([])
    reference_tar = Channel.fromPath(params.reference_tar).first()
    knownsites = params.knownsites ? Channel.fromPath(params.knownsites.class == String ? params.knownsites.split(',') as List : params.knownsites) : Channel.value([])
    knownsites_indexes = params.knownsites_indexes ? Channel.fromPath(params.knownsites_indexes.class == String ? params.knownsites_indexes.split(',') as List : params.knownsites_indexes) : Channel.value([])
    coverage_intervallist = params.wgs_coverage_interval_list ? Channel.fromPath(params.wgs_coverage_interval_list).first() : Channel.value([])
    evaluation_intervallist = params.wgs_evaluation_interval_list ? Channel.fromPath(params.wgs_evaluation_interval_list).first() : Channel.value([])
    calling_intervallist = params.wgs_calling_interval_list ? Channel.fromPath(params.wgs_calling_interval_list).first() : Channel.value([])
    bait_intervallist = params.wxs_bait_interval_list ? Channel.fromPath(params.wxs_bait_interval_list).first() : Channel.value([])
    target_intervallist = params.wxs_target_interval_list ? Channel.fromPath(params.wxs_target_interval_list).first() : Channel.value([])
    contamination_bed = params.contamination_sites_bed ? Channel.fromPath(params.contamination_sites_bed).first() : Channel.value([])
    contamination_mu = params.contamination_sites_mu ? Channel.fromPath(params.contamination_sites_mu).first() : Channel.value([])
    contamination_ud = params.contamination_sites_ud ? Channel.fromPath(params.contamination_sites_ud).first() : Channel.value([])
    dbsnp_vcf = params.dbsnp_vcf ? Channel.fromPath(params.dbsnp_vcf).first() : Channel.value([])

    // Housekeeping for References
    if (params.dbsnp_idx) {
        dbsnp_idx = Channel.fromPath(params.dbsnp_idx).first()
    } else {
        GATK4_INDEXFEATUREFILE(dbsnp_vcf.map{ file -> [["id": file.baseName], file] })
        dbsnp_idx = GATK4_INDEXFEATUREFILE.out.index.map{ _, file -> file }
    }

    svds = contamination_ud.combine(contamination_mu).combine(contamination_bed)

    ks = knownsites.map{ file -> [file.fileName.toString(), file]}
    ksi = knownsites_indexes.map{ file -> [file.baseName.toString(), file]}
    knownsite = ks.join(ksi, remainder: true).branch{ _, file, index ->
        indexed: index != null
        unindexed: index == null
    }
    TABIX_TABIX(knownsite.unindexed.map{ meta, file, _ -> [["id": meta], file]})
    knownsites_indexes = TABIX_TABIX.out.tbi.map{ _, file -> file}.concat(knownsites_indexes).collect()
    knownsites = knownsites.collect()

    UNTAR(reference_tar.map{ file -> [[:], file]})
    untarred_files = UNTAR.out.untar.map { meta, directory -> directory.listFiles() }
    refs = untarred_files.flatten().branch { file ->
        fasta: ["fa","fasta"].contains(file.extension)
        fai: file.extension == "fai"
        dict: file.extension == "dict"
        bwa_refs: ["alt","amb","ann","bwt","pac","sa"].contains(file.extension)
    }
    ref_fasta = refs.fasta.first()
    ref_fai = refs.fai.first()
    ref_dict = refs.dict.first()
    ref_bwa = refs.bwa_refs.collect()
    indexed_fasta = ref_fasta.concat(ref_fai, ref_dict, ref_bwa).collect()

    PYTHON_CREATESEQUENCEGROUPS(ref_dict)
    sequence_intervals = PYTHON_CREATESEQUENCEGROUPS.out.intervals.flatten()

    // Prepare Reads for BWA
    se_fastq = input_se_rgs.merge(input_se_reads). map { rg, read -> [["id": rg.replaceAll('\\\\t','\t').split('\t').find{ it.startsWith('ID') }.replaceFirst('ID:', ""), "rgline": rg, "single_end": true, "interleaved": false], read] }.branch{ ch ->
        trim: (params.cutadapt_r1_adapter || params.cutadapt_quality_base || params.cutadapt_quality_cutoff)
        pass: true
    }
    CUTADAPT_SINGLE(se_fastq.trim)

    pe_fastq = input_pe_rgs.merge(input_pe_reads, input_pe_mates).map { rg, read, mate -> [["id": rg.replaceAll('\\\\t','\t').split('\t').find{ it.startsWith('ID') }.replaceFirst('ID:', ""), "rgline": rg, "single_end": false, "interleaved": false], [read, mate]] }
    pe_fastq = pe_fastq.branch { meta, files ->
        trim: (params.cutadapt_r1_adapter || params.cutadapt_r2_adapter || params.cutadapt_quality_base || params.cutadapt_quality_cutoff)
        pass: true
    }
    CUTADAPT_INTERLEAVE_PEFQ(pe_fastq.pass.map{ meta, files -> [meta + ["single_end": true, "interleaved": true], files] })

    SAMTOOLS_SPLIT(input_aligned_reads, cram_reference)

    rg_bams = SAMTOOLS_SPLIT.out.rg_bams.transpose().map { meta, file -> [meta + ["id": file.baseName, "single_end": false, "interleaved": true], file] }
    SAMTOOLS_VIEW_RG(rg_bams.map{ meta, file -> [meta, file, []]}, Channel.value([[],[]]), Channel.value([]))
    // Each file should only have one RG. Use find to get the first @RG line from the header
    rg_lines = SAMTOOLS_VIEW_RG.out.sam.map{ meta, file -> [meta, file.readLines().find{ it.startsWith("@RG") }]}

    BIOBAMBAM_BAMTOFASTQ(rg_bams, cram_reference)
    rg_fqs = BIOBAMBAM_BAMTOFASTQ.out.fastq.join(rg_lines).map{ meta, file, rgtxt -> [meta + ["rgline": rgtxt], file] }.branch{ ch ->
        trim: (params.cutadapt_r1_adapter || params.cutadapt_r2_adapter || params.cutadapt_quality_base || params.cutadapt_quality_cutoff)
        pass: true
    }

    CUTADAPT_PAIRED(pe_fastq.trim.concat(rg_fqs.trim).map{ meta , files -> [meta + ["single_end": true], files] })

    fastq_channel = Channel.empty()
    fastq_channel = fastq_channel.mix(se_fastq.pass)
    fastq_channel = fastq_channel.mix(rg_fqs.pass)
    fastq_channel = fastq_channel.mix(CUTADAPT_SINGLE.out.reads)
    fastq_channel = fastq_channel.mix(CUTADAPT_INTERLEAVE_PEFQ.out.reads.map{ meta, file -> [meta + ["single_end": false], file] })
    fastq_channel = fastq_channel.mix(CUTADAPT_PAIRED.out.reads.map{ meta, file -> [meta + ["single_end": false], file] })

    fastq_channel = fastq_channel.branch{ meta, file ->
        split: file.size() > 10000000000
        pass: true
    }

    SPLIT_FASTQ(fastq_channel.split.map{ meta, reads -> [meta, reads, []]})

    fq_align_channel = Channel.empty()
    fq_align_channel = fq_align_channel.mix(fastq_channel.pass)
    fq_align_channel = fq_align_channel.mix(SPLIT_FASTQ.out.split_reads.transpose())

    if (params.biospecimen_name) {
        fq_align_channel = fq_align_channel.map { meta, file -> [meta + ["rgline": meta.rgline.replaceFirst(/\tSM:\S+\t/, "\tSM:${params.biospecimen_name}\t")], file] }
    }

    bwa_mem_payloads = fq_align_channel.map { meta, file -> [meta + ["id": file.baseName], file, meta.rgline.replaceAll("\t", "\\\\t"), meta.interleaved] }
    BWA_MEM(bwa_mem_payloads, indexed_fasta)

    bams_to_merge = BWA_MEM.out.aligned_bam.map { meta, file -> [["id": "temp.aligned.duplicates_marked.sorted"], file] }.groupTuple()
    SAMBAMBA_MERGE(bams_to_merge)

    recal_channel = SAMBAMBA_MERGE.out.merged_bam.combine(sequence_intervals.filter { it.baseName != 'unmapped' }).map{ meta, bam, bai, interval -> [["id": interval.simpleName], bam, bai, interval] }

    GATK4_BASERECALIBRATOR(recal_channel, ref_fasta.map{ file -> [[:], file]}, ref_fai.map{ file -> [[:], file]}, ref_dict.map{ file -> [[:], file]}, knownsites.map{ file -> [[:], file]}, knownsites_indexes.map{ file -> [[:], file]})
    GATK4_GATHERBQSRREPORTS(GATK4_BASERECALIBRATOR.out.table.map{ meta, file -> [file] }.collect().map{ file -> [["id": "temp"], file] })

    bqsr_channel = SAMBAMBA_MERGE.out.merged_bam.combine(GATK4_GATHERBQSRREPORTS.out.table.map{ meta, file -> file }).combine(sequence_intervals).map{ meta, bam, bai, bqsr, interval -> [["id": interval.simpleName], bam, bai, bqsr, interval] }

    GATK4_APPLYBQSR(bqsr_channel, ref_fasta, ref_fai, ref_dict)
    gather_channel = GATK4_APPLYBQSR.out.bam.map{ _, file -> file }.toSortedList{ a -> a.simpleName }.map{ files -> [["id": "temp"], files] }

    PICARD_GATHERBAMFILES(gather_channel)

    SAMTOOLS_VIEW_CRAM(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta.map{ file -> [[:], file]}, Channel.value([]))

    PICARD_COLLECTALIGNMENTSUMMARYMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_COLLECTGCBIASMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_COLLECTINSERTSIZEMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_COLLECTSEQUENCINGARTIFACTMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_QUALITYSCOREDISTRIBUTION(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)

    SAMTOOLS_IDXSTATS_XY(PICARD_GATHERBAMFILES.out.merged_bam)
    // The below approach works on local but not CAVATICA
    // SAMTOOLS_IDXSTATS(PICARD_GATHERBAMFILES.out.merged_bam)
    // idxstats_rows = SAMTOOLS_IDXSTATS.out.idxstats.map{ _, file -> file }.splitCsv(sep: '\t', header: ['seqName', 'seqLen', 'readsMapped', 'readsUnmapped'])
    // xy_info = idxstats_rows.filter{ row -> row.seqName == 'chrX' || row.seqName == 'chrY' }.map{ row -> [row.readsMapped.toInteger(), row.readsMapped.toInteger() / row.seqLen.toInteger()] }.collect()
    // xy_ratios = xy_info.map{ xreads, xrat, yreads, yrat -> ["Y_reads_fraction " + yreads/(xreads + yreads), "X:Y_ratio " + xrat/yrat, "X_norm_reads $xrat", "Y_norm_reads $yrat", "Y_norm_reads_fraction " + yrat/(xrat+yrat)]}
    // xy_ratios.flatten().collectFile(name: "${params.output_basename}.ratio.txt", storeDir: "${params.outdir}/metrics/", newLine: true)

    PICARD_COLLECTHSMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai, bait_intervallist, target_intervallist)
    PICARD_COLLECTWGSMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai, coverage_intervallist)

    if (params.precalculated_contamination) {
      contamination = Channel.value(params.precalculated_contamination)
    } else {
      VERIFYBAMID_VERIFYBAMID2(PICARD_GATHERBAMFILES.out.merged_bam, svds, Channel.value([]), ref_fasta)
      contamination = VERIFYBAMID_VERIFYBAMID2.out.self_sm.map { meta, tsv -> tsv }.splitCsv(header: true, sep: '\t').filter { row -> row.'FREEMIX(alpha)' != null }.first().map { v -> v.'FREEMIX(alpha)'.toFloat() / 0.75 }
    }

    GATK4_INTERVALLISTTOOLS(calling_intervallist.map{ file -> [["id":"wgs_calling"], file]})

    haplotyper_channel = PICARD_GATHERBAMFILES.out.merged_bam.combine(GATK4_INTERVALLISTTOOLS.out.interval_list.map{ _, files -> files }.flatten())
    haplotyper_channel = haplotyper_channel.map { meta, bam, bai, interval -> [["id": interval.parent.toString().split('/').last()], bam, bai, interval] }
    GATK4_HAPLOTYPECALLER(haplotyper_channel, ref_fasta, ref_fai, ref_dict, contamination)
    GATK4_MERGEVCFS(GATK4_HAPLOTYPECALLER.out.germline_vcf.map { meta, vcf, tbi -> [["id": "temp"], vcf] }.groupTuple(), Channel.value([[],[]]))
    if (params.biospecimen_name) {
        PICARD_RENAMESAMPLEINVCF(GATK4_MERGEVCFS.out.vcf.map { meta, file -> [["id": params.biospecimen_name], file] })
        TABIX_TABIX_GVCF(PICARD_RENAMESAMPLEINVCF.out.vcf)
        PICARD_COLLECTVARIANTCALLINGMETRICS(PICARD_RENAMESAMPLEINVCF.out.vcf.join(TABIX_TABIX_GVCF.out.tbi), dbsnp_vcf, dbsnp_idx, evaluation_intervallist, ref_dict)
    } else {
        PICARD_COLLECTVARIANTCALLINGMETRICS(GATK4_MERGEVCFS.out.vcf.join(GATK4_MERGEVCFS.out.tbi), dbsnp_vcf, dbsnp_idx, evaluation_intervallist, ref_dict)
    }
}
