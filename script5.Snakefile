SAMPLES, = glob_wildcards("{samples}_1.fastq")

rule all:
    input:
        expand('contigs/{sample}_contigs.fasta', sample=SAMPLES)

rule rename_spades_assembly_file:
     input: '{sample}_spades/contigs.fasta'
     output: 'contigs/{sample}_contigs.fasta'
     shell: 'cp {input} {output}'
