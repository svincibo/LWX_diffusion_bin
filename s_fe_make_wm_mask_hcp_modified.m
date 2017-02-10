function s_fe_make_wm_mask_hcp_modified(topdir, subjects)
%
% This script makes the white-matter mask used to track the connectomes in
% Pestilli et al., LIFE paper.
%
% Copyright Franco Pestilli (c) Stanford University, 2014

% This function requires that the subject folders are set up as:
% /N/dc2/projects/lifebid/development/sub101/anatomical
% /N/dc2/projects/lifebid/development/sub101/diffusion/
% /N/dc2/projects/lifebid/development/freesurfer/sub101/
% with the top directory of, for example, /N/dc2/projects/lifebid/development/

% Convert the freesurfer white matter mask to a subject specific white
% matter mask for each subject.
for isbj = 1:length(subjects)
    
    % Define the name of the subject's mask file and output location. 
    wmMaskFile = [topdir, 'sub' subjects{isbj}, '/diffusion/dti38trilin/bin/wm_mask.nii.gz'];
    
    % Select the atlas. 
    fs_wm = [topdir, 'freesurfer/sub', subjects{isbj}, '/mri/aparc+aseg.mgz'];
    
    % Call mri_convert from shell to 
    eval(sprintf('!mri_convert  --out_orientation RAS %s %s', fs_wm, wmMaskFile));
    
    % Convert the mask file to a nifti file.
    wm = niftiRead(wmMaskFile);
    
    % Specify a set of values in a voxel that would indicate that the voxel
    % is a white matter voxel according to the labeling in the atlas.
    invals  = [2 41 16 17 28 60 51 53 12 52 13 18 54 50 11 251 252 253 254 255 10 49 46 7];
    
    % Find and sort all of the unique vslues across all voxels.
    origvals = unique(wm.data(:)); 
    
    % Update user.
    fprintf('\n[%s] Converting voxels... ',mfilename);
    
    % Go through the voxels and (1) binarize according to whether the value indicates that the voxel is white matter or not 
    % and (2) keeping track of the number of voxels converted to white matter (e.g., wm.data = 1) and the number of
    % voxels converted to gray matter (e.g., wm.data = 0).
    wmCounter=0;noWMCounter=0;
    
    for ii = 1:length(origvals);
        
        if any(origvals(ii) == invals)
            
            wm.data( wm.data == origvals(ii) ) = 1;
            wmCounter=wmCounter+1;
            
        else            
            
            wm.data( wm.data == origvals(ii) ) = 0;
            noWMCounter = noWMCounter + 1;
            
        end
        
    end
    
    % Let the user know the number of voxels converted to white matter and
    % gray matter.
    fprintf('converted %i regions to White-matter (%i regions left outside of WM)\n\n',wmCounter,noWMCounter);
    
    % Write out wm as a niftifile. NOTE: Put this in the subject's
    % anatomical file because that is where mrtrix_ensemble expects it.
    niftiWrite(wm);
    
end

%end % Main function
