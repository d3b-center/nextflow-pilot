process BIOBAMBAM_BAMTOFASTQ {
    container "pgc-images.sbgenomics.com/d3b-bixu/bwa-bundle:dev"

    input:
    tuple val(meta), path(reads)
    path(fasta)

    output:
    tuple val(meta), path('*.fq'), emit: fastq

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def reference_command = fasta ? "reference=$fasta" : ''
    """
    bamtofastq \\
        filename=$reads \\
        inputFormat=${reads.getExtension()} \\
        $reference_command \\
        $args \\
        > ${reads.getBaseName()}.fq
    """

    stub:
    """
    touch test.fq
    """
}
