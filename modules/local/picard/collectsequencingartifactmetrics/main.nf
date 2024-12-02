process PICARD_COLLECTSEQUENCINGARTIFACTMETRICS {
    tag "${meta.id}"
    label 'process_single'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("*.bait_bias_detail_metrics"), emit: bait_bias_detail_metrics
    tuple val(meta), path("*.bait_bias_summary_metrics"), emit: bait_bias_summary_metrics
    tuple val(meta), path("*.error_summary_metrics"), emit: error_summary_metrics
    tuple val(meta), path("*.pre_adapter_detail_metrics"), emit: pre_adapter_detail_metrics
    tuple val(meta), path("*.pre_adapter_summary_metrics"), emit: pre_adapter_summary_metrics

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        CollectSequencingArtifactMetrics \\
        INPUT=${bam} \\
        OUTPUT=${prefix}.artifact_metrics \\
        REFERENCE_SEQUENCE=${fasta} \\
        $args
    """

    stub:
    """
    touch test.bait_bias_detail_metrics
    touch test.bait_bias_summary_metrics
    touch test.error_summary_metrics
    touch test.pre_adapter_detail_metrics
    touch test.pre_adapter_summary_metrics
    """
}
