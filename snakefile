import yaml

shell.prefix("set -euo pipefail; ")

#################
## CONFIG files
#################

configfile: "config.yaml"

with open('cluster.yaml', mode='r') as f:
    cluster_config = yaml.load(f)

#################
## datai ids, sample ids
#################
 
TENXSAMPLE = config["sample"]


#################
## rules
#################

include: "modules/findgse.module"
include: "modules/getorganelle_plast.module"
#include: "modules/"

rule all:
	input:
		expand("out_supernova_{sample}/outs", sample = TENXSAMPLE), ## supernova - de novo assembly module
		expand("out_findgse_{sample}/v1.94.est.jellyfish.hist.genome.size.estimated.k21to21.fitted.txt", sample = TENXSAMPLE), ## findgse - genome properties based on k-mer spectrum
		expand("out_getorganelle_plast_{sample}", sample = TENXSAMPLE), ## chloroplast genome assembler 
		expand("out_shasta_{sample}/Assembly.fasta", sample = TENXSAMPLE) ## nanopore assembler - Shasta
rule supernova_assembly:
	input:
		dir="10x/{sample}",
	output: 
		directory("out_supernova_{sample}/outs")
	log:
		"logs/supernova/{sample}.log"
	singularity:
        	"docker://nfcore/supernova"
	threads: 10
	shell: 
		"(supernova run --id=out_supernova_{wildcards.sample} --fastqs={input.dir} --sample={wildcards.sample} --localmem=600 --localcores={threads} --maxreads='all') 2> {log}"

rule longranger_basic:
	input:
		dir="10x/{sample}"
	output:
		"out_lrbasic_{sample}/outs/barcoded.fastq.gz"
	log:
		"logs/longranger/{sample}.log"
	singularity:
		"docker://olavurmortensen/longranger"
	threads: 10
	shell:
		"(longranger basic --id=out_lrbasic_{wildcards.sample} --fastqs={input.dir} --sample={wildcards.sample} --localcores={threads} --localmem=50 --maxjobs=20) 2> {log}"

rule shasta:
	input:
		file="ont_data/{sample}.fastq.gz"
	output:
		"out_shasta_{sample}/Assembly.fasta"
	params:
		outdir="out_shasta_{sample}"
	log:
		"logs/shasta/{sample}.log"
	singularity:
		"docker://kishwars/shasta"
	threads: 10
	shell:
		"(shasta --input {input.file} --memoryMode anonymous --memoryBacking 4K --Assembly.consensusCaller Bayesian:guppy-3.0.5-a --assemblyDirectory {params.outdir} --threads {threads}) 2> {log}"
		
