process PICARD_COLLECTHSMETRICS {
    tag "${meta.id}"
    label 'process_single'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)
    path(bait_intervals)
    path(target_intervals)

    output:
    tuple val(meta), path("*.hs_metrics"), emit: metrics

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        CollectHsMetrics \\
        INPUT=${bam} \\
        REFERENCE_SEQUENCE=${fasta} \\
        BAIT_INTERVALS=${bait_intervals} \\
        TARGET_INTERVALS=${target_intervals} \\
        OUTPUT=${prefix}.hs_metrics \\
	$args
    """

    stub:
    """
    touch test.hs_metrics
    """
}
