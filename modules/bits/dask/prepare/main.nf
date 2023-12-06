process DASK_PREPARE {
    label 'process_low'
    container { task.ext.container ?: 'docker.io/biocontainers/dask:2023.10.1-py11-ol9_cv1' }

    input:
    tuple val(meta), path(data)
    path(dask_work_dir)

    output:
    tuple val(meta), env(cluster_work_fullpath)

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    cluster_work_dir="${dask_work_dir}/${meta.id}"
    mkdir \${cluster_work_dir}
    cluster_work_fullpath=\$(realpath \${cluster_work_dir})
    echo "Cluster work dir: \${cluster_work_fullpath}"

    /opt/scripts/daskscripts/prepare.sh "\${cluster_work_fullpath}"
    """
}
