process PICARD_MERGEVCFS_RENAMESAMPLE {
    tag "${meta.id}"
    label 'process_low'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    tuple val(meta), path(input_vcfs), path(input_vcf_indexes)
    val(biospecimen_name)

    output:
    tuple val(meta), path("*.g.vcf.gz"), path("*.g.vcf.gz.tbi"), emit: merged_vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def inputs_command = input_vcfs.collect{"INPUT=$it"}.join(' ')
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        MergeVcfs \\
        $inputs_command \\
        OUTPUT=/dev/stdout \\
        CREATE_INDEX=false \\
    | /VcfSampleRename.py \\
        $biospecimen_name \\
    | bgzip \\
        -c \\
        > ${prefix}.g.vcf.gz \\
    && tabix \\
        -p vcf \\
        ${prefix}.g.vcf.gz
    """

    stub:
    """
    touch test.g.vcf.gz
    touch test.g.vcf.gz.tbi
    """
}
