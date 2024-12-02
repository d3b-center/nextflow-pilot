process PICARD_GATHERBAMFILES {
    tag "${meta.id}"
    label 'process_low'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(input_bams), path(input_bam_indexes)

    output:
    tuple val(meta), path("*.bam"), path("*.bai"), emit: merged_bam
    path("*.md5"), emit: bam_md5, optional: true

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def inputs_command = input_bams.collect{"INPUT=$it"}.join(' ')
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        GatherBamFiles \\
        $inputs_command \\
        OUTPUT=${prefix}.bam \\
        $args
    """

    stub:
    """
    touch test.bam
    touch test.bai
    touch test.bam.md5
    """
}
