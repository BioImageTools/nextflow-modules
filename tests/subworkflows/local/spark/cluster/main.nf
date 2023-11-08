#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SPARK_CLUSTER   } from '../../../../../subworkflows/bits/spark_cluster/main.nf'
include { SPARK_TERMINATE } from '../../../../../modules/bits/spark/terminate/main.nf'

workflow test_spark_cluster {

    def spark_work_dir = "${workDir}/test/spark/${workflow.sessionId}"
    def spark_work_d = new File(spark_work_dir)
    if (!spark_work_d.exists()) {
        spark_work_d.mkdirs()
    }

    def data_dir1 = "${workDir}/test/data1"
    def data_d1 = new File(data_dir1)
    if (!data_d1.exists()) {
        data_d1.mkdirs()
    }

    def data_dir2 = "${workDir}/test/data2"
    def data_d2 = new File(data_dir2)
    if (!data_d2.exists()) {
        data_d2.mkdirs()
    }

    SPARK_CLUSTER (
        Channel.of(spark_work_dir),
        [data_dir1, data_dir2],
        2,
        1,
        1
    )
    | SPARK_TERMINATE
}
