import yaml

shell.prefix("set -euo pipefail; ")

#################
## CONFIG files
#################

configfile: "config.yaml"

with open('cluster.yaml', mode='r') as f:
    cluster_config = yaml.load(f)

#################
## data, sample ids
#################
 
10xSAMPLE = config["10x_sample"]

rule supernova:
	log:
		"logs/supernova/{10xsample}.log
	shell: 
		"supernova run --id=10x_supernova --fastqs=10x/raw_data/Her2 --sample=Her2 --localmem 600 --localcores 20 --maxreads='all') 2> {log}"
