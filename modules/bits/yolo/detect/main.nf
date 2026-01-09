process YOLO_DETECT {
    tag "${meta.id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'quay.io/cellgeni/yolo:latest'
        : 'quay.io/cellgeni/yolo:latest'}"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("predict/*.jpg"), emit: detections, optional: true
    tuple val(meta), path("predict/crops/*.jpg"), emit: crops, optional: true
    tuple val(meta), path("predict/labels/*.txt"), emit: bboxes
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    yolo detect predict \\
        source=${image} \\
        project=./ \\
        save_txt=true \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        yolo: \$(yolo version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    echo ${args}
    mkdir -p predict/labels/
    touch predict/labels/dummy.txt
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        yolo: \$(yolo version)
    END_VERSIONS
    """
}
