import os


rule extract_inserts:
    """Pull the barcode insert out of each read, between the two flanking adapters."""
    input:
        get_reads,
    output:
        "trimmed/{sample}.inserts.txt",
    params:
        left=config["adapters"]["left"],
        right=config["adapters"]["right"],
    conda:
        "../envs/seqkit.yaml"
    log:
        "logs/extract_inserts/{sample}.log",
    shell:
        r"""
        exec 2> {log}
        seqkit seq -s {input} \
          | grep -oP '(?<={params.left})[ACGTN]+(?={params.right})' \
          > {output} || [ $? -eq 1 ]
        """


rule bowtie_map:
    """Map inserts to the theoretical Twist barcode library."""
    input:
        inserts="trimmed/{sample}.inserts.txt",
        index=multiext(
            config["barcode_index"],
            ".1.ebwt", ".2.ebwt", ".3.ebwt", ".4.ebwt",
            ".rev.1.ebwt", ".rev.2.ebwt",
        ),
    output:
        "mapped/{sample}_Twist_library_mapped.bowtie",
    params:
        prefix=config["barcode_index"],
        extra=config.get("bowtie_extra", ""),
    threads: 8
    conda:
        "../envs/bowtie.yaml"
    log:
        "logs/bowtie_map/{sample}.log",
    shell:
        "bowtie -r -p {threads} {params.extra} -x {params.prefix} {input.inserts} > {output} 2> {log}"


rule count_barcodes:
    """Tally reads per reference barcode."""
    input:
        "mapped/{sample}_Twist_library_mapped.bowtie",
    output:
        "final_counts/{sample}_Twist_BC_count.txt",
    log:
        "logs/count_barcodes/{sample}.log",
    shell:
        "awk -F'\\t' '{{print $3}}' {input} | sort | uniq -c > {output} 2> {log}"
