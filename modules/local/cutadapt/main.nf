process CUTADAPT {
    tag "$meta.id"
    label 'process_medium'

    container "quay.io/biocontainers/cutadapt:4.6--py310h4b81fae_1"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.trim.fastq.gz'), emit: reads
    tuple val(meta), path('*.cutadapt_stats.txt'), emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def interleaved = !meta.single_end && reads.size() == 1 ? "--interleaved" : ''
    """
    cutadapt \\
        -Z \\
        --cores $task.cpus \\
        $args \\
        $interleaved \\
        -o ${prefix}.trim.fastq.gz \\
        $reads \\
        > ${prefix}.cutadapt_stats.txt
    """

    stub:
    """
    touch test.cutadapt_stats.txt
    touch test.trim.fastq.gz
    """
}
