process SPARK_STARTWORKER {
    container 'docker.io/biocontainers/spark:3.1.3_cv1'
    cpus { worker_cores }
    // 1 GB of overhead for Spark, the rest for executors
    memory "${worker_mem_in_gb+1} GB"

    input:
    tuple val(spark_uri), path(cluster_work_dir), val(worker_id)
    path(data_dir)
    val(worker_cores)
    val(worker_mem_in_gb)

    output:
    val(spark_uri)

    when:
    task.ext.when == null || task.ext.when

    script:
    args = task.ext.args ?: ''
    sleep_secs = task.ext.sleep_secs ?: '1'
    spark_worker_log_file = "${cluster_work_dir}/sparkworker-${worker_id}.log"
    spark_config_filepath = "${cluster_work_dir}/spark-defaults.conf"
    terminate_file_name = "${cluster_work_dir}/terminate-spark"
    container_engine = workflow.containerEngine
    """
    /opt/scripts/startworker.sh "$cluster_work_dir" "$spark_uri" $worker_id $worker_cores $worker_mem_in_gb "$spark_worker_log_file" "$spark_config_filepath" "$terminate_file_name" "$args" $sleep_secs $container_engine
    """
}
