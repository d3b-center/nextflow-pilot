process GATK4_BASERECALIBRATOR {
    tag "${meta.id}"
    label 'process_low'
    container 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.3.0'

    input:
    tuple val(meta), path(input_bam), path(input_bam_index), path(sequence_interval)
    path(fasta)
    path(fai)
    path(dict)
    path(known_sites)
    path(known_sites_indexes)

    output:
    tuple val(meta), path("*.recal_data.csv"),  emit: recalibration_table

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def interval_command = sequence_interval ? "--intervals $sequence_interval" : ""
    def sites_command = known_sites.collect{"--known-sites $it"}.join(' ') // Use collect to convert a file Channel to a List (value channel) then to a string using join (Groovy)
    def args = task.ext.args ?: ''
    """
    /gatk --java-options "-Xmx${(task.memory.mega*0.8).intValue()}M" \\
        BaseRecalibrator \\
        -R $fasta \\
        -I $input_bam \\
        $interval_command \\
        $sites_command \\
        -O ${prefix}.recal_data.csv \\
        $args
    """

    stub:
    """
    touch test.recal_data.csv
    """
}
