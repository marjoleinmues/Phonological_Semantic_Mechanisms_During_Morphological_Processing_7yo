%%% Script to run 3dFMHMx over loop of subjects. It will display the average values from the subjects at the end.
%%% You can also choose to write out the values for each subject into a
%%% text file. The last line will be the average values. You can also
%%% choose to run 3dclustsim directly from this script and the average
%%% values will be automatically entered in. 
%%Created by : Jessica Younger 7/9/16 
%Modified by Marjolein Mues 6/24/2024

addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12'));
%addpath(genpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/fmriTools'));

spm_defaults;
spm('defaults','fmri');

% make sure the scriptdir is in the path
addpath(pwd);

% What directory has all your subject folders? We assume that in each subject folder is
% a folder containing the SPM.mat file for that subject's 1st level analysis
rootDIR  = '/dors/gpc/JamesBooth/JBooth-Lab/BDL/Marjolein/Morph_7/preprocessed';

%What directory holds the model file for each subject
modelDIR  = 'ses7_analysis_gram/deweight';

%List your subjects 
namesubjects={'sub-5003', 'sub-5004', 'sub-5008', 'sub-5009', 'sub-5011', 'sub-5015', 'sub-5020', 'sub-5022', 'sub-5025', 'sub-5029', 'sub-5031', 'sub-5034', 'sub-5035', 'sub-5045', 'sub-5047', 'sub-5054', 'sub-5055', 'sub-5057', 'sub-5058', 'sub-5065', 'sub-5069', 'sub-5070', 'sub-5074', 'sub-5075', 'sub-5077', 'sub-5094', 'sub-5099', 'sub-5102', 'sub-5103', 'sub-5104', 'sub-5109', 'sub-5110', 'sub-5136', 'sub-5137', 'sub-5139', 'sub-5140', 'sub-5141', 'sub-5143', 'sub-5149', 'sub-5153', 'sub-5157', 'sub-5158', 'sub-5159', 'sub-5160', 'sub-5163', 'sub-5167', 'sub-5185', 'sub-5186', 'sub-5194', 'sub-5199', 'sub-5215', 'sub-5216', 'sub-5224', 'sub-5231', 'sub-5252', 'sub-5259', 'sub-5260', 'sub-5274', 'sub-5286', 'sub-5302', 'sub-5304', 'sub-5307', 'sub-5312', 'sub-5317', 'sub-5332', 'sub-5334', 'sub-5338', 'sub-5342', 'sub-5344', 'sub-5357', 'sub-5365', 'sub-5367', 'sub-5374', 'sub-5378', 'sub-5379', 'sub-5388', 'sub-5400', 'sub-5414', 'sub-5417', 'sub-5430', 'sub-5438', 'sub-5439', 'sub-5443', 'sub-5448', 'sub-5452', 'sub-5468', 'sub-5478', 'sub-5479', 'sub-5492', 'sub-5495', 'sub-5501', 'sub-5508', 'sub-5510', 'sub-5526', 'sub-5527', 'sub-5536', 'sub-5543', 'sub-5550', 'sub-5553', 'sub-5567'};

%3dcluststim options
threedclust=1; %Run 3dclustsim with results? 1 for yes, 0 for no
pthr = [.005]; %enter values for pthr .05 .01
ROI = '/dors/gpc/JamesBooth/JBooth-Lab/BDL/Marjolein/typical_data_analysis/top_voxel_secondlevel/sem_top500/secondlevel_sem/IFGtri_HighLow_Cont_p1_k500_roi.nii'; %pathway to your ROI

%Writing options to have the matrix of ACF values for each subject written
%out. The last lnie will be the average values to use in 3dclustsim
write=1; %write the individual subject information? 1 yes 0 no
writeDIR  = rootDIR; % Where do you want the text file  to be written?
filename = 'analysis_3dclust_lifgtri';

%%%%%Do not edit below this line%%%%

numsubjects = length(namesubjects);
C=zeros(numsubjects,3);
idx = 1;
subj = 1:numsubjects;
 for x = subj
    swd = [rootDIR filesep char(namesubjects(x)) filesep modelDIR];
    %change to the subjects directory
    cd(swd);
    %run 3dFWHMx and store values
    diary('output.txt')
    %system(['3dFWHMx -detrend -ACF -mask mask.hdr -input ResMS.hdr -out
    %temp']); %Jin changed it here to make it compatable with
    %spm12. 5/3/2019
    system(['3dFWHMx -detrend -ACF -mask mask.nii -input ResMS.nii -out temp']);
    diary off
    temp1=textread('output.txt', '%s', 'delimiter', '\n');
    temp2=temp1(13,1);
    temp2=char(temp2);%     C(idx,1) = str2num(temp2(1:8));
%     C(idx,2) = str2num(temp2(10:17));
%     C(idx,3) = str2num(temp2(19:25));
    temp3=strsplit(temp2); %Jin changed here to make it easier to recognize the values
    C(idx,1) = str2num(temp3{1});
    C(idx,2) = str2num(temp3{2});
    C(idx,3) = str2num(temp3{3}); 
    idx = idx+1;
 end
 
 %Get mean ACF values
avgA = mean(C(:,1));
avgC = mean(C(:,2));
avgF = mean(C(:,3));
 
C(1+numsubjects, :) = [avgA, avgC, avgF];

if write==1
    fextension='.txt';
    cd(writeDIR);
    writefile=char([char(filename) char(fextension)]);
    dlmwrite(writefile, C, 'delimiter', '\t', '-append');
 end
diary 3dClustSim_Tables
if threedclust==1
system(['3dClustSim -pthr ' num2str(pthr) ' -mask ' ROI ' -ACF ' num2str(avgA) ' ' num2str(avgC) ' ' num2str(avgF)]);
end

Values=[avgA, avgC, avgF];
display(Values)
diary off
