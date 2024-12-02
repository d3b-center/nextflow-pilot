process PICARD_QUALITYSCOREDISTRIBUTION {
    tag "${meta.id}"
    label 'process_low'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("*.qual_score_dist.txt"), emit: metrics
    tuple val(meta), path("*.qual_score_dist.pdf"), emit: chart

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        QualityScoreDistribution \\
        INPUT=${bam} \\
        OUTPUT=${prefix}.qual_score_dist.txt \\
        CHART_OUTPUT=${prefix}.qual_score_dist.pdf \\
        $args
    """

    stub:
    """
    touch test.qual_score_dist.txt
    touch test.qual_score_dist.pdf
    """
}
