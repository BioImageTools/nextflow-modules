include { SPARK_PREPARE        } from '../../../modules/bits/spark/prepare/main'
include { SPARK_STARTMANAGER   } from '../../../modules/bits/spark/startmanager/main'
include { SPARK_WAITFORMANAGER } from '../../../modules/bits/spark/waitformanager/main'
include { SPARK_STARTWORKER    } from '../../../modules/bits/spark/startworker/main'
include { SPARK_WAITFORWORKER  } from '../../../modules/bits/spark/waitforworker/main'

/**
 * Create a new Spark cluster for each spark_work_dir and wait for it to be ready.
 * Returns a tuple that provides the cluster URI for each spark_work_dir.
 */
workflow SPARK_CLUSTER {
    take:
    spark_work_dir      // channel: [ val(spark_work_dir) ]
    data_dir            // path: [ /path/to/input mounted to the Spark workers ]
    spark_workers       // int: number of workers in the cluster
    spark_worker_cores  // int: number of cores per worker
    spark_gb_per_core   // int: number of GB of memory per worker core

    main:
    // prepare spark cluster params
    def prepare_input = spark_work_dir.map { [
        file(it).parent,
        file(it).name
    ] }
    SPARK_PREPARE(prepare_input)

    // start the Spark manager
    // this runs indefinitely until SPARK_TERMINATE is called
    SPARK_STARTMANAGER(SPARK_PREPARE.out)

    // start a watcher that waits for the manager to be ready
    SPARK_WAITFORMANAGER(SPARK_PREPARE.out) // channel: [val(spark_uri, val(spark_work_dir))]

    // cross product all workers with all work dirs
    // so that we can start all needed spark workers with the proper worker directory
    def workers_list = 1..spark_workers

    // cross product all worker directories with all worker numbers
    // channel: [val(spark_uri), val(spark_work_dir), val(worker_id)]
    def workers_with_work_dirs = SPARK_WAITFORMANAGER.out.combine(workers_list)

    workers_with_work_dirs.subscribe {
        log.debug "workers_with_work_dirs: ${it}"
    }

    // start workers
    // these run indefinitely until SPARK_TERMINATE is called
    SPARK_STARTWORKER(
        workers_with_work_dirs,
        data_dir,
        spark_worker_cores,
        spark_worker_cores * spark_gb_per_core,
    )

    // wait for cluster to start
    def final_out = SPARK_WAITFORWORKER(workers_with_work_dirs)
    | map {
        def worker_id = it[2]
        log.debug "Spark worker $worker_id - started"
        it
    }
    | groupTuple(by: [0,1]) // wait for all workers to start
    | map {
        log.debug "Spark cluster started:"
        log.debug "  Spark URI: ${it[0]}"
        log.debug "  Spark work directory: ${it[1]}"
        log.debug "  Number of workers: ${spark_workers}"
        log.debug "  Cores per worker: ${spark_worker_cores}"
        log.debug "  GB per worker core: ${spark_gb_per_core}"
        it[0..1]
    }

    emit:
    done = final_out // channel: [ spark_uri, spark_work_dir ]
}
