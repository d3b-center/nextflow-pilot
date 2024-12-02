process PICARD_COLLECTVARIANTCALLINGMETRICS {
    tag "${meta.id}"
    label 'process_single'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(input_vcf), path(input_vcf_index)
    path(dbsnp_vcf)
    path(dbsnp_vcf_index)
    path(target_intervals)
    path(dict)

    output:
    tuple val(meta), path("*_metrics"), emit: vcf_metrics

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        CollectVariantCallingMetrics \\
        THREAD_COUNT=${task.cpus} \\
        INPUT=${input_vcf} \\
        TARGET_INTERVALS=${target_intervals} \\
        DBSNP=${dbsnp_vcf} \\
        SEQUENCE_DICTIONARY=${dict} \\
        OUTPUT=${prefix} \\
        $args
    """

    stub:
    """
    touch test.one_metrics
    touch test.two_metrics
    """
}
