% This script will perform the second portion of the diffusion
% preprocessing pipeline. You must first run batch_diffusion_step1 from
% shell. 

% This script requires the vistasoft toolbox. Specifically:mrAnatAverageAcpcNifti.m and dtiInit.m

% This script also requires bvals_bvecs_split.m in
% /N/dc2/projects/lifebid/development/bin/

topdir = addpath(genpath('/N/dc2/projects/lifebid/development/'));

subID = {'009'};
b_vals = {'1000'};
%b_vals = {'1000','2500'};

for i = 1:length(subID)
    
    % Get directory.
    subdir = ['/N/dc2/projects/lifebid/development/sub' subID{i}];

    % Split the bvals and bvecs files according to the number of shells.
    bvals_bvecs_split(subID{i}, b_vals)
    
    % Update user. 
    fprintf('\n==========Finished splitting the bvals and bvecs for subject %s.==========\n', subID{i});
    
    % Align the T1 images (e.g., mprage.nii.gz) to standard AC-PC space.
    % This step opens a gui and the user will have to select the anatomical
    % images, specify the output filename, manually define the AC-PC
    % midline, and save the image.
    mrAnatAverageAcpcNifti([subdir '/anatomical/mprage.nii.gz'], [subdir '/anatomical/mprage_acpc.nii.gz']);
    
    % Make a copy of mprage_acpc.nii.gz in the diffusion folder.
    copyfile([subdir '/anatomical/mprage_acpc.nii.gz'], [subdir '/diffusion/mprage_acpc.nii.gz']) 

    % Update user. 
    fprintf('\n==========Finished AC-PC alignment for subject %s.==========\n', subID{i});
    
    % Coregister the diffusion images to the anatomical image space. This
    % should be done for each shell.
    for j = 1:length(b_vals)
        
        % Initiate dtiInitParams.m to set parameters for dtiInit.m
        dwParams = dtiInitParams;
        
        % Define .bvecs and .bvals files for this shell.
        dwParams.bvecsFile = [subdir '/diffusion/diffusion_data/data_b' b_vals{j} '.bvecs'];
        dwParams.bvalsFile = [subdir '/diffusion/diffusion_data/data_b' b_vals{j} '.bvals'];

        % Turn off the eddy current correction and motion compensation, because it is already done by batch_diffusion_step1. 
        %dwParams.eddyCorrect = -1;

        % Ensure that the ‘xform’ is correct. 
        dwParams.rotateBvecsWithRx = 1;
        dwParams.rotateBvecsWithCanXform = 1;

        % Additional parameters to set:
        dwParams.phaseEncodeDir = 2;
        dwParams.dwOutMm = [1.5 1.5 1.5];

        % Run dtiInit.m for this shell.
        dbstop if error
        dtiInit([subdir '/diffusion/diffusion_data/data_b' b_vals{j} '.nii.gz'], ...
            [subdir '/anatomical/mprage_acpc.nii.gz'], dwParams);
        
        % Update user. 
        fprintf('\n==========Finished dtiInit for subject %s and shell %s.==========\n', subID{i}, b_vals{j});

    end
    
    % Create wm_mask.nii.gz. This is a special mask file that mrtrix_ensemble.sh expects. 
    s_fe_make_wm_mask_hcp_modified(topdir, subID)
    
    % Place wm_mask.nii.gz in the anatomical folder. This is where
    % mrtrix_ensemble.sh expects to find it.
    
    
end

