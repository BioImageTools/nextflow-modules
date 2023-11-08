process SPARK_STARTMANAGER {
    label 'process_single'
    container 'docker.io/biocontainers/spark:3.1.3_cv1'

    input:
    path(cluster_work_dir)

    output:
    val(cluster_work_fullpath)

    when:
    task.ext.when == null || task.ext.when

    script:
    args = task.ext.args ?: ''
    spark_local_dir = task.ext.spark_local_dir ?: "/tmp/spark-${workflow.sessionId}"
    sleep_secs = task.ext.sleep_secs ?: '1'
    spark_config_filepath = "${cluster_work_dir}/spark-defaults.conf"
    spark_master_log_file = "${cluster_work_dir}/sparkmaster.log"
    terminate_file_name = "${cluster_work_dir}/terminate-spark"
    container_engine = workflow.containerEngine
    cluster_work_fullpath = cluster_work_dir.resolveSymLink().toString()
    """
    /opt/scripts/startmanager.sh "$spark_local_dir" "$cluster_work_dir" "$spark_master_log_file" \
        "$spark_config_filepath" "$terminate_file_name" "$args" $sleep_secs $container_engine
    """
}
