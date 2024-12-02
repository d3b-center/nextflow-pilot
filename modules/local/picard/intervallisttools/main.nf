process PICARD_INTERVALLISTTOOLS {
    label 'process_low'
    container 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'

    input:
    path(interval_list)

    output:
    path("temp*/*.interval_list"), emit: interval_lists

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    java -Xmx${(task.memory.mega*0.8).intValue()}M -jar /picard.jar \\
        IntervalListTools \\
        INPUT=${interval_list} \\
        OUTPUT=. \\
        $args
    """

    stub:
    """
    mkdir temp1
    touch temp1/01.interval_list
    touch temp1/02.interval_list
    touch temp1/03.interval_list
    """
}
