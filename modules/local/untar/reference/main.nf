process UNTAR_REFERENCE {
    tag ''
    label 'process_low'

    container 'ubuntu:20.04'

    input:
    path(reference_tar)

    output:
    path('*.fasta'), emit: fasta
    path('*.dict'), emit: dict
    path('*.fai'), emit: fai
    path('*.{alt,amb,ann,bwt,pac,sa}'), emit: bwa_references

    script:
    """
    tar xf $reference_tar
    """

    stub:
    """
    touch test.fasta
    touch test.dict
    touch test.fasta.fai
    touch test.fasta.64.alt
    touch test.fasta.64.amb
    touch test.fasta.64.ann
    touch test.fasta.64.bwt
    touch test.fasta.64.pac
    touch test.fasta.64.sa
    """
}
