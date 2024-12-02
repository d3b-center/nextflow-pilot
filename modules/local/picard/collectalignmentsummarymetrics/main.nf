process PICARD_COLLECTALIGNMENTSUMMARYMETRICS {
    tag "${meta.id}"
    label 'process_single'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("*.alignment_summary_metrics"), emit: metrics

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        CollectAlignmentSummaryMetrics \\
        INPUT=${bam} \\
        REFERENCE_SEQUENCE=${fasta} \\
        OUTPUT=${prefix}.alignment_summary_metrics \\
        $args
    """

    stub:
    """
    touch test.alignment_summary_metrics
    """
}
