# P.amygdali-PyP-2021
PyParanoid summary of *Pseudomonas amygdali*.

#### Creation of a gene homology database of *Pseudomonas amygdali* strains. 

Novel isolate = putative *Pseudomonas amygdali* pv. *hibisci* strain 35-1.   
Skip to [results](amygdali_db/).  

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

Assemblies downloaded 9/12/2021, using NCBI "datasets" tool.  
(+ Unzip.)

~~~ bash
../../Scripts/datasets download genome taxon 47877 \
--filename P_amygdali.zip
~~~
~~~
Downloading: P_amygdali.zip    553MB done
~~~

Few complete genomes available within this species:  
- Complete Genome (7)  
- Scaffold (51)          
- Contig (27)    

#### Set up PyParanoid directory within working directory.

~~~ bash
git clone https://github.com/ryanmelnyk/PyParanoid
~~~

~~~ python
python3

import pyparanoid.genomedb as gdb
gdb.setupdirs("genomedb")
exit()
~~~

#### Create peptide database for PyParanoid.

All peptide sequence files should be in genomedb/pep. PyParanoid also requires a strainlist, which should be a text file containing the names of the strains to include in the analysis, one per line.  
Note: In strainlist, only underscores, letters, and numbers are permitted. These should match up with the prefixes of the files in the pep folder.

List available assemblies. (Sometimes some are missing.)

~~~ bash
ls ncbi_dataset/data/ > ncbi_dataset/available_assemblies.txt
~~~

Create strainlists, and copy all pep.fa files into genomedb/pep.  
strainlist.txt is all genomes where assembly_level = "Complete Genome".* 
prop_strainlist.txt is all genomes where assembly_level = "Scaffold".

~~~ r
R
> source("src/strain_selection.R")
> q()
~~~

Add *P. syringae* controls and strain of interest to core strainlist.

~~~ bash
echo "Pseudomonas_amygdali_35-1" >> genomedb/strainlist.txt
echo "Pseudomonas_syringae_B728a" >> genomedb/strainlist.txt
echo "Pseudomonas_syringae_DC3000" >> genomedb/strainlist.txt
echo "Pseudomonas_savastanoi_1448A" >> genomedb/strainlist.txt
~~~

- [strainlist.txt](amygdali_db/strainlist.txt)
- [prop_strainlist.txt](amygdali_db/prop_strainlist.txt)

**Edit**: Add prop_strainlist.txt genomes to strainlist.txt and run all-vs-all comparison instead of sequential.

~~~ bash
cat genomedb/prop_strainlist.txt >> genomedb/strainlist.txt
~~~

Copy all relevant [NCBI downloaded] peptide sequences.

~~~ bash
chmod +x src/cp_faa.sh
./src/cp_faa.sh
~~~

#### Download additional reference strains.

- *P. syringae* pv. *tomato* DC3000 (GCF_000007805.1)
- *P. syringae* pv. *syringae* B728a (GCF_000012245.1)
- *P. savastanoi* pv. *phaseolicola* 1448A (GCF_000012205.1)

~~~ bash
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/007/805/GCF_000007805.1_ASM780v1/GCF_000007805.1_ASM780v1_protein.faa.gz \
-O genomedb/pep/Pseudomonas_syringae_DC3000.pep.fa.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/012/245/GCF_000012245.1_ASM1224v1/GCF_000012245.1_ASM1224v1_protein.faa.gz \
-O genomedb/pep/Pseudomonas_syringae_B728a.pep.fa.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/012/205/GCF_000012205.1_ASM1220v1/GCF_000012205.1_ASM1220v1_protein.faa.gz \
-O genomedb/pep/Pseudomonas_savastanoi_1448A.pep.fa.gz

gunzip genomedb/pep/*pep.fa.gz
~~~

#### Copy proteome of interest into genomedb/pep.

~~~ bash
cp Pseudomonas_amygdali_35-1.pep.fa \
genomedb/pep/Pseudomonas_amygdali_35-1.pep.fa
~~~

#### Build genome database.

~~~ bash
BuildGroups.py --clean --verbose  --cpus 8 genomedb/ \
genomedb/strainlist.txt amygdali_db
~~~

~~~
Formatting 61 fasta files...
Making diamond databases for 61 strains...
Running DIAMOND on all 61 strains...
	Done!
Getting gene lengths...
Parsing diamond results for 61 strains...
	Done!
Running InParanoid on 1830 pairs of strains...
Sequential mode...
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
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/out
Parsing 1830 output files.
	1000 remaining...
	Done!
.................................................. 1M
.................................................. 2M
.................................................. 3M
.................................................. 4M
.................................................. 5M
.................................................. 6M
.................................................. 7M
.................................................. 8M
.........
[mclIO] writing </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.mci>
.......................................
[mclIO] wrote native interchange 317193x317193 matrix with 16296344 entries to stream </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.mci>
[mclIO] wrote 317193 tab entries to stream </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.tab>
[mcxload] tab has 317193 entries
[mclIO] reading </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/data.mci>
.......................................
[mclIO] read native interchange 317193x317193 matrix with 16296344 entries
[mcl] pid 86781
 ite   chaos  time hom(avg,lo,hi) m-ie m-ex i-ex fmv
  1    22.11 13.21 1.01/0.16/5.29 1.05 1.05 1.05   0
  2    33.02 18446744073721.51 0.99/0.30/3.95 1.11 1.00 1.05   0
  3    42.63 18446744073721.23 0.99/0.17/3.90 1.06 0.98 1.03   0
  4    22.37 14.73 0.98/0.11/7.12 1.03 0.99 1.02   0
  5    22.08 12.70 0.98/0.11/11.35 1.01 0.99 1.01   0
  6    14.22 18446744073720.46 0.97/0.12/13.60 1.01 0.99 0.99   0
  7    12.58 18446744073720.14 0.97/0.08/21.04 1.00 0.99 0.99   0
  8    13.72 12.75 0.98/0.08/37.07 1.00 0.99 0.98   0
  9    13.45 18446744073721.81 0.97/0.08/3.43 1.00 0.99 0.97   0
 10    14.07 14.05 0.98/0.09/1.00 1.00 0.99 0.95   0
 11    13.54 13.81 0.98/0.08/1.00 1.00 0.99 0.94   0
 12    13.44 18446744073720.19 0.98/0.08/1.00 1.00 0.99 0.93   0
 13    13.97 18446744073719.98 0.98/0.08/1.00 1.00 0.99 0.92   0
 14    14.74 13.81 0.99/0.08/1.00 1.00 0.98 0.90   0
 15    14.16 13.46 0.99/0.11/1.00 1.00 0.99 0.89   0
 16     5.90 18446744073719.84 1.00/0.37/1.00 1.00 1.00 0.89   0
 17     3.64 11.59 1.00/0.28/1.00 1.00 0.99 0.88   0
 18     4.39 11.91 1.00/0.16/1.00 1.00 1.00 0.88   0
 19     4.82 18446744073719.82 1.00/0.46/1.00 1.00 1.00 0.88   0
 20     1.37 11.78 1.00/0.59/1.00 1.00 1.00 0.88   0
 21     2.59 18446744073719.72 1.00/0.26/1.00 1.00 1.00 0.88   0
 22     6.82 13.47 1.00/0.19/1.00 1.00 1.00 0.88   0
 23     2.25 18446744073719.70 1.00/0.63/1.00 1.00 1.00 0.88   0
 24     1.05 18446744073719.65 1.00/0.45/1.00 1.00 1.00 0.88   0
 25     1.11 11.94 1.00/0.57/1.00 1.00 1.00 0.88   0
 26     0.17 18446744073719.78 1.00/0.88/1.00 1.00 1.00 0.88   0
 27     0.01 13.33 1.00/0.99/1.00 1.00 1.00 0.88   0
 28     0.00 13.56 1.00/1.00/1.00 1.00 1.00 0.88   0
[mcl] cut <1> instances of overlap
[mcl] jury pruning marks: <99,99,99>, out of 100
[mcl] jury pruning synopsis: <99.0 or perfect> (cf -scheme, -do log)
[mclIO] writing </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/mcl.out>
.......................................
[mclIO] wrote native interchange 317193x10963 matrix with 317193 entries to stream </Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/mcl/mcl.out>
[mcl] 10963 clusters found
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
[mclIO] read native interchange 317193x10963 matrix with 317193 entries
Writing fasta files and parsing descriptions...
10964 groups equal to or larger than 2 sequences.
Clustering sequences...
Sequential mode...
	10000 remaining...
	9000 remaining...
	8000 remaining...
	7000 remaining...
	6000 remaining...
	5000 remaining...
	4000 remaining...
	3000 remaining...
	2000 remaining...
	1000 remaining...
	0 remaining...
Aligning groups...
Sequential mode...
	10000 remaining...
	9000 remaining...
	8000 remaining...
	7000 remaining...
	6000 remaining...
	5000 remaining...
	4000 remaining...
	3000 remaining...
	2000 remaining...
	1000 remaining...
	0 remaining...
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/clustered
Building hmms...
Sequential mode...
	10000 remaining...
	9000 remaining...
	8000 remaining...
	7000 remaining...
	6000 remaining...
	5000 remaining...
	4000 remaining...
	3000 remaining...
	2000 remaining...
	1000 remaining...
	0 remaining...
Cleaning up /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/aligned
Emitting consensus sequences...
Sequential mode...
	10000 remaining...
	9000 remaining...
	8000 remaining...
	7000 remaining...
	6000 remaining...
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

(Need to create dummy files.)

~~~ bash
touch amygdali_db/prop_homolog.faa amygdali_db/prop_strainlist.txt
~~~

~~~ bash
IdentifyOrthologs.py amygdali_db amygdali_ortho
~~~

~~~
Parsing matrix to identify orthologs...
2332 orthologs found.
Indexing all_groups.hmm...
Working...    done.
Indexed 10963 HMMs (10963 names).
SSI index written to file /Users/tylerhelmann/Documents/USDA/Projects/P.amygdali-PyP-2021/amygdali_db/all_groups.hmm.ssi
Extracting 2332 HMM files...0 already found.
	2300 remaining...
	2200 remaining...
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
Aligning 2332 ortholog files...
Creating master alignment...Parsing 2332 homologs...
	2300 remaining...
	2200 remaining...
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
61 sequences and 688077 positions in the first alignment file:
amygdali_ortho/master_alignment.faa

amygdali_ortho/master_alignment.faa
Original alignment: 688077 positions
Gblocks alignment:  655152 positions (95 %) in 1121 selected block(s)
~~~

#### Create tree using FastTree2.

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
Ignored unknown character X (seen 24 times)
Initial topology in 26.97 secondshits for      1 of     59 seqs   
Refining topology: 24 rounds ME-NNIs, 2 rounds ME-SPRs, 12 rounds ML-NNIs
Total branch-length 0.121 after 141.62 sec 1 of 57 splits    
ML-NNI round 1: LogLk = -2595733.584 NNIs 6 max delta 106.11 Time 950.68
Switched to using 20 rate categories (CAT approximation)20 of 20   
Rate categories were divided by 0.659 so that average rate = 1.0
CAT-based log-likelihoods may not be comparable across runs
Use -gamma for approximate but comparable Gamma(20) log-likelihoods
ML-NNI round 2: LogLk = -2547064.755 NNIs 4 max delta 274.70 Time 1881.76
ML-NNI round 3: LogLk = -2547064.595 NNIs 0 max delta 0.00 Time 1988.74
Turning off heuristics for final round of ML NNIs (converged)
ML-NNI round 4: LogLk = -2547064.149 NNIs 2 max delta 0.04 Time 2570.28 (final)
Optimize all lengths: LogLk = -2547064.126 Time 2771.08
Total time: 3716.74 seconds Unique: 59/61 Bad splits: 0/56
~~~

Set *P. syringae* B728a as root for [tree](amygdali_ortho/amygdali.tree).

#### Create tree using RAxML.

Use same input as FastTree: amygdali\_ortho/master\_alignment.faa-gb

System: Linux (CentOS 7.6) 64-core 512 GB.

~~~
export PATH=/programs/RAxML-8.2.12:$PATH

raxmlHPC-PTHREADS -T 64 -f a -m PROTGAMMAAUTO \
-p 12345 -x 12345 -# 100 -s master_alignment.faa-gb \
-n T1 -o Pseudomonas_syringae_B728a
~~~

Results: [RAxML/](RAxML/)  
[log](RAxML/RAxML_info.T1)
