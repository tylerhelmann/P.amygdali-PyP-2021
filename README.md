# P.amygdali-PyP-2021
PyParanoid summary of Pseudomonas amygdali

#### Creation of a gene homology database of *Pseudomonas amygdali* strains. 

Focus: novel isolate = putative *Pseudomonas amygdali*.   
Skip to [results](P_amygdali_db/)

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

~~~ bash
mv genomedb/pep/GCF_000007805.1_ASM780v1_protein.faa \
genomedb/pep/Pseudomonas_syringae_DC3000.pep.fa
mv genomedb/pep/GCF_000012245.1_ASM1224v1_protein.faa \
genomedb/pep/Pseudomonas_syringae_B728a.pep.fa
~~~

#### Set up PyParanoid directory within working directory

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
Training dataset is all genomes where assembly_level = "Complete Genome".  
Propagation dataset is all additional genomes.  
Note: duplicates are found in prop\_strainlist, though accession values are unique. 

~~~ r
R
> source("src/strain_selection.R")
> q()
~~~

Add *P. syringae* controls and strain of interest to core strainlist.

~~~ bash
echo "Pseudomonas_amygdali_Hibiscus.pep.fa" >> genomedb/strainlist.txt
echo "Pseudomonas_syringae_B728a.pep.fa" >> genomedb/strainlist.txt
echo "Pseudomonas_syringae_DC3000.pep.fa" >> genomedb/strainlist.txt
~~~

- [strainlist.txt](genomedb/strainlist.txt)
- [prop_strainlist.txt](genomedb/prop_strainlist.txt)

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

~~~

#### Propagate groups to new draft genomes.

~~~ bash
PropagateGroups.py --cpus 4 genomedb/ \
genomedb/prop_strainlist.txt amygdali_db
~~~
~~~

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

Additional output files not uploaded due to size:

- all_groups.hmm (?)
- homolog.faa (?)
- prop_homolog.faa (?)
