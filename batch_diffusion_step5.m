% batch_diffusion_step5

addpath(genpath('/N/dc2/projects/lifebid/development/bin/'));

% Get the base directory for the data.
topdir = '/N/dc2/projects/lifebid/development/';

% Get subject IDs.
subID = {'306'};%, '103', '105', '203', '204', '206', '301', '302', '303', '304', '306'}; 
lmax = {'2'};%, '4', '6'};

%
for i = 1:length(subID)
    
    % Get the out directory.
    outdir = [topdir 'sub' subID{i} '/diffusion/afq/'];
    
    % TENSOR MODEL
   [fascicles, classification, fd, fg_classified] = feAfqSegment([topdir 'sub' subID{i} '/diffusion/dti38trilin/dt6.mat'], ...
        [topdir 'sub' subID{i} '/diffusion/fibers/data_b1000_aligned_trilin_noMEC_wm_tensor-500000.tck']);

    % CSD MODEL
    for j = j:length(lmax)
        
        % DETERMINISTIC TRACKING
        [fascicles2, classificatio2n, fd2, fg_classified2] = feAfqSegment([topdir 'sub' subID{i} '/diffusion/dti38trilin/dt6.mat'], ...
            [topdir 'sub' subID{i} '/diffusion/fibers/data_b1000_aligned_trilin_noMEC_csd_lmax' lmax{i} '_wm_SD_STREAM-500000.tck']);
    
        % PROBABILISTIC TRACKING
        [fascicles3, classification3, fd3, fg_classified3] = feAfqSegment([topdir '/sub' subID{i} '/diffusion/dti38trilin/dt6.mat'], ...
            [topdir 'sub' subID{i} '/diffusion/fibers/data_b1000_aligned_trilin_noMEC_csd_lmax' lmax{i} '_wm_SD_PROB-500000.tck']);
    
    end
    
end