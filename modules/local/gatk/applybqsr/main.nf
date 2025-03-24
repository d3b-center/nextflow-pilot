process GATK4_APPLYBQSR {
    tag "${meta.id}"
    label 'process_low'
    container 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.3.0'

    input:
    tuple val(meta), path(input_bam), path(input_bam_index), path(bqsr_report), path(sequence_interval)
    path(fasta)
    path(fai)
    path(dict)

    output:
    path("*.bam"), emit: bam
    path("*.bai"), emit: bai
    path("*.md5"), emit: md5, optional: true

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def interval_command = sequence_interval ? "--intervals $sequence_interval" : ""
    def args = task.ext.args ?: ''
    """
    /gatk --java-options "-Xmx${(task.memory.mega*0.8).intValue()}M" \\
        ApplyBQSR \\
        -R $fasta \\
        -I $input_bam \\
        -O ${prefix}.aligned.duplicates_marked.recalibrated.bam \\
        -bqsr $bqsr_report \\
        $interval_command \\
        $args
    """

    stub:
    """
    touch recalibrated.bam
    touch recalibrated.bai
    touch recalibrated.md5
    """
}
