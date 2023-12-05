You can run these tests using:

```
nextflow run ./tests/subworkflows/bits/start_dask/main.nf -entry test_start_stop_dask -c tests/config/nf-test.config -c ./tests/subworkflows/bits/start_dask/nextflow.config -profile docker --distributed false


nextflow run ./tests/subworkflows/bits/start_dask/main.nf -entry test_start_stop_dask -c tests/config/nf-test.config -c ./tests/subworkflows/bits/start_dask/nextflow.config -profile docker --distributed true
```
