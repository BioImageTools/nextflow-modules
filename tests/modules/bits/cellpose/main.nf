include { DASK_PREPARE        } from '../../../../modules/bits/dask/prepare/main'
include { DASK_STARTMANAGER   } from '../../../../modules/bits/dask/startmanager/main'
include { DASK_STARTWORKER    } from '../../../../modules/bits/dask/startworker/main'
include { DASK_TERMINATE      } from '../../../../modules/bits/dask/terminate/main'
include { DASK_WAITFORMANAGER } from '../../../../modules/bits/dask/waitformanager/main'
include { DASK_WAITFORWORKERS } from '../../../../modules/bits/dask/waitforworkers/main'
include { CELLPOSE            } from '../../../../modules/bits/cellpose/main'

workflow test_distributed_cellpose_with_dask {
    def input_image = params.test_data['stitched_images']['n5']['r1_n5']
    def test_input_output = [
        file(input_image),
        file(params.output_image_dir),
    ]
    def cellpose_test_data = [
        [
            id: 'test_distributed_cellpose_with_dask',
        ],
        params.dask_config 
            ? test_input_output + [ file(params.dask_config).parent ]
            : test_input_output
    ]
    def cellpose_test_data_ch = Channel.of(cellpose_test_data)
    // create a dask cluster
    def dask_prepare_result = DASK_PREPARE(cellpose_test_data_ch, file(params.dask_work_dir))
    DASK_STARTMANAGER(dask_prepare_result)
    DASK_WAITFORMANAGER(dask_prepare_result)
    def dask_cluster_info = DASK_WAITFORMANAGER.out.cluster_info
    def dask_workers_list = 1..params.cellpose_workers

    def dask_workers_input = dask_cluster_info
    | join(cellpose_test_data_ch, by: 0)
    | combine(dask_workers_list)
    | multiMap { meta, cluster_work_dir, scheduler_address, data, worker_id ->
        log.info "Cluster data files: ${data}"
        worker_info: [ meta, cluster_work_dir, scheduler_address, worker_id ]
        data: data
    }
    DASK_STARTWORKER(dask_workers_input.worker_info,
                     dask_workers_input.data,
                     params.cellpose_worker_cpus,
                     params.cellpose_worker_mem_gb)
    def cluster = DASK_WAITFORWORKERS(dask_cluster_info,
                                      params.cellpose_workers,
                                      params.cellpose_required_workers)

    def cellpose_input = cluster.cluster_info
    | join(cellpose_test_data_ch, by: 0)
    | multiMap { meta, cluster_work_dir, scheduler_address, available_workers, datapaths ->
        data: [ meta, datapaths[0], datapaths[1] ]
        cluster: scheduler_address
        names: [ params.input_image_dataset, params.output_image_name ]
    }

    def cellpose_results = CELLPOSE(
        cellpose_input.data,
        cellpose_input.names,
        cellpose_input.cluster,
        params.cellpose_driver_cpus,
        params.cellpose_driver_mem_gb,
    )

    cellpose_results.results.subscribe {
        log.info "Cellpose results: $it"
    }

    cluster.cluster_info.join(cellpose_results.results, by:0)
    | map {
        def (meta, cluster_work_dir) = it
        [ meta, cluster_work_dir ]
    }
    | DASK_TERMINATE

}

workflow test_distributed_cellpose_without_dask_scheduler {
    def input_image = params.test_data['stitched_images']['n5']['r1_n5']
    def cellpose_test_data = [
        [
            id: 'test_distributed_cellpose_with_dask',
        ],
        file(input_image),
        file(params.output_image_dir),
    ]

    def cellpose_results = CELLPOSE(
        Channel.of(cellpose_test_data),
        Channel.of([ params.input_image_dataset, params.output_image_name ]),
        Channel.of(''),
        params.cellpose_driver_cpus,
        params.cellpose_driver_mem_gb,
    )

    cellpose_results.results.subscribe {
        log.info "Cellpose results: $it"
    }

}