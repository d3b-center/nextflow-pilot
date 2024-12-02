process SAMTOOLS_VIEW_CRAM {
    tag "$meta.id"
    label 'process_low'
    container "pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9"

    input:
    tuple val(meta), path(reads), path(index)
    path(fasta)

    output:
    tuple val(meta), path('*.cram'), emit: cram
    tuple val(meta), path('*.crai'), emit: crai

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reference_command = fasta ? "--reference $fasta" : ''
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    """
    samtools \\
        view \\
        --threads $task.cpus \\
        -C \\
        $reference_command \\
        -o ${prefix}.cram \\
        $args \\
        $reads \\
    && samtools \\
        index \\
        -@ $task.cpus \\
        $args2 \\
        ${prefix}.cram
    """

    stub:
    """
    touch test.cram
    touch test.cram.crai 
    """
}
