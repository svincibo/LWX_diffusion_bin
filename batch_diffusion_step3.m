% batch_diffusion_step3

% Get the base directory for the data.
topdir = '/N/dc2/projects/lifebid/development/';

% Get subject IDs.
subID = {'103' '203' '204', '302', '303', '304', '306'}; % DONE: '101', '103', '105', '203', '204', '206', '301'};

for i = 1:length(subID)
    
    % Create wm_mask.nii.gz for each subject. This is a special mask file that mrtrix_ensemble.sh expects. 
    s_fe_make_wm_mask_hcp_modified(topdir, subID)
    
    % Place wm_mask.nii.gz in the anatomical folder. This is where mrtrix_ensemble.sh expects to find it.
    copyfile([topdir 'sub' subID{i} '/diffusion/dti38trilin/bin/wm_mask.nii.gz'], [topdir 'sub' subID{i} '/anatomical/wm_mask.nii.gz']) 
    
end