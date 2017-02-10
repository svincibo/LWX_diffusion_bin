function bsc_plot_fibers_VPF_only_Coronal_Life(fullFiberOutDir,fullFigureOutDir,t1path,saveHeaderData,posIndexes,wbFG)
% This function plots the VPF and saves a saggital
% figure
%
% INPUTS
% fullFiberOutDir:  path to directory contining the relevant VPF, Arc pArc
% and VOF fibers which were generated earlier (i.e. VPFandOtherFiberSegmentWrapperHCP1.m)
% this path is a standard output from bsc_HCP_Stanford_PathGen --- in
% practice this file stores the data structure containing fiber indices for
% all AFQ outputs... this contains indices for all streamlines
%
% fullFigureOutDir: path to directory where output figures will be saved
% this path is a standard output from bsc_HCP_Stanford_PathGen
%
% t1path: path to t1 file
% this path is a standard output from bsc_HCP_Stanford_PathGen
%
% saveHeaderData: unnecessary
%
% posIndexes: 
%
%
% wbFG: is from from fgRead of any whole brain fiber connectome (e.g.,
% .trk)
%
% OUTPUTS
%  no outputs, all figures are saved into the fullFigureOutDir
%


%reminder
%     Fibers.L_VOF
%     Fibers.R_VOF
%     Fibers.L_pArc
%     Fibers.R_pArc
%     Fibers.L_pArc_vot
%     Fibers.R_pArc_vot
%     Fibers.L_Arc
%     Fibers.R_Arc
%     Fibers.L_Lat_VPF
%     Fibers.L_Med_VPF
%     Fibers.R_Lat_VPF
%     Fibers.R_Med_VPF



load(strcat(fullFiberOutDir,saveHeaderData,'_FiberIndexes.mat'));

L_Lat_VPF_Indexes=Fibers.L_Lat_VPF.fibers(ismember(FiberIndexes.L_Lat_VPF,posIndexes));
R_Lat_VPF_Indexes=Fibers.R_Lat_VPF.fibers(ismember(FiberIndexes.R_Lat_VPF,posIndexes));
L_Med_VPF_Indexes=Fibers.L_Med_VPF.fibers(ismember(FiberIndexes.L_Med_VPF,posIndexes));
R_Med_VPF_Indexes=Fibers.R_Med_VPF.fibers(ismember(FiberIndexes.R_Med_VPF,posIndexes));

fibers{1}=Fibers.L_Lat_VPF;
fibers{3}=Fibers.L_Med_VPF;
fibers{2}=Fibers.R_Lat_VPF;
fibers{4}=Fibers.R_Med_VPF;

%fiber1=left med VPF [.6,1,0]
%fiber2=Right Med VPF [.6,1,0]
%fiber3=Left Lat VPF [1,1,0]
%fiber4=Right lat VPF [1,1,0]

%flip the fibers if the cells are arranged incorrectly
%followed by removing fiber outliers
cutvar1=3;
cutvar2=3;
for iFiberGroups=1:length(fibers)
    if ~isempty(fibers{iFiberGroups})
    if ~isempty(fibers{iFiberGroups}.fibers)
    fiberDim=size(fibers{iFiberGroups}.fibers);
    if fiberDim(1)<fiberDim(2)
        fibers{iFiberGroups}.fibers=fibers{iFiberGroups}.fibers';
    end
    [~, keep] = mbaComputeFibersOutliers(fibers{iFiberGroups},cutvar1,cutvar2);
    fprintf('\n Found a tract with %i fibers in %s... \n',sum(keep),fibers{iFiberGroups}.name);
    fibers{iFiberGroups}.params=[]
    fibers{iFiberGroups} = fgExtract(fibers{iFiberGroups},find(keep),'keep');
    end
    end
end


%% being plotting coronal VPF

fiberColors={[.6,1,0],[.6,1,0],[1,1,0],[1,1,0]};


t1          = niftiRead(t1path);
slices      = {[-1 0 0],[0 -45 0],[0 0 -1]}; %slice that the fibers will be displayed on

fh = figure('name','VPF','color','k','units','normalized','position',[.5 .5 .5 .5]);
axis square
fhNum = fh.Number
hold on

%h  = mbaDisplayBrainSlice(t1, slices{1});
h  = mbaDisplayBrainSlice(t1, slices{2});
%h  = mbaDisplayBrainSlice(t1, slices{3});

%axis([-55, 50,-30, 60,-90, 60]);
% xlim([-65, 65]);
% %ylim([-30,60]);
% zlim([-35,79]);

for itract = 1:length(fibers)
    if exist('lh','var'), delete(lh); end
    if ~isempty(fibers{itract})
        if ~isempty(fibers{itract}.fibers)
    [fh, lh] = mbaDisplayConnectome(fibers{itract}.fibers,fhNum, fiberColors{itract}, 'single');%color{itract}
    delete(lh)
    display (itract)
    fprintf('\n %i \n',itract)
        end
    end
end

%find Variant Name (i.e. the name of this batch of fiber/plot outputs)
slashIndicies=strfind(fullFiberOutDir,'/');
BatchName=fullFiberOutDir(slashIndicies(end)+1:end);
SubjectID=fullFiberOutDir(slashIndicies(end-2)+1:slashIndicies(end-1)-1);

fig.views = {[0,0]};%,[0,90],[90,0],[-90,0]};
light.angle = {[0,-90]};%,[90,45],[90,-45],[-90,45]};
fig.names = {strcat(saveHeaderData,'_VPF_All3_NoLat_coronal_Life2')};

for iview = 1:length(fig.views)
    view(fig.views{iview}(1),fig.views{iview}(2))
    lh = camlight('left'); 
    axis square
    feSavefig(fhNum,'verbose','yes', ...
        'figName',fig.names{iview}, ...
        'figDir',fullFigureOutDir, ...
        'figType','jpg');
    delete(lh)
end

close all

%% begin plotting saggital VPF
fh = figure('name','VPF','color','k','units','normalized','position',[.5 .5 .5 .5]);
axis square
fhNum = fh.Number
hold on

h  = mbaDisplayBrainSlice(t1, slices{1});
%h  = mbaDisplayBrainSlice(t1, slices{2});
%h  = mbaDisplayBrainSlice(t1, slices{3});

%axis([-55, 50,-30, 60,-90, 60]);
% xlim([-65, 65]);
% %ylim([-30,60]);
% zlim([-35,79]);

for itract = 1:length(fibers)
    if exist('lh','var'), delete(lh); end
    if ~isempty(fibers{itract})
        if ~isempty(fibers{itract}.fibers)
    [fh, lh] = mbaDisplayConnectome(fibers{itract}.fibers,fhNum, fiberColors{itract}, 'single');%color{itract}
    
    delete(lh)
    display (itract)
    fprintf('\n %i \n',itract)
        end
    end
end

fig.views = {[90,0],[-90,0]};%,[0,90],[90,0],[-90,0]};
light.angle = {[90,-45],[-90,45]};%,[90,45],[90,-45],[-90,45]};
fig.names = {strcat(saveHeaderData,'_VPF_All3_noLat_saggital1_Life2'),strcat(saveHeaderData,'_VPF_All3_NoLat_saggital2_Life2')};

for iview = 1:length(fig.views)
    view(fig.views{iview}(1),fig.views{iview}(2))
    lh = camlight('left');
         feSavefig(fhNum,'verbose','yes', ...
        'figName',fig.names{iview}, ...
        'figDir',fullFigureOutDir, ...
        'figType','jpg');
    delete(lh)
end
clear fibers
clear LeftMed
clear LeftLat;
clear RightLat;
clear RightMed;
close all

end

