# A simple snakemake file to take a reads from a sample and map on to a Reference genome


rule all:
  input: ['bowtie2_output/E307.sam', 'bowtie2_output/E307.stats']

rule bowtie2_alignment:
  input:
    R1='E307_1.fastq',
    R2='E307_2.fastq'
  output:
    sam='bowtie2_output/E307.sam',
    stats='bowtie2_output/E307.stats'
  shell:
    '''bowtie2 -X 1000 -x KP_Ref -1 {input.R1} -2{input.R2} -S {output.sam} --end-to-end --sensitive --threads 20 2> {output.stats}'''
