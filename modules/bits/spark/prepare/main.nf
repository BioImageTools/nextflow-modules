process SPARK_PREPARE {
    label 'process_single'
    container 'docker.io/biocontainers/spark:3.1.3_cv1'

    input:
    // The parent spark dir and the dir name are passed separately so that parent
    // gets mounted and work dir can be created within it
    tuple path(spark_work_dir), val(spark_work_dir_name)

    output:
    val(cluster_work_fullpath)

    when:
    task.ext.when == null || task.ext.when

    script:
    cluster_work_fullpath = spark_work_dir.resolveSymLink().resolve(spark_work_dir_name).toString()
    """
    /opt/scripts/prepare.sh "$spark_work_dir/$spark_work_dir_name"
    """
}
