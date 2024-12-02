process SAMBAMBA_SORT {
    label 'process_low'
    container "images.sbgenomics.com/bogdang/sambamba:0.6.3"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.bam'), path('*.bai'), emit: sorted_bam

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    /opt/sambamba_0.6.3/sambamba_v0.6.3 sort \\
        -t $task.cpus \\
        -m ${task.memory.toGiga()}G \\
        $args \\
        -o ${prefix}.bam \\
        $reads

    mv ${prefix}.bam.bai ${prefix}.bai
    """

    stub:
    """
    touch test.bam
    touch test.bai
    """
}
