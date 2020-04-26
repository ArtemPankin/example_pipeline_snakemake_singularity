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
		expand("out_supernova_{sample}/outs/report.txt", sample = TENXSAMPLE), ## supernova - de novo assembly module
		expand("out_findgse_{sample}/v1.94.est.jellyfish.hist.genome.size.estimated.k21to21.fitted.txt", sample = TENXSAMPLE)

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

rule jellyfish_kmer:
	input:
		"out_lrbasic_{sample}/outs/barcoded.fastq.gz"
	output:
		"out_jellyfish_{sample}/kmer_counts_jellyfish"
	log:
		"logs/jellyfish/{sample}_kmer.log"
	threads: 4
	shell:
		"(zcat {input} | "
		"jellyfish count /dev/fd/0 -C -o {output} -m 21 -t {threads} -s 5G) 2> {log}"

rule jellyfish_hist:
	input:
		"out_jellyfish_{sample}/kmer_counts_jellyfish"
	output:
		"out_jellyfish_{sample}/jellyfish.hist"
	log:
		"logs/jellyfish/{sample}_hist.log"
	shell:
		"(jellyfish histo -h 3000000 -o {output} {input}) 2> {log}"

rule findgse:
	input:
		"out_jellyfish_{sample}/jellyfish.hist"
	params:
		outdir = "out_findgse_{sample}"
	output:
		"out_findgse_{sample}/v1.94.est.jellyfish.hist.genome.size.estimated.k21to21.fitted.txt"
	log:
		"logs/findgse/{sample}.log"
	script:
		"scripts/findgse.R"
