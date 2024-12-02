process SAMTOOLS_VIEW_RG {
    tag "$meta.id"
    label 'process_low'
    container "pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.txt'), emit: rg_lines

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    samtools \\
        view \\
        -@ $task.cpus \\
        -H \\
        $reads \\
        | grep '^@RG' > rgs.txt
    """

    stub:
    """
    touch rgs.txt
    """
}
