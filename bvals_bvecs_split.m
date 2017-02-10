function bvals_bvecs_split(subID, b_vals)
% seperate bvals/bvecs
% build paths
subj = ['sub' subID];
stem = 'data';
projdir1 = '/N/dc2/projects/lifebid/development';
cd(fullfile(projdir1,subj,'diffusion'))
% organize folder
mkdir diffusion_data
mkdir fibers
cd diffusion_data
copyfile((fullfile(projdir1,subj,'diffusion/AP','dwi_dir80_ap.bvals')),(fullfile(projdir1,subj,'diffusion','diffusion_data','data.bvals'))) 
copyfile((fullfile(projdir1,subj,'diffusion/AP','dwi_dir80_ap.bvecs')),(fullfile(projdir1,subj,'diffusion','diffusion_data','data.bvecs')))
copyfile((fullfile(projdir1,subj,'diffusion','data.nii.gz')),(fullfile(projdir1,subj,'diffusion','diffusion_data','data.nii.gz')))% Split data into two separate files (BVALS = 1000 and 2000).
bvals = dlmread('data.bvals');
bvals = round(bvals./100)*100;
bvals(bvals==100) = 0;
dlmwrite('data.bvals',bvals)
dwi   = niftiRead('data.nii.gz');
dwi1000 = dwi;
dwi1000.fname = 'data_b1000.nii.gz';
dwi2500 = dwi;
dwi2500.fname = 'data_b2500.nii.gz';
index1000 = (bvals == 1000);
index2500 = (bvals == 2500);
index0    = (bvals == 0);
% Find all indices to each bvalue and B0
all_1000  = or(index1000,index0);
all_2500  = or(index2500,index0);
dwi1000.data = dwi.data(:,:,:,all_1000);
dwi1000.dim(4) = size(dwi1000.data,4);
niftiWrite(dwi1000);
bvals1000 = bvals(all_1000);
dlmwrite('data_b1000.bvals',bvals1000);
bvecs1000 = dlmread('data.bvecs');
bvecs1000 = bvecs1000(:,all_1000);
dlmwrite('data_b1000.bvecs',bvecs1000);
dwi2500.data = dwi.data(:,:,:,all_2500);
dwi2500.dim(4) = size(dwi2500.data,4);
niftiWrite(dwi2500);
bvals2500 = bvals(all_2500);
dlmwrite('data_b2500.bvals',bvals2500);
bvecs2500 = dlmread('data.bvecs');
bvecs2500 = bvecs2500(:,all_2500);
dlmwrite('data_b2500.bvecs',bvecs2500);
for ibv = 1:length(b_vals)
bvecs = fullfile(projdir1, subj, 'diffusion','diffusion_data', sprintf('data_b%s.bvecs',b_vals{ibv}));
bvals = fullfile(projdir1, subj, 'diffusion','diffusion_data', sprintf('data_b%s.bvals',b_vals{ibv}));
out   = fullfile(projdir1, subj, 'diffusion','fibers',         sprintf('data_b%s.b',    b_vals{ibv}));
mrtrix_bfileFromBvecs(bvecs, bvals, out);
end
end
