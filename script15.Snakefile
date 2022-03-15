SAMPLES, = glob_wildcards("{samples}_1.fastq")

rule all:
    input:
        expand('{sample}_1_bbmap_adaptertrimmed.fq', sample=SAMPLES),
	expand('{sample}_2_bbmap_adaptertrimmed.fq', sample=SAMPLES),
	'2_CleanData',
	expand('SPAdes_Assemblies/gteq1kb/{sample}.gte1kb.contigs.fasta', sample=SAMPLES), 
	'mlst/Combined_log_mlst_2.19.txt',
	expand('Kraken2/{sample}_kraken2_report.txt', sample=SAMPLES),
	expand('AMRFinderplus/{sample}_amrfinder_out.txt', sample=SAMPLES),
	#expand('Prokka/{sample}_prokka_out', sample=SAMPLES), 
	expand('Prokka/{sample}_prokka_out/{sample}.gff', sample=SAMPLES),
	expand('Roary/{sample}.gff', sample=SAMPLES),'roary.done'

rule bbtools_qualfil_trim:
    input:
        r1 = '{sample}_1.fastq',
        r2 = '{sample}_2.fastq'
    output:
        out1 = "{sample}_1_bbmap_adaptertrimmed.fq",
        out2 = "{sample}_2_bbmap_adaptertrimmed.fq",
    log: "logs/bbduk.{sample}.log"
    shell:
        '/storage/apps/bbmap/bbduk.sh -Xmx6g in1={input.r1} in2={input.r2} out1={output.out1} out2={output.out2} ref=/storage/apps/bbmap/resources/adapters.fa ktrim=r k=23 mink=11 hdist=1 qtrim=rl trimq=30 minavgquality=30 &>{log}; touch {output.out1} {output.out2}'

rule spades_assembly:
    input:
        r1 = '{sample}_1_bbmap_adaptertrimmed.fq',
        r2 = '{sample}_2_bbmap_adaptertrimmed.fq'
    output:
        o=directory('{sample}_spades')
    shell:
        'spades.py --pe1-1 {input.r1} --pe1-2 {input.r2} -o {output.o} --careful -t 48'

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
        r1 = '{sample}_1_bbmap_adaptertrimmed.fq',
        r2 = '{sample}_2_bbmap_adaptertrimmed.fq'
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

rule move_CleanData:
    input:
        r1 = expand('{sample}_1_bbmap_adaptertrimmed.fq',sample=SAMPLES),
        r2 = expand('{sample}_1_bbmap_adaptertrimmed.fq',sample=SAMPLES)
    output: '2_CleanData/'
    shell:
        """ 
        mv {input.r1} {output};
	mv {input.r2} {output};
        """

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
  outdir = "Roary/Roary_output"
 shell:
  'roary -f {params.outdir} -e --mafft  -p 48 -cd 95 {input} && touch {output}'


