include { SPARK_TERMINATE } from '../../../modules/janelia/spark/terminate/main'

/**
 * Terminate the specified Spark clusters.
 */
workflow SPARK_STOP {
    take:
    meta_ch // channel: [ val(meta), [ files ], val(spark_context) ]

    main:
    if (params.spark_cluster) {
        done_cluster = meta_ch.map { [it[2].uri, it[2].work_dir] }
        done = SPARK_TERMINATE(done_cluster) | map { it[1] }
    }
    else {
        done = meta_ch.map { it[2].work_dir }
    }

    emit:
    done
}
