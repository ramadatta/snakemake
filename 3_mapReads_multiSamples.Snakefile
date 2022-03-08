# This snakemake file maps multiple samples and writes the sam file into a output directory 
# The difference from previous file is we are dynamically reading the fastq files using glob_wildcards

SAMPLES, = glob_wildcards("{samples}_1.fastq")

rule all:
  input: expand("bowtie2_EC_output/{id}.sam", id=SAMPLES)

rule bowtie2_EC_alignment:
  input:
    R1='{id}_1.fastq',
    R2='{id}_2.fastq',
  output:
    sam='bowtie2_EC_output/{id}.sam',
    stats='bowtie2_EC_output/{id}.stats',
  shell:
    '''bowtie2 -X 1000 -x EC_Ref -1 {input.R1} -2 {input.R2} -S {output.sam} --end-to-end --sensitive --threads 20 2> {output.stats}'''

