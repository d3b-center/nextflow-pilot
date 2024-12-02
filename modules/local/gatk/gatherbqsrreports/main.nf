process GATK4_GATHERBQSRREPORTS {
    tag "${meta.id}"
    label 'process_medium'
    container 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.3.0'

    input:
    tuple val(meta), path(bqsr_reports)

    output:
    tuple val(meta), path("*.GatherBqsrReports.recal_data.csv"), emit: merged_reports

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reports_command = bqsr_reports.collect{"-I $it"}.join(' ')
    def args = task.ext.args ?: ''
    """
    /gatk --java-options "-Xmx${(task.memory.mega*0.8).intValue()}M" \\
        GatherBQSRReports \\
        $reports_command \\
        -O ${prefix}.GatherBqsrReports.recal_data.csv \\
        $args
    """

    stub:
    """
    touch test.GatherBqsrReports.recal_data.csv
    """
}
