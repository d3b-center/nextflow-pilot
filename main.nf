#!/usr/bin/env nextflow

include { UNTAR } from './modules/nf-core/untar/main'
include { SAMTOOLS_SPLIT } from './modules/local/samtools/split/main'
include { SAMTOOLS_VIEW_RG } from './modules/local/samtools/view_rg/main'
include { BIOBAMBAM_BAMTOFASTQ } from './modules/local/biobambam/bamtofastq/main'
include { CUTADAPT } from './modules/local/cutadapt/main'
include { BWA_MEM } from './modules/local/bwa/mem/main'
include { SAMBAMBA_MERGE } from './modules/local/sambamba/merge/main'
include { SAMBAMBA_SORT } from './modules/local/sambamba/sort/main'
include { PYTHON_CREATESEQUENCEGROUPS } from './modules/local/python/createsequencegroups/main'
include { GATK4_BASERECALIBRATOR } from './modules/local/gatk/baserecalibrator/main'
include { GATK4_GATHERBQSRREPORTS } from './modules/local/gatk/gatherbqsrreports/main'
include { GATK4_APPLYBQSR } from './modules/local/gatk/applybqsr/main'
include { PICARD_GATHERBAMFILES } from './modules/local/picard/gatherbamfiles/main'
include { PICARD_COLLECTALIGNMENTSUMMARYMETRICS } from './modules/local/picard/collectalignmentsummarymetrics/main'
include { PICARD_COLLECTGCBIASMETRICS } from './modules/local/picard/collectgcbiasmetrics/main'
include { PICARD_COLLECTINSERTSIZEMETRICS } from './modules/local/picard/collectinsertsizemetrics/main'
include { PICARD_COLLECTSEQUENCINGARTIFACTMETRICS } from './modules/local/picard/collectsequencingartifactmetrics/main'
include { PICARD_QUALITYSCOREDISTRIBUTION } from './modules/local/picard/qualityscoredistribution/main'
include { PICARD_COLLECTWGSMETRICS } from './modules/local/picard/collectwgsmetrics/main'
include { PICARD_COLLECTHSMETRICS } from './modules/local/picard/collecthsmetrics/main'
include { SAMTOOLS_IDXSTATS_XY } from './modules/local/samtools/idxstats_xy/main.nf'
include { SAMTOOLS_VIEW_CRAM } from './modules/local/samtools/view_cram/main'
include { VERIFYBAMID } from './modules/local/verifybamid/main'
include { PICARD_INTERVALLISTTOOLS } from './modules/local/picard/intervallisttools/main'
include { GATK4_HAPLOTYPECALLER } from './modules/local/gatk/haplotypecaller/main'
include { PICARD_MERGEVCFS_RENAMESAMPLE } from './modules/local/picard/mergevcfs_renamesample/main'
include { PICARD_COLLECTVARIANTCALLINGMETRICS } from './modules/local/picard/collectvariantcallingmetrics/main'
include { TABIX_TABIX } from './modules/nf-core/tabix/tabix/main.nf'

workflow {
    in_bam = Channel.fromPath(params.in).flatten().map { file -> [["inbam": file.getBaseName()], file] }
    cram_fasta = params.cram_fasta ? Channel.fromPath(params.cram_fasta).first() : Channel.value([])
    reference_tar = Channel.fromPath(params.reference_tar).first()
    knownsites = params.knownsites ? Channel.fromPath(params.knownsites) : Channel.value([])
    knownsites_indexes = params.knownsites_indexes ? Channel.fromPath(params.knownsites_indexes) : Channel.value([])
    coverage_intervallist = params.coverage_intervallist ? Channel.fromPath(params.coverage_intervallist).first() : Channel.value([])
    evaluation_intervallist = params.evaluation_intervallist ? Channel.fromPath(params.evaluation_intervallist).first() : Channel.value([])
    calling_intervallist = params.calling_intervallist ? Channel.fromPath(params.calling_intervallist).first() : Channel.value([])
    contamination_bed = params.contamination_bed ? Channel.fromPath(params.contamination_bed).first() : Channel.value([])
    contamination_mu = params.contamination_mu ? Channel.fromPath(params.contamination_mu).first() : Channel.value([])
    contamination_ud = params.contamination_ud ? Channel.fromPath(params.contamination_ud).first() : Channel.value([])
    dbsnp_vcf = params.dbsnp_vcf ? Channel.fromPath(params.dbsnp_vcf).first() : Channel.value([])
    dbsnp_vcf_index = params.dbsnp_vcf_index ? Channel.fromPath(params.dbsnp_vcf_index).first() : Channel.value([])


    ks = knownsites.map{ file -> [file.fileName.toString(), file]}
    ksi = knownsites_indexes.map{ file -> [file.baseName.toString(), file]}
    knownsite = ks.join(ksi, remainder: true).branch{ _, file, index ->
        indexed: index != null
        unindexed: index == null
    }
    TABIX_TABIX(knownsite.unindexed.map{ meta, file, _ -> [["id": meta], file]})
    knownsites_indexes = TABIX_TABIX.out.tbi.map{ _, file -> file}.concat(knownsites_indexes).collect()
    knownsites = knownsites.collect()

    SAMTOOLS_SPLIT(in_bam, cram_fasta)

    rg_bams = SAMTOOLS_SPLIT.out.rg_bams.transpose().map { meta, file -> [meta + ["rgbam": file.getBaseName(), "single_end": false], file] }

    SAMTOOLS_VIEW_RG(rg_bams)
    BIOBAMBAM_BAMTOFASTQ(rg_bams, cram_fasta)
    rg_fqs = BIOBAMBAM_BAMTOFASTQ.out.fastq

    if (params.cutadapt_r1_adapter || params.cutadapt_r2_adapter || params.cutadapt_min_len || params.cutadapt_quality_base || params.cutadapt_quality_cutoff) {
      CUTADAPT(BIOBAMBAM_BAMTOFASTQ.out.fastq)
      rg_fqs = CUTADAPT.out.reads
    }

    split_rg_fqs = rg_fqs.join(SAMTOOLS_VIEW_RG.out.rg_lines).map { meta, fastq, rgtxt -> [meta + ["rgline": rgtxt.text.trim()], fastq.splitFastq(by: 170_000_000, file: true)] }.transpose()

    if (params.sample) {
        split_rg_fqs = split_rg_fqs.map { meta, file -> meta.rgline = meta.rgline.replaceFirst(/\tSM:\S+\t/, "\tSM:${params.sample}\t"); [meta, file] }
    }

    UNTAR(reference_tar.map{ file -> [[:], file]})
    index_reference = UNTAR.out.untar.map { meta, directory -> directory.listFiles() }
    refs = reference_files.flatten().branch { file ->
        fasta: ["fa","fasta"].contains(file.extension)
        fai: file.extension == "fai"
        dict: file.extension == "dict"
        bwa_refs: ["alt","amb","ann","bwt","pac","sa"].contains(file.extension)
    }
    ref_fasta = refs.fasta.first()
    ref_fai = refs.fai.first()
    ref_dict = refs.dict.first()
    ref_bwa = refs.bwa_refs.collect()

    PYTHON_CREATESEQUENCEGROUPS(ref_dict)

    bwa_mem_payloads = split_rg_fqs.map { meta, file -> meta.id = meta.rgbam; [meta, file, meta.rgline.replaceAll("\t", "\\\\t"), true] }
    BWA_MEM(bwa_mem_payloads, index_reference)

    bams_to_merge = BWA_MEM.out.unsorted_bam.map { meta, file -> [["id": "temp.aligned.duplicates_marked.unsorted"], file] }.groupTuple()
    SAMBAMBA_MERGE(bams_to_merge)

    bam_to_sort = SAMBAMBA_MERGE.out.merged_bam.map { meta, file -> meta.id = "temp.aligned.duplicates_marked.sorted"; [meta, file] }
    SAMBAMBA_SORT(bam_to_sort)

    sequence_intervals = PYTHON_CREATESEQUENCEGROUPS.out.intervals.flatten()
    recal_channel = SAMBAMBA_SORT.out.sorted_bam.combine(sequence_intervals.filter { it.baseName != 'unmapped' }).map{ meta, bam, bai, interval -> [["id": interval.simpleName], bam, bai, interval] }

    GATK4_BASERECALIBRATOR(recal_channel, ref_fasta, ref_fai, ref_dict, knownsites, knownsites_indexes)
    GATK4_GATHERBQSRREPORTS(GATK4_BASERECALIBRATOR.out.recalibration_table.map{ meta, file -> [file] }.collect().map{ file -> [["id": "temp"], file] })

    bqsr_channel = SAMBAMBA_SORT.out.sorted_bam.combine(sequence_intervals).map{ meta, bam, bai, interval -> [["id": interval.simpleName], bam, bai, interval] }
    GATK4_APPLYBQSR(bqsr_channel, ref_fasta, ref_fai, ref_dict, GATK4_GATHERBQSRREPORTS.out.merged_reports.map{ meta, file -> [file] })

    gather_channel = GATK4_APPLYBQSR.out.recalibrated_bam.toSortedList( { a -> a.simpleName } ).map{ file -> [["id": "temp"], file] }.join(GATK4_APPLYBQSR.out.recalibrated_bai.collect().map{ file -> [["id": "temp"], file] })
    PICARD_GATHERBAMFILES(gather_channel)

    SAMTOOLS_VIEW_CRAM(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta)

    PICARD_COLLECTALIGNMENTSUMMARYMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_COLLECTGCBIASMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_COLLECTINSERTSIZEMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_COLLECTSEQUENCINGARTIFACTMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    PICARD_QUALITYSCOREDISTRIBUTION(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai)
    SAMTOOLS_IDXSTATS_XY(PICARD_GATHERBAMFILES.out.merged_bam)
    if (params.wgs_or_wxs == "WXS") {
      PICARD_COLLECTHSMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai, coverage_intervallist, coverage_intervallist)
    } else {
      PICARD_COLLECTWGSMETRICS(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai, coverage_intervallist)
    }

    if (params.precalc_contam) {
      contamination = params.precalc_contam
    } else {
      VERIFYBAMID(PICARD_GATHERBAMFILES.out.merged_bam, ref_fasta, ref_fai, contamination_bed, contamination_mu, contamination_ud)
      contamination = VERIFYBAMID.out.contamination_estimation.map { meta, tsv -> tsv }.splitCsv(header: true, sep: '\t').filter { row -> row.FREEMIX != null }.first().FREEMIX.toFloat() / 0.75
    }

    PICARD_INTERVALLISTTOOLS(calling_intervallist)

    haplotyper_channel = PICARD_GATHERBAMFILES.out.merged_bam.combine(PICARD_INTERVALLISTTOOLS.out.interval_lists.flatten())
    haplotyper_channel = haplotyper_channel.map { meta, bam, bai, interval -> [["id": interval.parent.toString().split('/').last()], bam, bai, interval] }
    GATK4_HAPLOTYPECALLER(haplotyper_channel, ref_fasta, ref_fai, ref_dict, contamination)
    PICARD_MERGEVCFS_RENAMESAMPLE(GATK4_HAPLOTYPECALLER.out.germline_vcf.map { meta, vcf, tbi -> [["id": "temp"], vcf, tbi] }.groupTuple(), params.sample)
    PICARD_COLLECTVARIANTCALLINGMETRICS(PICARD_MERGEVCFS_RENAMESAMPLE.out.merged_vcf, dbsnp_vcf, dbsnp_vcf_index, evaluation_intervallist, ref_dict)
}
