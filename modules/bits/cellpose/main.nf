process CELLPOSE {
    container 'docker.io/multifish/cellpose:2.2.3-dask2023.10.1-py11'
    cpus { cellpose_cpus }
    memory "${cellpose_mem_in_gb} GB"
    clusterOptions { task.ext.cluster_opts }

    input:
    tuple val(meta), path(image), path(output_dir), path(dask_config)
    tuple val(image_subpath), val(output_name)
    val(dask_scheduler)
    val(cellpose_cpus)
    val(cellpose_mem_in_gb)

    output:
    tuple val(meta),
          path(image),
          path("${output_dir}/${output_name_noext}*${output_name_ext}"), emit: results
    tuple val(meta), val(output_name_noext), val(output_name_ext)      , emit: result_names
    path('versions.yml')                                               , emit: versions

    script:
    log.info "!!!!!${dask_config}"
    def args = task.ext.args ?: ''
    def input_image_subpath_arg = image_subpath
                                    ? "--input-subpath ${image_subpath}"
                                    : ''
    def output_image_name = output_name ?: ''
    def output = output_image_name ? "${output_dir}/${output_image_name}" : output_dir
    def dask_scheduler_arg = dask_scheduler ? "--dask-scheduler ${dask_scheduler}" : ''
    (output_name_noext, output_name_ext) = output_image_name.lastIndexOf('.').with {
        it == -1
            ? [output_image_name, ''] 
            : [output_image_name[0..<it], output_image_name[(it+1)..-1]]
    }
    log.debug "Output name:ext => ${output_name_noext}:${output_name_ext}"
    """
    python /opt/scripts/cellpose/distributed_cellpose.py \
        -i ${image} ${input_image_subpath_arg} \
        -o ${output} \
        ${dask_scheduler_arg} \
        ${args}

    cellpose_version=\$(python /opt/scripts/cellpose/distributed_cellpose.py \
                            --version | \
                        grep "cellpose version" | \
                        sed "s/cellpose version:\\s*//")
    echo "Cellpose version: \${cellpose_version}"
    cat <<-END_VERSIONS > versions.yml
    cellpose: \${cellpose_version}
    END_VERSIONS
    """

}
