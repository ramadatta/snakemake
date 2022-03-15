### 1. Compiling Snakemake file

```
snakemake --snakefile 2_mapReads_multiSamples.Snakefile --cores 20
```

### 2. Must know

#### 2.1 Comments
```
# One line Comment
myvar = 5 # Can also start after any chunk of code
```

```
"""
Big multiple lines comment
So many lines
WoW
"""
```

#### 2.2 Running AWK
- [To escape this behaviour use double curly brackets: {{score[$3]}}](https://stackoverflow.com/questions/64364682/nameerror-when-ues-awk-in-snakemake)

### 3. Errors 

- `invalid syntax` - mainly due to comma in input and output arguments
- `Missing input files for rule` - check if the input files is correct. 
  - This gave me an error: `SAMPLES, = glob_wildcards("{samples}.fastq")`
  - This resolved the error: `SAMPLES = ["E306","E307","E678"]`
  - This is because these are not single read files but paired-end read files
- [`NameError:`, `Also note that braces not used for variable access have to be escaped by repeating them, i.e. {{print $1}}` ](https://stackoverflow.com/questions/64364682/nameerror-when-ues-awk-in-snakemake)
- [Unexpected keyword expand in rule definition ](https://stackoverflow.com/questions/50455772/snakemake-with-multiples-rule-all)
- [If you define a directory, and not files, as output of a rule, it can indeed be confusing for snakemake.](https://stackoverflow.com/questions/69824618/snakemake-make-rule-wait-for-full-excecution-of-previous-rule)
- [Unexpected keyword o in rule definition](https://groups.google.com/g/snakemake/c/9iZoH4bifOg) -make sure the intendation is proper


### 4. To check before running script
- [snakemake requires output to be files and not directory](https://stackoverflow.com/questions/51044361/syntax-error-in-snakemake-snakefile)
- [How the flow works](https://www.biostars.org/p/406916/)



