# nextflow-modules

nf-core-compatible Nextflow modules for bioimage analysis tools.

The repository is formatted to be compatible with [nf-core tooling](https://nf-co.re/), in particular the [module system](https://github.com/nf-core/modules/tree/master).

The `org_path` is "bits" which stands for **B**io**I**mage**T**ool**s**.

## Prerequisites

You must [install nf-core tools](https://nf-co.re/tools) in your environment before you can install modules from this repository.

## Initializing an nf-core pipeline

To install modules from this repository you must have an nf-core-compatible pipeline folder structure. Your pipeline should be called `main.nf`, and you should have a `nextflow.config` in the same folder.  With the current version (2.10) of nf-core tools, you must also initialize some directory and file structure:

```bash
touch .nf-core.yml
mkdir modules
```

Next, create a `modules.json` file in that folder like this:
```json
{
    "name": "",
    "homePage": "",
    "repos": {
        "git@github.com:BioImageTools/nextflow-modules.git": {
            "modules": {
            }
        }
    }
}
```

When you install a module, it may prompt you with some questions the first time through. Just accept the defaults:

```
Is this repository an nf-core pipeline or a fork of nf-core/modules? pipeline
Would you like me to add this config now? yes
```
For advnaced usage/setting, please see [this documentation](https://claptar.notion.site/Converting-pipeline-to-NF-CORE-201b0afc406980d49eddf32accdf0af2) from @Claptar

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

