process PYTHON_CREATESEQUENCEGROUPS {
    label 'process_single'
    container "python:2.7.18"

    input:
    path(dict)

    output:
    path('*.intervals'), emit: intervals

    when:
    task.ext.when == null || task.ext.when

    script:
    template 'create_sequence_groups.py'

    stub:
    """
    touch a.intervals
    touch b.intervals
    touch c.intervals
    touch unmapped.intervals
    """
}
