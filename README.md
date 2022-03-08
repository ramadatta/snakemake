### Snakemake

```
snakemake --snakefile 2_mapReads_multiSamples.Snakefile --cores 20
```

### Errors 

- `invalid syntax` - mainly due to comma in input and output arguments
- `Missing input files for rule` - check if the input files is correct. 
  - This gave me an error: `SAMPLES, = glob_wildcards("{samples}.fastq")`
  - This resolved the error: `SAMPLES = ["E306","E307","E678"]`
  - This is because these are not single read files but paired-end read files
