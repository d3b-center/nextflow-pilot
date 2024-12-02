process SAMTOOLS_SPLIT {
    tag "$meta.id"
    label 'process_low'
    container "pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9"

    input:
    tuple val(meta), path(reads)
    path(fasta)

    output:
    tuple val(meta), path('*.bam'), emit: rg_bams

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def reference_command = fasta ? "--reference $fasta" : ''
    """
    samtools \\
        split \\
        -@ $task.cpus \\
        $reference_command \\
        $args \\
        $reads
    """

    stub:
    """
    touch a.bam
    touch b.bam
    touch c.bam
    """
}
