#! bash

# Requires HMMER. http://hmmer.org/

# Usage: 
# Argument 1 = List of ortholog groups to use.
# Argument 2 = Name of PyParanoid database.

ALL_GROUPS=$1
DB=$2

echo "Temp directories removed after run. Multiplexing will fail."
echo "Orthologs file = " $ALL_GROUPS
echo "PyP database = " $DB

# Make temp directories.

mkdir -p temp/hmm_consensus
mkdir -p temp/hmm_groups
mkdir -p hmm_alignments/

# Create alignment for each ortholog group.

for group in $(cat $ALL_GROUPS); do

echo ${group}

# Fetch HMM consensus seqeunce for ortholog group.
hmmfetch ${DB}/all_groups.hmm $group > \
temp/hmm_consensus/${group}.hmm

# Select amino acid sequences from each strain for group.
# Assumes prop_homolog.faa is longer than homolog.faa.
cat ${DB}/homolog.faa | \
grep -A 1 ${group} | \
grep -v '^--' > \
temp/hmm_groups/${group}_temp1.faa &

cat ${DB}/prop_homolog.faa | \
grep -A 1 ${group} | \
grep -v '^--' > \
temp/hmm_groups/${group}_temp2.faa

# Combine temp fasta files and save.
cat temp/hmm_groups/${group}_temp1.faa \
temp/hmm_groups/${group}_temp2.faa > \
temp/hmm_groups/${group}.faa

# Remove temp files.
rm temp/hmm_groups/${group}_temp1.faa
rm temp/hmm_groups/${group}_temp2.faa

# Remove all text from defline except for strain name.
cat temp/hmm_groups/${group}.faa | sed 's/|.*//' > \
temp/hmm_groups/${group}b.faa

# Align all amino acid sequences to HMM conensus. 
hmmalign temp/hmm_consensus/${group}.hmm \
temp/hmm_groups/${group}b.faa \
> hmm_alignments/${group}.hmm

# Convert alignment to afa format.
esl-reformat afa hmm_alignments/${group}.hmm \
> hmm_alignments/${group}.afa

done

# Remove temp directories and contents.
echo "Cleaning up..."
rm -r temp/
