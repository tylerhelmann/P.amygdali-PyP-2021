## Creating a multiple sequence alignment using HMMER

Target: *P. amygdali* clade and selected outgroups.

#### List all single-copy ortholog groups.

~~~ r
R
source("src/single_copy_ortholog.R")
homolog_matrix <- read.delim("amygdali_db/homolog_matrix.txt", 
	header=T)
single_copy_rows <- sapply(1:nrow(homolog_matrix),
	single_copy_ortholog, matrix = homolog_matrix)
write(homolog_matrix[which(single_copy_rows), "X"],
	file = "amygdali_db/single_copy_groups.txt")
q()
~~~

[single\_copy\_groups.txt](amygdali_db/single_copy_groups.txt)  
2131 single-copy groups in all strains. 

#### Construct an alignment for each ortholog.

~~~ bash
chmod +x src/create_hmm_alignment.sh

./src/create_hmm_alignment.sh \
amygdali_db/single_copy_groups.txt amygdali_db
~~~
~~~
Temp directories removed after run. Multiplexing will fail.
Orthologs file =  amygdali_db/single_copy_groups.txt
PyP database =  amygdali_db
group_00066
group_00067
group_00068
...
group_03711
group_03712
group_03715
Cleaning up...
~~~

#### Combine all alignments.

~~~ bash
../../Scripts/concat-afas.pl \
$(ls hmm_alignments/*afa) \
> hmm_alignments/all.afa
~~~

#### Trim MSA and construct tree.

Gblocks trimming, no gaps allowed. 

~~~ bash
../../Scripts/Gblocks hmm_alignments/all.afa -t=p
~~~
~~~
80 sequences and 622808 positions in the first alignment file:
hmm_alignments/all.afa

hmm_alignments/all.afa
Original alignment: 622808 positions
Gblocks alignment:  118925 positions (19 %) in 2121 selected block(s)
~~~

Use FastTree to construct tree.

~~~ bash
../../Scripts/FastTree \
< hmm_alignments/all.afa-gb \
> MLSA.tree
~~~
~~~
FastTree Version 2.1.11 No SSE3
Alignment: standard input
Amino acid distances: BLOSUM45 Joins: balanced Support: SH-like 1000
Search: Normal +NNI +SPR (2 rounds range 10) +ML-NNI opt-each=1
TopHits: 1.00*sqrtN close=default refresh=0.80
ML Model: Jones-Taylor-Thorton, CAT approximation with 20 rate categories
Ignored unknown character X (seen 3 times)
Initial topology in 5.60 seconds hits for      1 of     68 seqs   
Refining topology: 24 rounds ME-NNIs, 2 rounds ME-SPRs, 12 rounds ML-NNIs
Total branch-length 0.131 after 26.08 sec, 1 of 66 splits    

WARNING! This alignment consists of closely-related and very-long sequences.
This version of FastTree may not report reasonable branch lengths!
Consider recompiling FastTree with -DUSE_DOUBLE.
For more information, visit
http://www.microbesonline.org/fasttree/#BranchLen

WARNING! FastTree (or other standard maximum-likelihood tools)
may not be appropriate for aligments of very closely-related sequences
like this one, as FastTree does not account for recombination or gene conversion

ML-NNI round 1: LogLk = -479827.639 NNIs 7 max delta 92.92 Time 184.80
Switched to using 20 rate categories (CAT approximation)20 of 20   
Rate categories were divided by 0.660 so that average rate = 1.0
CAT-based log-likelihoods may not be comparable across runs
Use -gamma for approximate but comparable Gamma(20) log-likelihoods
ML-NNI round 2: LogLk = -470934.524 NNIs 4 max delta 0.01 Time 372.57
Turning off heuristics for final round of ML NNIs (converged)
ML-NNI round 3: LogLk = -470934.465 NNIs 3 max delta 0.01 Time 490.41 (final)
Optimize all lengths: LogLk = -470934.468 Time 530.58
Total time: 650.50 seconds Unique: 68/80 Bad splits: 0/65
~~~