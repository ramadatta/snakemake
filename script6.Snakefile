SAMPLES, = glob_wildcards("{samples}_1.fastq")

rule all:
    input:
        expand('contigs/{sample}.gte1kb.contigs.fasta', sample=SAMPLES)
"""
rule spades_assembly:
    input:
        r1 = '{sample}_1.fastq',
        r2 = '{sample}_2.fastq'
    output:
        o=directory('{sample}_spades')
    shell:
        'spades.py --pe1-1 {input.r1} --pe1-2 {input.r2} -o {output.o} --careful -t 48'
"""

rule rename_spades_assembly_file:
     input: '{sample}_spades/contigs.fasta',
     output: 'contigs/{sample}_contigs.fasta'
     shell: 'cp {input} {output}'

rule filter_1kb_contigs_spades_assembly_file:
     input: 'contigs/{sample}_contigs.fasta',
     output: 'contigs/{sample}.gte1kb.contigs.fasta'
     shell: (""" /storage/apps/bioawk/bioawk -c fastx 'length($seq) >=1000 {{print "\>"$name"\\n"$seq}}' {input}  > {output}""") 

rule filter_1kb_contigs_spades_assembly_file:
     input: 'contigs/{sample}_contigs.fasta',
     output: 'contigs/{sample}.gte1kb.contigs.fasta'
     shell: (""" /storage/apps/bioawk/bioawk -c fastx 'length($seq) >=1000 {{print "\>"$name"\\n"$seq}}' {input}  > {output}""") 
