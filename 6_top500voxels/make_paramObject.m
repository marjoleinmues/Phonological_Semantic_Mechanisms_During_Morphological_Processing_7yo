%%Script to find top x or x% voxels for each subject for a given contrast, masked by an ROI or not. This script puts all the necessary 
%info into an object. After running this script, you should run the command: makeroi(paramObject). 
%Written by Jerome Prado 
%Modified by Marjolein Mues

%note that when running this script and the makeroi script, you want to cd
%to your project folder in matlab for all filepaths to run correctly

%add your paths
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12'));
spm('defaults','fmri');


addpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12/toolbox/marsbar'); %You can leave this line alone. This just ensures that marsbar is in your path.
%addpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/fmriTools/util');

paramObject.data_root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/Marjolein/Morph_7'; %the parent directory for all the subject folders
% paramObject.SPM_mat_folder='/Eng_Allpic_vs_contrl'; %the name of the directory under the subject data folder containing the SPM.mat file with contrast info 
% paramObject.contrast_name= 'Eng_Allpic_vs_contrl'; %the name of the contrast associated with the statistical map you want to use. Check your SPM.mat file for names 

paramObject.SPM_mat_folder='/HighLow_Cont';
paramObject.contrast_name= 'HighLow_Cont';
%paramObject.contrast_name= 'EngWords-Con';
%paramObject.contrast_name= 'Span-con';
%paramObject.contrast_name= 'Num-con';

%All Regions
paramObject.regions={};
%paramObject.regions={'fPPI_LIPL' 'fPPI_RSPL' 'fPPI_LMFG' 'fPPI_MeFG' 'LMFG' 'LeftNA_005'}; %for each region 'XXX', there should be a tab-delimited list of xyz coordinates called XXX.txt in the working directory. (I think the purpose of this line has been lost, and you can just leave the paramObjects.regions blank -JY)
paramObject.images={'IFGtri' 'pMTG'}; %The ROI you want to use (you can also specify the names of .nii files to be used in lieu of or in addition to your sphere coordinates)
paramObject.subjects={'secondlevel_sem'}; %although this says 'subjects', it really means the second-level folder where your full analysis is.
%paramObject.subjects={'GroupLevel_LangSpan'};
%paramObject.subjects={'GroupLevel_Numeros'};

% data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PhonReading_7_9/data_bids.xlsx';
% if isempty(paramObject.subjects)
%     M=readtable(data_info);
%     paramObject.subjects=M.subjects;
% end

%%OPTIONAL PARAMETERS%%
%%If these values are not specified, defaults will be used (p=.05, radius=8mm, k=100%)
paramObject.p=1; %uncorrected p-value for statistical map with which sphere is intersected
%paramObject.radius=6; %sphere radius, in mm (again, the utility of this line I think has been lost -JY)
paramObject.k='500'; %specify paramObject.k as either 'k%' or just 'k' = the number of voxels
			%if k is specified as k%, it will take the top k percentile of voxels
			%if k is specified as k, then it will take the top k voxels
			%It will always select at least 1 voxel (e.g., top 10% of a 9 voxel blob < 1, so select the top 1 voxel)
paramObject.savesphere=0; %do you want to save the base spheres for each person? Might be useful for debugging failed ROI attempts
paramObject.savedir='/sem_top500';%name of the subdirectory to be created in the current directory into which the ROIs will be saved
				%if a savedir is not specified, a directory with today's date will be created
                
                