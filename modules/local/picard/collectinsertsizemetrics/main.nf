process PICARD_COLLECTINSERTSIZEMETRICS {
    tag "${meta.id}"
    label 'process_single'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("*.insert_size_metrics"), emit: metrics
    tuple val(meta), path("*.insert_size_Histogram.pdf"), emit: histogram

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        CollectInsertSizeMetrics \\
        INPUT=${bam} \\
        OUTPUT=${prefix}.insert_size_metrics \\
        HISTOGRAM_FILE=${prefix}.insert_size_Histogram.pdf \\
        REFERENCE_SEQUENCE=${fasta} \\
        $args
    """

    stub:
    """
    touch test.insert_size_metrics
    touch test.insert_size_Histogram.pdf
    """
}
