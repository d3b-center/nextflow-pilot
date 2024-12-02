process PICARD_COLLECTGCBIASMETRICS {
    tag "${meta.id}"
    label 'process_single'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("*.gc_bias_metrics.txt"), emit: detail_metrics
    tuple val(meta), path("*.gc_bias_summary_metrics.txt"), emit: summary_metrics
    tuple val(meta), path("*.gc_bias_metrics.pdf"), emit: chart

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        CollectGcBiasMetrics \\
        INPUT=${bam} \\
        OUTPUT=${prefix}.gc_bias_metrics.txt \\
        SUMMARY_OUTPUT=${prefix}.gc_bias_summary_metrics.txt \\
        CHART_OUTPUT=${prefix}.gc_bias_metrics.pdf \\
        REFERENCE_SEQUENCE=${fasta} \\
        $args
    """

    stub:
    """
    touch test.gc_bias_metrics.txt
    touch test.gc_bias_summary_metrics.txt
    touch test.gc_bias_metrics.pdf
    """
}
