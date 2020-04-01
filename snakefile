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

rule all:
	input:
		expand("out_supernova_{sample}/outs/report.txt", sample = TENXSAMPLE),
		expand("out_lrbasic_{sample}/outs/barcoded.fastq.gz", sample = TENXSAMPLE)

#rule create_dir_supernova:
#    	output: 
#    		directory(expand("10x/{sample}", sample = TENXSAMPLE))
#    	shell:
#        	"mkdir -p {output}"

rule supernova_assembly:
	input:
		dir="10x/{sample}",
	output: 
		"out_supernova_{sample}/outs/report.txt"
	log:
		"logs/supernova/{sample}.log"
	singularity:
        	"docker://nfcore/supernova"
	shell: 
		"(supernova run --id=out_supernova_{wildcards.sample} --fastqs={input.dir} --sample={wildcards.sample} --localmem 600 --localcores 10 --maxreads='all') 2> {log}"

rule longranger_basic:
	input:
		dir="10x/{sample}"
	output:
		"out_lrbasic_{sample}/outs/barcoded.fastq.gz"
	log:
		"logs/longranger/{sample}.log"
	singularity:
		"docker://olavurmortensen/longranger"
	shell:
		"longranger basic --id=out_lrbasic_{wildcards.sample} --fastqs={input.dir} --sample={wildcards.sample} --localcores=10 --localmem=50 --maxjobs=20"
