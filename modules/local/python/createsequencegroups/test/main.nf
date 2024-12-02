params.dict = ''

include { PYTHON_CREATESEQUENCEGROUPS } from '../main.nf'

workflow {
    in_dict = Channel.fromPath(params.dict)
    PYTHON_CREATESEQUENCEGROUPS(in_dict)
    PYTHON_CREATESEQUENCEGROUPS.out.sequence_intervals.view()
}

