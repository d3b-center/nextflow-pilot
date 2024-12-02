process PICARD_COLLECTWGSMETRICS {
    tag "${meta.id}"
    label 'process_single'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)
    path(intervallist)

    output:
    tuple val(meta), path("*.wgs_metrics"), emit: metrics

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        CollectWgsMetrics \\
        INPUT=${bam} \\
        OUTPUT=${prefix}.wgs_metrics \\
        REFERENCE_SEQUENCE=${fasta} \\
        INTERVALS=${intervallist} \\
        $args
    """

    stub:
    """
    touch test.wgs_metrics
    """
}
