# nextflow-modules

nf-core-compatible Nextflow modules for bioimage analysis tools.

The repository is formatted to be compatible with [nf-core tooling](https://nf-co.re/), in particular the [module system](https://github.com/nf-core/modules/tree/master).

The `org_path` is "bits" which stands for **B**io**I**mage**T**ool**s**.

## Prerequisites

You must [install nf-core tools](https://nf-co.re/tools) in your environment before you can install modules from this repository.

## Installing a module

To install a module into a pipeline, use the `modules install` command, e.g.:

```bash
nf-core modules -g git@github.com:BioImageTools/nextflow-modules.git install spark/prepare
```

## Installing a subworkflow

```bash
nf-core subworkflows -g git@github.com:BioImageTools/nextflow-modules.git install spark_start
```

This will install the subworkflow and all of its dependencies including the spark_cluster subworkflow and all necessary modules.

