#!/bin/bash -l
#SBATCH --time=1:00:00
#SBATCH --ntasks=32
#SBATCH --mem=60g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=levin252@umn.edu
#SBATCH --job-name=Nsg2-snATAC-bigwigs

# sbatch ./scripts/Nsg2_brain/snATAC-cell-Nsg2-bigwigs_20220705.sh
echo "This log documents a script used to 'crop' bigwig signal files (generated from MACS2) of single nuclei ATAC-seq signal aggregated across cell clusters in the mouse brain. Specifically, we wanted to compare accessibility around the gene Nsg2 to see if Nsg2 gene/enhancers are more open/active in certain cell types than others."
echo ""

# Load environment modules
echo "$ conda activate deeptols"
echo "$ module load parallel/20210822"
conda activate deeptools
module load parallel/20210822
sleep 3
echo ""

# Set the folder variables and key parameters
infolder="/home/slattery/levin252/data/Nsg2_brain/original_bigwigs"
outfolder="/home/slattery/levin252/data/Nsg2_brain/bigwigs"
chrom_sizes="/panfs/roc/risdb/genomes/Mus_musculus/mm10/seq/mm10.len"
region_chrom="chr11"
region_start=31865000
region_end=32065000

# Display these variables
echo ""
echo "# Check environment variables/key parameters"
echo "$ infolder=\"$infolder\""
echo "$ outfolder=\"$outfolder\""
echo "$ chrom_sizes=\"\""
echo "$ region_chrom=\"$region_chrom\""
echo "$ region_start=$region_start"
echo "$ region_end=$region_end"
echo ""

# Output bigWigToWig and wigToBigWig versions used
echo ""
echo "# Check software versions:"
echo ""
bigWigToWig
echo ""
wigToBigWig
echo ""

# Filtering reads to only look at region nearby Nsg2 gene
echo ""
echo "# The following is example code of the settings used with deeptools to isolate only specific regions of bigwig:"
printf "$ bigWigToWig -chrom=\"$region_chrom\" -start=$region_start -end=$region_end \\ \n\tfull-bigwig-file.bw cropped-wig-file.wig\n"
echo ""

# Converting back to bigwig
echo ""
echo "# The following is example code of the settings used with deeptools to convert the wig back to bigwig format:"
printf "$ wigToBigWig cropped-wig-file.wig $chom_sizes cropped-bigwig-file.bigwig\n"
echo ""


# Make bigWig again from bedGraphs
echo "# Now execute loop to 'crop' bigwigs to region around Nsg2 using code from above"
echo ""

echo "$ cd $infolder"
cd "$infolder"
echo ""

# For loop for merged files
for file in `ls *.bw`
do
    # Set naming variables
    name=${file/.bw/}
    
    # "Progress bar"
    echo "# Timestamp:"
    date
    echo ""
    
    # mention file
    echo "# Working on $name."
    echo ""

    echo "# Crop the bigwig."
    bigWigToWig -chrom="$region_chrom" -start=$region_start -end=$region_end \
        "$file" "${name}.wig" # This step is almost instantaneous
    echo ""

    # Now convert back to bigwig
    echo "# Convert WIG back to bigWig."
    wigToBigWig "${name}.wig" "$chrom_sizes" "${outfolder}/${name}_Nsg2-region.bigwig" # This step takes ~20 min
    echo ""

    # Clean up
    rm "${name}.wig"
done

echo "# Finished all at:"
date