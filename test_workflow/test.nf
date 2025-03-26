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
params.in = ""
params.in2 = ""
params.in3 = ""

/*
 * Define the workflow
 */
workflow {
  f1 = params.in ? Channel.fromPath(params.in).map{ file -> [0, file] } : Channel.empty()
  f2 = params.in2 ? Channel.fromPath(params.in2).map{ file -> [0, file] } : Channel.empty()
  f3 = params.in3 ? Channel.fromPath(params.in3).map{ file -> [0, file] } : Channel.empty()
  ch = f1.concat(f2, f3)
  ch.view()
  ch.groupTuple(sort: true).view()
  // in_se_r = params.input_se_reads_list ? Channel.fromPath(params.input_se_reads_list) : Channel.empty()
  // in_pe_r = Channel.fromPath(params.input_pe_reads_list)
  // in_pe_m = Channel.fromPath(params.input_pe_mates_list)
  // pairs = in_pe_r.merge(in_pe_m)
  // SPLIT_FASTQ_PAIR(pairs.map{ reads, mates -> [["id": reads.name], reads, mates]})
  // SPLIT_FASTQ_PAIR.out.split_reads.join(SPLIT_FASTQ_PAIR.out.split_mates).transpose().view()
  // SPLIT_FASTQ_SOLO(in_se_r.map{ reads -> [["id": reads.name], reads, []]})
  // SPLIT_FASTQ_SOLO.out.split_reads.transpose().view()
}
