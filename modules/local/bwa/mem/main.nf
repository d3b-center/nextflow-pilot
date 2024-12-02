process BWA_MEM {
    label 'process_high'
    container "pgc-images.sbgenomics.com/d3b-bixu/bwa-kf-bundle:0.1.17"

    input:
    tuple val(meta), path(reads), val(rgline), val(interleaved)
    path(fasta)

    output:
    tuple val(meta), path('*.bam'), emit: unsorted_bam

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def interleaved_command = interleaved ? '-p' : ''
    def rgline_command = rgline ? "-R '${rgline}'" : ''
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def args4 = task.ext.args4 ?: ''
    """
    INDEX=`find -L ./ -name "*.amb" | sed 's/\\.64\\.amb\$//'`

    bwa mem \\
        -t $task.cpus \\
        $interleaved_command \\
        $rgline_command \\
        $args \\
        \$INDEX \\
        $reads \\
    | /opt/samblaster/samblaster \\
        -i /dev/stdin \\
        -o /dev/stdout \\
        $args2 \\
    | /opt/sambamba_0.6.3/sambamba_v0.6.3 view \\
        -t $task.cpus \\
        $args3 \\
        /dev/stdin \\
    | /opt/sambamba_0.6.3/sambamba_v0.6.3 sort \\
        -t $task.cpus \\
        -m ${Math.floor(task.memory.toGiga() / 4) as int}GiB \\
        -o ${prefix}.unsorted.bam \\
        $args4 \\
        /dev/stdin
    """

    stub:
    """
    touch test.bam
    """
}
