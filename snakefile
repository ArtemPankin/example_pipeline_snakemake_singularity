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
 
TENXSAMPLE = config["10x_sample"]

#################
## rules
#################

include: "modules/findgse.module"
include: "modules/getorganelle_plast.module"


rule all:
	input:
		expand("out_supernova_{sample}/outs", sample = TENXSAMPLE), ## supernova - de novo assembly module
		expand("out_findgse_{sample}/v1.94.est.jellyfish.hist.genome.size.estimated.k21to21.fitted.txt", sample = TENXSAMPLE),
		expand("out_getorganelle_plast_{sample}", sample = TENXSAMPLE)

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

