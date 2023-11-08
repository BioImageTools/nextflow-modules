include { SPARK_CLUSTER } from '../spark_cluster/main'

/**
 * Prepares a Spark context using either a distributed cluster or single process
 * as specified by the `spark_cluster` parameter.
 *
 * Expects a channel of meta tuples where the meta contains a `spark_work_dir` key.
 * A Spark cluster is created for each meta, and the Spark contexts are returned
 * appended to each meta tuple.
 */
workflow SPARK_START {
    take:
    ch_meta               // channel: [ val(meta), [ files ] ]
    data_dir              // path: [ /path/to/input mounted to the Spark workers ]
    spark_cluster         // boolean: start a distributed cluster?
    spark_workers         // int: number of workers in the cluster (ignored if spark_cluster is false)
    spark_worker_cores    // int: number of cores per worker
    spark_gb_per_core     // int: number of GB of memory per worker core
    spark_driver_cores    // int: number of cores for the driver
    spark_driver_memory   // string: memory specification for the driver

    main:

    spark_work_dirs = ch_meta.map { it[0].spark_work_dir }

    if (spark_cluster) {
        workers = spark_workers
        driver_cores = spark_driver_cores
        driver_memory = spark_driver_memory
        spark_cluster_res = SPARK_CLUSTER(
            spark_work_dirs,
            data_dir,
            workers,
            spark_worker_cores,
            spark_gb_per_core
        )
    }
    else {
        // When running locally, the driver needs enough resources to run a spark worker
        workers = 1
        driver_cores = spark_driver_cores + spark_worker_cores
        driver_memory = (2 + spark_worker_cores * spark_gb_per_core) + " GB"
        spark_cluster_res = spark_work_dirs.map { [ 'local[*]', it ] }
    }

    log.debug "Setting workers: $workers"
    log.debug "Setting driver_cores: $driver_cores"
    log.debug "Setting driver_memory: $driver_memory"

    // Rejoin Spark clusters to metas
    // channel: [ meta, spark_work_dir, spark_uri ]
    spark_context = ch_meta.map {
        def (meta, files) = it
        log.debug "Prepared $meta.id"
        [meta, meta.spark_work_dir, files]
    }
    .join(spark_cluster_res, by:1)
    .map {
        def (spark_work_dir, meta, files, spark_uri) = it
        def spark = [:]
        spark.uri = spark_uri
        spark.work_dir = spark_work_dir
        spark.workers = workers ?: 1
        spark.worker_cores = spark_worker_cores
        spark.driver_cores = driver_cores ?: 1
        spark.driver_memory = driver_memory
        spark.parallelism = (workers * spark_worker_cores)
        spark.executor_memory = (spark_worker_cores * spark_gb_per_core)+" GB"
        log.debug "Assigned Spark context for ${meta.id}: "+spark
        [meta, files, spark]
    }

    emit:
    spark_context // channel: [ val(meta), [ files ], val(spark_context) ]
}
