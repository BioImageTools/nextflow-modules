process SPARK_WAITFORMANAGER {
    label 'process_single'
    container 'docker.io/biocontainers/spark:3.1.3_cv1'
    errorStrategy { task.exitStatus == 2
        ? 'retry' // retry on a timeout to prevent the case when the waiter is started before the master and master never gets its chance
        : 'terminate' }
    maxRetries 20

    input:
    path(cluster_work_dir)

    output:
    tuple env(spark_uri), val(cluster_work_fullpath)

    when:
    task.ext.when == null || task.ext.when

    script:
    sleep_secs = task.ext.sleep_secs ?: '1'
    max_wait_secs = task.ext.max_wait_secs ?: '3600'
    spark_master_log_name = "${cluster_work_dir}/sparkmaster.log"
    terminate_file_name = "${cluster_work_dir}/terminate-spark"
    cluster_work_fullpath = cluster_work_dir.resolveSymLink().toString()
    """
    /opt/scripts/waitformanager.sh "$spark_master_log_name" "$terminate_file_name" $sleep_secs $max_wait_secs
    export spark_uri=`cat spark_uri`
    """
}
