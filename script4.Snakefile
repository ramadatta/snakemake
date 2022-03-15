SAMPLES, = glob_wildcards("{samples}_1.fastq")

rule all:
    input:
        expand('{sample}_spades', sample=SAMPLES)

rule spades_assembly:
    input:
        r1 = '{sample}_1.fastq',
        r2 = '{sample}_2.fastq'
    output:
        o=directory('{sample}_spades')
    shell:
        'spades.py --pe1-1 {input.r1} --pe1-2 {input.r2} -o {output.o} --careful -t 48'

rule rename_spades_assembly_file:
     input: '{sample}_spades/contigs.fasta'
     output: 'contigs/{sample}_contigs.fasta'
     shell: 'mv {input} > {output}'
