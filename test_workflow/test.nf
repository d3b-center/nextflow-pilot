#!/usr/bin/env nextflow
// In our image, baseDir is /usr/bin

include { UNTAR } from '../modules/nf-core/untar/main'
include { SPLIT_FASTQ as SPLIT_FASTQ_PAIR } from '../modules/local/split/fastq/main'
include { SPLIT_FASTQ as SPLIT_FASTQ_SOLO } from '../modules/local/split/fastq/main'

params.input_pe_reads_list = ""
params.input_pe_mates_list = ""
params.input_pe_rgs_list = ""
params.input_se_reads_list = ""
params.input_se_rgs_list = ""

/*
 * Define the workflow
 */
workflow {
  ch = Channel.of(1,2,3,4,5)
  ch = ch.branch { v ->
    low: v <= 3
    high: v >= 3
  }
  ch.low.view{ "LOW $it" }
  ch.high.view{ "HIGH $it" }
  // in_se_r = params.input_se_reads_list ? Channel.fromPath(params.input_se_reads_list) : Channel.empty()
  // in_pe_r = Channel.fromPath(params.input_pe_reads_list)
  // in_pe_m = Channel.fromPath(params.input_pe_mates_list)
  // pairs = in_pe_r.merge(in_pe_m)
  // SPLIT_FASTQ_PAIR(pairs.map{ reads, mates -> [["id": reads.name], reads, mates]})
  // SPLIT_FASTQ_PAIR.out.split_reads.join(SPLIT_FASTQ_PAIR.out.split_mates).transpose().view()
  // SPLIT_FASTQ_SOLO(in_se_r.map{ reads -> [["id": reads.name], reads, []]})
  // SPLIT_FASTQ_SOLO.out.split_reads.transpose().view()
}
