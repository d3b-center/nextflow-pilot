process GATK4_HAPLOTYPECALLER {
    tag "${meta.id}"
    label 'process_medium'
    container 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.beta.1-3.5'

    input:
    tuple val(meta), path(input_bam), path(input_bam_index), path(sequence_interval)
    path(fasta)
    path(fai)
    path(dict)
    val(contamination)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.vcf.gz.tbi"),  emit: germline_vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    """
    /gatk-launch --javaOptions "-Xmx${(task.memory.mega*0.8).intValue()}M" \\
        PrintReads \\
        -I $input_bam \\
        -L $sequence_interval \\
        -O local.sharded.bam \\
        $args \\
    && java -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx${(task.memory.mega*0.8).intValue()}M -jar /GenomeAnalysisTK.jar \\
        -T HaplotypeCaller \\
        -I local.sharded.bam \\
        -L $sequence_interval \\
        -R $fasta \\
        -o ${prefix}.vcf.gz \\
        -contamination $contamination \\
        $args2
    """

    stub:
    """
    touch test.vcf.gz
    touch test.vcf.gz.tbi
    """
}
