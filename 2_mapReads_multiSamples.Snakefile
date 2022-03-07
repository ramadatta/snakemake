# This snakemake file maps multiple samples and writes the sam file into a output directory 

KP_SAMPLES = ["E306","E307"]

rule all:
  input: expand("bowtie2_output/{id}.sam", id=KP_SAMPLES)

rule bowtie2_alignment:
  input:
    R1='{id}_1.fastq',
    R2='{id}_2.fastq',
  output:
    sam='bowtie2_output/{id}.sam',
    stats='bowtie2_output/{id}.stats',
  shell:
    '''bowtie2 -X 1000 -x KP_Ref -1 {input.R1} -2 {input.R2} -S {output.sam} --end-to-end --sensitive --threads 20 2> {output.stats}'''



