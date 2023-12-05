include { START_DASK } from '../../../../subworkflows/bits/start_dask/main.nf'
include { STOP_DASK  } from '../../../../subworkflows/bits/stop_dask/main.nf'

params.distributed = true

workflow test_start_stop_dask {
    def dask_cluster_input = [
        [id: 'test_local_dask'],
        [/* empty data paths */],
    ]

    def dask_cluster_info = START_DASK(
        Channel.of(dask_cluster_input),
        params.distributed,
        file(params.dask_work_dir),
        3, // dask workers
        2, // required workers
        1, // worker cores
        1.5, // worker mem
    )
    | STOP_DASK

    dask_cluster_info.subscribe {
        log.info "Cluster info: $it"
    }
}
