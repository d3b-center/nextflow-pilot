#!/usr/bin/env nextflow
// In our image, baseDir is /usr/bin
params.in = "$baseDir/data/sample.fa"

/*
 * Split a fasta file into multiple files
 */
process splitSequences {

    input:
    path 'input.fa'

    output:
    path 'seq_*'

    """
    echo $baseDir
    awk '/^>/{f="seq_"++d} {print > f}' < input.fa
    """
}

/*
 * Reverse the sequences
 */
process reverse {

    input:
    path x

    output:
    stdout

    """
    cat $x | rev
    """
}

/*
 * Define the workflow
 */
workflow {
    splitSequences(params.in) \
      | reverse \
      | view
}