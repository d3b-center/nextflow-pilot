process SPLIT_FASTQ {
    tag ''
    label 'process_low'

    container 'ubuntu:20.04'

    input:
    tuple val(meta), path(reads), path(mates)

    output:
    tuple val(meta), path("${reads.simpleName}*"), emit: split_reads
    tuple val(meta), path("${mates.simpleName}*"), optional: true, emit: split_mates

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def method = reads.extension == 'gz' ? 'zcat' : 'cat'
    """
    for file in $reads $mates; do
        $method \$file | split \\
        -d \\
        -l 320000000 \\
        --additional-suffix .fastq \\
        $args \\
        - \\
        \${file%f*q*}
    done
    """

    stub:
    """
    touch reads.00.fastq
    touch reads.01.fastq
    touch reads.02.fastq
    """
}
