process VERIFYBAMID {
    container "griffan/verifybamid2:v1.0.6"

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    path(fai)
    path(contamination_bed)
    path(contamination_mu)
    path(contamination_ud)

    output:
    tuple val(meta), path('*.selfSM'), emit: contamination_estimation

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    /VerifyBamID/bin/VerifyBamID \\
        --Verbose \\
        --DisableSanityCheck \\
        --NumPC $task.cpus \\
        --Output $prefix \\
        --BamFile $bam \\
        --Reference $fasta \\
        --UDPath $contamination_ud \\
        --MeanPath $contamination_mu \\
        --BedPath $contamination_bed \\
        1>/dev/null
    """

    stub:
    """
    touch test.selfSM
    """
}
