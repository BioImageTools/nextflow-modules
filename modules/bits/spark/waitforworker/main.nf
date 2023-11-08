process SPARK_WAITFORWORKER {
    label 'process_single'
    container 'docker.io/biocontainers/spark:3.1.3_cv1'
    errorStrategy { task.exitStatus == 2
        ? 'retry' // retry on a timeout to prevent the case when the waiter is started before the worker and the worker never gets its chance
        : 'terminate' }
    maxRetries 20

    input:
    tuple val(spark_uri), path(cluster_work_dir), val(worker_id)

    output:
    tuple val(spark_uri), val(cluster_work_fullpath), val(worker_id)

    when:
    task.ext.when == null || task.ext.when

    script:
    sleep_secs = task.ext.sleep_secs ?: '1'
    max_wait_secs = task.ext.max_wait_secs ?: '3600'
    spark_worker_log_file = "${cluster_work_dir}/sparkworker-${worker_id}.log"
    terminate_file_name = "${cluster_work_dir}/terminate-spark"
    cluster_work_fullpath = cluster_work_dir.resolveSymLink().toString()
    """
    /opt/scripts/waitforworker.sh "$spark_uri" "$spark_worker_log_file" "$terminate_file_name" $sleep_secs $max_wait_secs
    """
}
