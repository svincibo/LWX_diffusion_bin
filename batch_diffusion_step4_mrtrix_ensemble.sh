#!/bin/bash

#PBS -k o
#PBS -l nodes=1:ppn=16,walltime=6:00:00
#PBS -N lwx_sub206_tracking
#PBS -M svincibo@indiana.edu

# Brent McPherson 
# 20151218
# create an ensemble of whole brain fibers
# edited by Sophia Vinci-Booher, 01/2017

# module calls
module unload mrtrix/0.3.12
module load mrtrix/0.2.12

# build paths and file names
subID='206' #'101 103 105 203 204 206 301 302 303 304 306'

for i in $subID; do

# Set file paths. Note that the dwifilename is the output from dtiInit in the subject diffusion folder.
DWIFILENAME=data_b1000_aligned_trilin_noMEC
BFILENAME=data_b1000
TOPDIR=/N/dc2/projects/lifebid/development/sub${i}
ANATDIR=/N/dc2/projects/lifebid/development/sub${i}/anatomical
DIFFDIR=/N/dc2/projects/lifebid/development/sub${i}/diffusion
OUTDIR=$TOPDIR/diffusion/fibers
# Set tracking parameters.
NUMFIBERS=500000
MAXNUMFIBERSATTEMPTED=1000000

## =====PREPROCESSING=====

# convert wm mask to mrtrix format (i.e., .mif)
mrconvert $ANATDIR/wm_mask.nii.gz $OUTDIR/${DWIFILENAME}_wm.mif
# convert dwi's to mrtrix format (i.e., .mif)
mrconvert $TOPDIR/diffusion/$DWIFILENAME.nii.gz $OUTDIR/${DWIFILENAME}_dwi.mif
# make _brainmask.mif from DWI data
average $OUTDIR/${DWIFILENAME}_dwi.mif -axis 3 - | threshold - - | median3D - - | median3D - $OUTDIR/${DWIFILENAME}_brainmask.mif

## =====Perform TENSOR fit at each white matter voxel and get FA and MD maps.=====

# fit tensors using _dwi.mif and .b files... output is _dt.mif. Note that the .b file is NOT the .bvals file.
dwi2tensor $OUTDIR/${DWIFILENAME}_dwi.mif -grad $OUTDIR/${BFILENAME}.b $OUTDIR/${DWIFILENAME}_dt.mif 
# FA: create FA image using the tensor fit (i.e., _dt.mif) image and multiply it by the brain mask (i.e., _brainmask.mif) to get the FA (i.e., _fa.mif) image for only the brain
tensor2FA $OUTDIR/${DWIFILENAME}_dt.mif - | mrmult - $OUTDIR/${DWIFILENAME}_brainmask.mif $OUTDIR/${DWIFILENAME}_fa.mif
# MD: create eigenvector map: _ev.mif is the output image of the major eigenvector
tensor2vector $OUTDIR/${DWIFILENAME}_dt.mif - | mrmult - $OUTDIR/${DWIFILENAME}_fa.mif $OUTDIR/${DWIFILENAME}_ev.mif

## =====Estimate deconvolution kernel: Estimate the kernel for deconvolution, using voxels with highest FA.=====

#erodes brainmask - removes extreme artifacts (w/ high FA, here >0.7), creates FA image, AND single fiber mask 
erode $OUTDIR/${DWIFILENAME}_brainmask.mif -npass 3 - | mrmult $OUTDIR/${DWIFILENAME}_fa.mif - - | threshold - -abs 0.7 $OUTDIR/${DWIFILENAME}_sf.mif
# estimates the fiber response function for use in spherical deconvolution
estimate_response $OUTDIR/${DWIFILENAME}_dwi.mif $OUTDIR/${DWIFILENAME}_sf.mif -lmax 6 -grad $OUTDIR/${BFILENAME}.b $OUTDIR/${DWIFILENAME}_response.txt

## =====Perform CSD fit in each white matter voxel using different lmax.=====
# I will only estimate up to lmax=6, because my data only have 43 directions.
for i_lmax in 2 4 6; do
    csdeconv $OUTDIR/${DWIFILENAME}_dwi.mif -grad $OUTDIR/${BFILENAME}.b $OUTDIR/${DWIFILENAME}_response.txt -lmax $i_lmax -mask $OUTDIR/${DWIFILENAME}_brainmask.mif $OUTDIR/${DWIFILENAME}_lmax${i_lmax}.mif
done 

## =====TRACKING=====

# Deterministic tracking.
streamtrack DT_STREAM $OUTDIR/${DWIFILENAME}_dwi.mif \
                      $OUTDIR/${DWIFILENAME}_wm_tensor-$NUMFIBERS.tck \
                -seed $OUTDIR/${DWIFILENAME}_wm.mif \
                -mask $OUTDIR/${DWIFILENAME}_wm.mif \
                -grad $OUTDIR/${BFILENAME}.b \
	      -number $NUMFIBERS \
              -maxnum $MAXNUMFIBERSATTEMPTED

# Probabilistic tracking using CSD.
# loop over tracking and lmax
for c in SD_STREAM SD_PROB; do
    for d in 2 4 6; do
	
	streamtrack $c $OUTDIR/${DWIFILENAME}_lmax${d}.mif \
	               $OUTDIR/${DWIFILENAME}_csd_lmax${d}_wm_${c}-$NUMFIBERS.tck \
                 -seed $OUTDIR/${DWIFILENAME}_wm.mif \
		 -mask $OUTDIR/${DWIFILENAME}_wm.mif \
                 -grad $OUTDIR/${BFILENAME}.b \
               -number $NUMFIBERS \
	       -maxnum $MAXNUMFIBERSATTEMPTED

    done
done

done

