process SAMBAMBA_MERGE {
    label 'process_low'
    container "images.sbgenomics.com/bogdang/sambamba:0.6.3"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.bam'), emit: merged_bam

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    /opt/sambamba_0.6.3/sambamba_v0.6.3 merge \\
        -t $task.cpus \\
        $args \\
        ${prefix}.bam \\
        $reads
    """

    stub:
    """
    touch test.bam
    """
}
