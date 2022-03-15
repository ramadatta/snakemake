SAMPLES, = glob_wildcards("{samples}_1.fastq")

rule all:
    input:
        expand('SPAdes_Assemblies/gteq1kb/{sample}.gte1kb.contigs.fasta', sample=SAMPLES), 
	'mlst/Combined_log_mlst_2.19.txt',
	expand('Kraken2/{sample}_kraken2_report.txt', sample=SAMPLES),
	expand('AMRFinderplus/{sample}_amrfinder_out.txt', sample=SAMPLES),
	#expand('Prokka/{sample}_prokka_out', sample=SAMPLES), 
	expand('Prokka/{sample}_prokka_out/{sample}.gff', sample=SAMPLES),
	expand('Roary/{sample}.gff', sample=SAMPLES),'roary.done'
	
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
     output: 'SPAdes_Assemblies/full_assemblies/{sample}_contigs.fasta'
     shell: 'cp {input} {output}'

rule filter_1kb_contigs_spades_assembly_file:
     input: 'SPAdes_Assemblies/full_assemblies/{sample}_contigs.fasta',
     output: 'SPAdes_Assemblies/gteq1kb/{sample}.gte1kb.contigs.fasta'
     shell: (""" /storage/apps/bioawk/bioawk -c fastx 'length($seq) >=1000 {{print "\>"$name"\\n"$seq}}' {input}  > {output} """) 


rule mlst:
     input: 'SPAdes_Assemblies/gteq1kb/{sample}.gte1kb.contigs.fasta',
     output: 'mlst/{sample}.log_mlst_2.19.txt'
     shell: 
        'mlst {input} | grep ".fasta" > {output}'

rule comb_mlst:
     input: expand('mlst/{sample}.log_mlst_2.19.txt', sample=SAMPLES),
     output: 'mlst/Combined_log_mlst_2.19.txt'
     shell:
        """ 
        cat {input} >> {output};
        """

rule kraken2:
    input:
        r1 = '{sample}_1.fastq',
        r2 = '{sample}_2.fastq'
    output: 
        result='Kraken2/{sample}_kraken2_result.txt',
        report='Kraken2/{sample}_kraken2_report.txt'	
    shell: 
        'kraken2 --db /storage/apps/Kraken2/Kraken2_db/minikraken_8GB_20200312 --threads 48 --report {output.report} --paired {input.r1} {input.r2} --output {output.result}'

rule amrfinderplus:
     input: 'SPAdes_Assemblies/gteq1kb/{sample}.gte1kb.contigs.fasta'
     output: 'AMRFinderplus/{sample}_amrfinder_out.txt'
     shell: 
        '/storage/apps/amrfinder/amrfinder --plus -n {input} > {output} --threads 48'


rule prokka:
     input: 'SPAdes_Assemblies/gteq1kb/{sample}.gte1kb.contigs.fasta'
     output:
       "Prokka/{sample}_prokka_out/{sample}.gff"
     params:
       outdir = "Prokka/{sample}_prokka_out",
       genome = "{sample}"
     shell:
      'prokka --force --cpus 32 --outdir {params.outdir} --prefix {params.genome} {input} >>{params.genome}.prokka_log 2>>{params.genome}.prokka_error'

rule prokka_gffs:
     input: 'Prokka/{sample}_prokka_out/{sample}.gff'
     output: 'Roary/{sample}.gff'
     shell: 'cp {input} {output}'

rule roary:
 input:
  expand('Roary/{sample}.gff', sample=SAMPLES)
 output:
  "roary.done"
 params:
  outdir = "roary_results"
 shell:
  'roary -p 32 -f {params.outdir} -e -n -v {input} && touch {output}'


"""

rule _all_prokka:
 input:
  expand("fnas/prokka_{genome}/{genome}.gff", genome=GENOMES)

roary -e --mafft  -p 48 -cd 95 {input}


rule roary:
     input: 'Roary/*.gff'
     output: 'Roary/core_gene_alignment.aln'
     shell: 
        'roary -e --mafft  -p 48 -cd 95 {input}'
"""
