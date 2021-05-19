# P.amygdali-PyP-2021
PyParanoid summary of *Pseudomonas amygdali*.

#### Creation of a gene homology database of *Pseudomonas amygdali* strains. 

Focus: novel isolate = putative *Pseudomonas amygdali "Hibiscus"*.   
Skip to [results](amygdali_db/)
3
PyParanoid citation: 

Melnyk, R.A., Hossain, S.S. & Haney, C.H. Convergent gain and loss of genomic islands drive lifestyle changes in plant-associated Pseudomonas. ISME J 13, 1575–1588 (2019). DOI: [10.1038/s41396-019-0372-5](https://doi.org/10.1038/s41396-019-0372-5)

##### Dependencies.

System: macOS Catalina (10.15.7) (4 cores).  
For OSX, install using Homebrew.

~~~ bash
brew tap brewsci/bio
brew install diamond
brew install hmmer
brew install mcl
brew install cd-hit
brew install muscle
~~~

Versions used here:

- cd-hit 4.8.1_1
- diamond 0.9.36
- hmmer 3.3.1
- mcl 14-137
- muscle 3.8.1551

### Database setup.

#### Copy proteome of interest into genomedb/pep.

~~~ bash
mv genomedb/pep/Hibiscus_isolate_annotated.faa \
genomedb/pep/Pseudomonas_amygdali_Hibiscus.pep.fa
~~~

#### Download NCBI RefSeq genome metadata.

~~~ bash
curl ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt \
-o ncbi_metadata.txt

# Extract header.
head -n 2 ncbi_metadata.txt | tail -n 1 | \
sed 's/# //' > ncbi_header.txt
# Extract P. amygdali data.
grep amygdali ncbi_metadata.txt > ncbi_amygdali_temp.txt
# Combine.
cat ncbi_header.txt ncbi_amygdali_temp.txt > ncbi_amygdali.txt

# Clean up.
rm ncbi_metadata.txt ncbi_header.txt ncbi_amygdali_temp.txt
~~~

#### Download NCBI assemblies for these strains. 

Assemblies downloaded 5/4/2021, using NCBI "datasets" tool.  
(+ Unzip.)

~~~ bash
../../Scripts/datasets download genome taxon 47877 \
--filename P_amygdali.zip
~~~
~~~
Downloading: P_amygdali.zip    521MB done
~~~

Few complete genomes available within this species:  
- Complete Genome (4)  
- Scaffold (51)          
- Contig (27)    

#### Download additional strains for outgroups.

- *P. syringae* pv. *tomato* DC3000 (GCF_000007805.1)
- *P. syringae* pv. *syringae* B728a (GCF_000012245.1)
- *P. savastanoi* pv. *phaseolicola* 1448A (GCF_000012205.1)

~~~ bash
mv genomedb/pep/GCF_000007805.1_ASM780v1_protein.faa \
genomedb/pep/Pseudomonas_syringae_DC3000.pep.fa
mv genomedb/pep/GCF_000012245.1_ASM1224v1_protein.faa \
genomedb/pep/Pseudomonas_syringae_B728a.pep.fa
mv genomedb/pep/GCF_000012205.1_ASM1220v1_protein.faa \
genomedb/pep/Pseudomonas_savastanoi_1448A.pep.fa
~~~

#### Set up PyParanoid directory within working directory.

~~~ bash
git clone https://github.com/ryanmelnyk/PyParanoid
~~~

~~~ python
python3
>>>import pyparanoid.genomedb as gdb
>>>gdb.setupdirs("genomedb")
>>>exit()
~~~

#### Create peptide database for PyParanoid.

All peptide sequence files should be in genomedb/pep. PyParanoid also requires a strainlist, which should be a text file containing the names of the strains to include in the analysis, one per line.  
Note: In strainlist, only underscores, letters, and numbers are permitted. These should match up with the prefixes of the files in the pep folder.

List available assemblies. (Sometimes some are missing.)

~~~ bash
ls ncbi_dataset/data/ > ncbi_dataset/available_assemblies.txt
~~~

Create strainlists, and copy all pep.fa files into genomedb/pep.  
**Training dataset is all genomes where assembly_level = "Complete Genome".**  
Propagation dataset is all additional genomes.  
Note: duplicates are found in prop\_strainlist, though accession values are unique. 

~~~ r
R
> source("src/strain_selection.R")
> q()
~~~

Add *P. syringae* controls and strain of interest to core strainlist.

~~~ bash
echo "Pseudomonas_amygdali_Hibiscus" >> genomedb/strainlist.txt
echo "Pseudomonas_syringae_B728a" >> genomedb/strainlist.txt
echo "Pseudomonas_syringae_DC3000" >> genomedb/strainlist.txt
echo "Pseudomonas_savastanoi_1448A" >> genomedb/strainlist.txt
~~~

#### Troubleshooting edit.

Removed *P. amygdali* pv. *dendropanacis* CFBP 3226 from prop\_strainlist.txt because appears to be duplicated.  
(NCBI: GCF\_000935735.1 and GCF\_001538145.1)

- [strainlist.txt](amygdali_db/strainlist.txt)
- [prop_strainlist.txt](amygdali_db/prop_strainlist.txt)

Copy all [NCBI downloaded] peptide sequences.

~~~ bash
chmod +x src/cp_faa.sh
./src/cp_faa.sh
~~~

#### Build genome database from training dataset.

~~~ bash
BuildGroups.py --clean --verbose  --cpus 4 genomedb/ \
genomedb/strainlist.txt amygdali_db
~~~
~~~
Formatting 8 fasta files...
Making diamond databases for 8 strains...
Running DIAMOND on all 8 strains...
	Done!
Getting gene lengths...
Parsing diamond results for 8 strains...
	Done!
Running InParanoid on 28 pairs of strains...
Sequential mode...
        0 remaining...
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/out
Parsing 28 output files.
	Done!
......[mclIO] writing </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.mci>
.......................................
[mclIO] wrote native interchange 39388x39388 matrix with 250222 entries to stream </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.mci>
[mclIO] wrote 39388 tab entries to stream </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.tab>
[mcxload] tab has 39388 entries
[mclIO] reading </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.mci>
.......................................
[mclIO] read native interchange 39388x39388 matrix with 250222 entries
[mcl] pid 57759
 ite   chaos  time hom(avg,lo,hi) m-ie m-ex i-ex fmv
  1     1.98  0.13 1.00/0.41/2.32 1.02 1.02 1.02   0
  2     2.76  0.14 0.99/0.54/1.37 1.01 1.01 1.03   0
  3     4.16  0.14 0.99/0.30/1.93 1.00 1.00 1.02   0
  4     5.43 18446744073709.64 0.99/0.29/3.43 1.00 0.99 1.02   0
  5     2.50  0.15 0.99/0.32/3.47 1.00 0.99 1.01   0
  6     3.54  0.14 0.99/0.19/2.58 1.00 0.99 1.00   0
  7     7.19  0.15 0.99/0.28/1.04 1.00 0.99 0.98   0
  8     1.45  0.14 1.00/0.36/1.03 1.00 0.99 0.98   0
  9     0.74  0.19 1.00/0.57/1.01 1.00 0.99 0.97   0
 10     0.74  0.13 1.00/0.63/1.00 1.00 1.00 0.97   0
 11     1.27  0.14 1.00/0.48/1.00 1.00 1.00 0.96   0
 12     1.47 18446744073709.64 1.00/0.57/1.00 1.00 1.00 0.96   0
 13     0.81  0.15 1.00/0.55/1.00 1.00 1.00 0.96   0
 14     1.46  0.15 1.00/0.42/1.00 1.00 1.00 0.96   0
 15     1.37  0.14 1.00/0.61/1.00 1.00 1.00 0.96   0
 16     0.27  0.15 1.00/0.82/1.00 1.00 1.00 0.96   0
 17     0.03  0.14 1.00/0.98/1.00 1.00 1.00 0.96   0
 18     0.00  0.14 1.00/1.00/1.00 1.00 1.00 0.96   0
[mcl] cut <4> instances of overlap
[mcl] jury pruning marks: <100,99,99>, out of 100
[mcl] jury pruning synopsis: <99.6 or perfect> (cf -scheme, -do log)
[mclIO] writing </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/mcl.out>
.......................................
[mclIO] wrote native interchange 39388x5862 matrix with 39388 entries to stream </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/mcl.out>
[mcl] 5862 clusters found
[mcl] output is in /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/mcl.out

Please cite:
    Stijn van Dongen, Graph Clustering by Flow Simulation.  PhD thesis,
    University of Utrecht, May 2000.
       (  http://www.library.uu.nl/digiarchief/dip/diss/1895620/full.pdf
       or  http://micans.org/mcl/lit/svdthesis.pdf.gz)
OR
    Stijn van Dongen, A cluster algorithm for graphs. Technical
    Report INS-R0010, National Research Institute for Mathematics
    and Computer Science in the Netherlands, Amsterdam, May 2000.
       (  http://www.cwi.nl/ftp/CWIreports/INS/INS-R0010.ps.Z
       or  http://micans.org/mcl/lit/INS-R0010.ps.Z)

[mclIO] reading </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/mcl.out>
.......................................
[mclIO] read native interchange 39388x5862 matrix with 39388 entries
Writing fasta files and parsing descriptions...
5863 groups equal to or larger than 2 sequences.
Clustering sequences...
Sequential mode...
	5000 remaining...
	4000 remaining...
	3000 remaining...
	2000 remaining...
	1000 remaining...
	0 remaining...
Aligning groups...
Sequential mode...
	5000 remaining...
	4000 remaining...
	3000 remaining...
	2000 remaining...
	1000 remaining...
	0 remaining...
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/clustered
Building hmms...
Sequential mode...
	5000 remaining...
	4000 remaining...
	3000 remaining...
	2000 remaining...
	1000 remaining...
	0 remaining...
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/aligned
Emitting consensus sequences...
Sequential mode...
	5000 remaining...
	4000 remaining...
	3000 remaining...
	2000 remaining...
	1000 remaining...
	0 remaining...
Writing multi-hmm file...
Writing multi-fasta consensus file...
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/hmms
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/consensus_seqs
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/m8
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/paranoid_output
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/dmnd_tmp
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/faa
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/homolog_faa
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl
~~~

#### Propagate groups to new draft genomes.

~~~ bash
PropagateGroups.py --cpus 4 genomedb/ \
genomedb/prop_strainlist.txt amygdali_db
~~~
~~~
Making diamond databases for 72 strains...
	70 remaining...
	60 remaining...
	50 remaining...
	40 remaining...
	30 remaining...
	20 remaining...
	10 remaining...
	Done!
Running diamond on all 72 strains...
	70 remaining...
	60 remaining...
	50 remaining...
	40 remaining...
	30 remaining...
	20 remaining...
	10 remaining...
	Done!
Getting gene lengths...
Parsing diamond results...
	210 remaining...
	200 remaining...
	190 remaining...
	180 remaining...
	170 remaining...
	160 remaining...
	150 remaining...
	140 remaining...
	130 remaining...
	120 remaining...
	110 remaining...
	100 remaining...
	90 remaining...
	80 remaining...
	70 remaining...
	60 remaining...
	50 remaining...
	40 remaining...
	30 remaining...
	20 remaining...
	10 remaining...
	Done!
Running inparanoid on 72 strains...
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/prop_m8
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/prop_out
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/prop_dmnd
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/prop_paranoid_output
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/prop_faa
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/prop_homolog_faa
~~~

Output:

- [strainlist.txt](amygdali_db/strainlist.txt)
- [prop_strainlist.txt](amygdali_db/prop_strainlist.txt)
- [clusterstats.out](amygdali_db/clusterstats.out)  
- [Homolog matrix](amygdali_db/homolog_matrix.txt)  
- [Locustag matrix](amygdali_db/locustag_matrix.txt)  
- [Group descriptions](amygdali_db/group_descriptions.txt)
- [Consensus sequences](amygdali_db/all_groups.faa)
- [Diamond output](amygdali_db/all_groups.dmnd)

Additional output files not uploaded:

- all_groups.hmm
- homolog.faa
- prop_homolog.faa

#### Make tree.

Create an alignment of all [single-copy ortholog groups](amygdali_ortho/orthos.txt). 

~~~ bash
IdentifyOrthologs.py amygdali_db amygdali_ortho
~~~

~~~
Parsing matrix to identify orthologs...
2136 orthologs found.
Indexing all_groups.hmm...
Working...    done.
Indexed 5862 HMMs (5862 names).
SSI index written to file /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/all_groups.hmm.ssi
Extracting 2136 HMM files...0 already found.
	2100 remaining...
	2000 remaining...
	1900 remaining...
	1800 remaining...
	1700 remaining...
	1600 remaining...
	1500 remaining...
	1400 remaining...
	1300 remaining...
	1200 remaining...
	1100 remaining...
	1000 remaining...
	900 remaining...
	800 remaining...
	700 remaining...
	600 remaining...
	500 remaining...
	400 remaining...
	300 remaining...
	200 remaining...
	100 remaining...
	0 remaining...
	Done!
Parsing homolog.faa...
Parsing prop_homolog.faa...
Aligning 2136 ortholog files...
Creating master alignment...Parsing 2136 homologs...
	2100 remaining...
	2000 remaining...
	1900 remaining...
	1800 remaining...
	1700 remaining...
	1600 remaining...
	1500 remaining...
	1400 remaining...
	1300 remaining...
	1200 remaining...
	1100 remaining...
	1000 remaining...
	900 remaining...
	800 remaining...
	700 remaining...
	600 remaining...
	500 remaining...
	400 remaining...
	300 remaining...
	200 remaining...
	100 remaining...
	0 remaining...
Done!
Writing alignment...
~~~

Trim alignment using Gblocks. 

~~~ bash
 ../../Scripts/Gblocks amygdali_ortho/master_alignment.faa -t p
~~~

~~~
80 sequences and 620731 positions in the first alignment file:
amygdali_ortho/master_alignment.faa

amygdali_ortho/master_alignment.faa
Original alignment: 620731 positions
Gblocks alignment:  589316 positions (94 %) in 1029 selected block(s)
~~~

Create tree using FastTree2.

~~~ bash
../../Scripts/FastTree \
< amygdali_ortho/master_alignment.faa-gb \
> amygdali_ortho/amygdali.tree
~~~

~~~
FastTree Version 2.1.11 No SSE3
Alignment: standard input
Amino acid distances: BLOSUM45 Joins: balanced Support: SH-like 1000
Search: Normal +NNI +SPR (2 rounds range 10) +ML-NNI opt-each=1
TopHits: 1.00*sqrtN close=default refresh=0.80
ML Model: Jones-Taylor-Thorton, CAT approximation with 20 rate categories
Ignored unknown character X (seen 22 times)
Initial topology in 34.63 secondshits for      1 of     74 seqs   
Refining topology: 25 rounds ME-NNIs, 2 rounds ME-SPRs, 12 rounds ML-NNIs
Total branch-length 0.120 after 181.21 sec 1 of 72 splits    

WARNING! This alignment consists of closely-related and very-long sequences.
This version of FastTree may not report reasonable branch lengths!
Consider recompiling FastTree with -DUSE_DOUBLE.
For more information, visit
http://www.microbesonline.org/fasttree/#BranchLen

WARNING! FastTree (or other standard maximum-likelihood tools)
may not be appropriate for aligments of very closely-related sequences
like this one, as FastTree does not account for recombination or gene conversion

ML-NNI round 1: LogLk = -2336646.793 NNIs 7 max delta 185.89 Time 1133.83
Switched to using 20 rate categories (CAT approximation)20 of 20   
Rate categories were divided by 0.658 so that average rate = 1.0
CAT-based log-likelihoods may not be comparable across runs
Use -gamma for approximate but comparable Gamma(20) log-likelihoods
ML-NNI round 2: LogLk = -2294982.216 NNIs 4 max delta 0.09 Time 2247.69
Turning off heuristics for final round of ML NNIs (converged)
ML-NNI round 3: LogLk = -2294982.041 NNIs 1 max delta 0.00 Time 2930.86 (final)
Optimize all lengths: LogLk = -2294982.056 Time 3166.96
Total time: 4223.11 seconds Unique: 74/80 Bad splits: 0/71
~~~

Set *P. syringae* B728a as root for [tree](amygdali_ortho/amygdali.tree).

