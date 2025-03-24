process SPLIT_FASTQ {
    tag ''
    label 'process_low'

    container 'ubuntu:20.04'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq"), emit: split_reads

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def method = reads.extension == 'gz' ? 'zcat' : 'cat'
    def output = reads.name.replaceAll(/f(ast)?q(.gz)?$/,"")
    """
    $method $reads | split \\
    -d \\
    -l 160000000 \\
    --additional-suffix .fastq \\
    $args \\
    - \\
    $output
    """

    stub:
    """
    touch reads.00.fastq
    touch reads.01.fastq
    touch reads.02.fastq
    """
}
