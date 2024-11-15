%% First level analysis, written by Jin Wang 3/15/2019
% You should define your conditions, onsets, duration, TR.
% The repaired images will be deweighted from 1 to 0.01 in the first level

% Make sure you run clear all before running this code. This is to clear
% all existing data structure which might be left by previous analysis in
% the work space.

% Adapted by Marjolein Mues for ELP Morphology Project on 06/14/2024
%Can be used as bash script using the "firstlevel_ses7submit.sh" and
%"firstlevel_ses7.submit" files
%change the .submit file depending on the task (sem, phon, gram)
%In terminal use ./firstlevel_ses7submit.sh
%Need an idfile.txt with all ID numbers in them

function firstlevel_gram_ses7 (subjects)
parpool;
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/Marjolein/typical_data_analysis/3firstlevel')); % the path of your scripts
%spm_path='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM_ELP/spm12_elp';%the path of spm
spm_path='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12_elp';
addpath(genpath(spm_path));
analysis_folder='ses7_analysis_gram'; % the name of your first level modeling folder

% define your data path
data=struct();
root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/Marjolein/Morph_7' ;  %your project path
model_deweight='deweight'; % the deweigthed modeling folder, it will be inside of your analysis folder

global CCN
CCN.preprocessed='preprocessed'; % your data folder
CCN.session='ses-7'; % the time points you want to analyze
CCN.func_pattern='sub*Gram*_bold'; % the name of your functional folders
CCN.file='vs6_wsub*Gram*_bold.nii'; % the name of your preprocessed data (4d)%
CCN.rpfile='rp_*Gram*.txt'; %the movement files
events_file_exist=0; % 1 means you did not clean your events.tsv, 0 means you cleaned the events.tsv in your preprocessed folder
bids_folder='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/ELP/bids'; % if you assign 0 to events_file_exist, then you mask fill in this path, so it can read events.tsv file for individual onsets from bids folder

%%define your task conditions, be sure it follows the sequence of the
%%output from count_repaired_acc_rt.m.
conditions=[];
conditions{1}={'G_C' 'G_F' 'G_G' 'G_P'}; %Run1
conditions{2}={'G_C' 'G_F' 'G_G' 'G_P'}; %Run2

%duration
dur=0; %I think all projects in BDL are event-related, so I hard coded the duration as 0.

%TR
TR=1.25; %ELP project

%define your contrasts, make sure your contrasts and your weights should be
%matched.
contrasts={'Gram_Fin_Cont'};
Gram_Fin_Cont=[0 1 -1 0];


%adjust the contrast by adding six 0s into the end of each session
rp_w=zeros(1,6);
% empty=zeros(1,10);
weights={[Gram_Fin_Cont rp_w Gram_Fin_Cont rp_w]};

%%%%%%%%%%%%%%%%%%%%%%%%Do not edit below here%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check if you define your contrasts in a correct way
if length(weights)~=length(contrasts)
    error('the contrasts and the weights are not matched');
end

% Initialize
%addpath(spm_path);
spm('defaults','fmri');
spm_jobman('initcfg');
% spm_figure('Create','Graphics','Graphics','off');
spm_figure('Create','Graphics','Graphics');
spm_get_defaults('cmdline',true);



% Dependency and sanity checks
if verLessThan('matlab','R2013a')
    error('Matlab version is %s but R2013a or higher is required',version)
end

req_spm_ver = 'SPM12 (6225)';
spm_ver = spm('version');
if ~strcmp( spm_ver,req_spm_ver )
    error('SPM version is %s but %s is required',spm_ver,req_spm_ver)
end

%Start to analyze the data from here
try
   
        fprintf('work on subject %s', subjects);
        CCN.subject=[root '/' CCN.preprocessed '/' subjects];
        %specify the outpath,create one if it does not exist
        out_path=[CCN.subject '/' analysis_folder];
        if ~exist(out_path)
            mkdir(out_path)
        end
         
        %specify the deweighting spm folder, create one if it does not exist
        model_deweight_path=[out_path '/' model_deweight];
        if exist(model_deweight_path,'dir')~=7
            mkdir(model_deweight_path)
        end
        
        %find folders in func
        CCN.functional_dirs='[subject]/[session]/func/[func_pattern]/';
        functional_dirs=expand_path(CCN.functional_dirs);
        
        %re-arrange functional_dirs so that run-01 is always before run-02
        %if they are the same task. This is only for ELP project. modified
        %1/7/2021
        func_dirs_rr=functional_dirs;
        for rr=1:length(functional_dirs)
            if rr<length(functional_dirs)
            [~, taskrunname1]=fileparts(fileparts(functional_dirs{rr}));
            sessionname1=taskrunname1(10:15);
            taskname1=taskrunname1(21:25);
            taskrun1=str2double(taskrunname1(end-5:end-5));
            [~, taskrunname2]=fileparts(fileparts(functional_dirs{rr+1}));
            sessionname2=taskrunname2(10:15);
            taskname2=taskrunname2(21:25);
            taskrun2=str2double(taskrunname2(end-5:end-5));
            if strcmp(sessionname1,sessionname2) && strcmp(taskname1,taskname2) && taskrun1>taskrun2
                func_dirs_rr{rr}=functional_dirs{rr+1};
                func_dirs_rr{rr+1}=functional_dirs{rr};
            end
            end
        end
                
        %load the functional data, 6 mv parameters, and event onsets
        mv=[];
        swfunc=[];
        P=[];
        onsets=[];
        for j=1:length(func_dirs_rr)
             swfunc{j}=expand_path([func_dirs_rr{j} '[file]']);
            %load the event onsets
            if events_file_exist==1
                [p,run_n]=fileparts(func_dirs_rr{j}(1:end-1));
                event_file=[func_dirs_rr{j} run_n(1:end-4) 'events.tsv'];
            elseif events_file_exist==0
                [p,run_n]=fileparts(func_dirs_rr{j}(1:end-1));
                [q,session]=fileparts(fileparts(p));
                [~,this_subject]=fileparts(q);
                event_file=[bids_folder '/' this_subject '/' session '/func/' run_n(1:end-4) 'events.tsv'];
                rp_file=[p '/' run_n '/rp_' run_n '.txt'];
            end
            event_data=tdfread(event_file);
            cond=unique(event_data.trial_type,'row');
            [~,len]=size(cond);
            for k=1:size(cond,1)
            onsets{j}{k}=event_data.onset(sum((event_data.trial_type==cond(k,:))')'==len);
            end
            mv{j}=load(rp_file); 
        end
        data.swfunc=swfunc;
        
        
        %pass the experimental design information to data
        data.conditions=conditions;
        data.onsets=onsets;
        data.dur=dur;
        data.mv=mv;
        
        %run the firstlevel modeling and estimation (with deweighting)
        mat=firstlevel_4d(data, out_path, TR, model_deweight_path);
        origmat=[out_path '/SPM.mat'];
        %run the contrasts
        
        contrast(origmat,contrasts,weights);
        
        contrast(mat,contrasts,weights);
        
  
    catch e
    rethrow(e)
    %display the errors
end
end