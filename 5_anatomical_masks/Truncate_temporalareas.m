
% Marsbar code to truncate anatomical temporal regions - STG and MTG
% Code written by AM - 7/26/2023

% Marsbar switch on
marsbar('on')

% ROI directory path to anatomical ROIs
roi_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/Marjolein/typical_data_analysis/templates_cerebroMatic';

% Make a box ROI to do trimming
% Box to trim STG
box_limits1 = [-74 -34; -26 50; -16 30]'; % -26 is the Ycentre for STG/ 50 is the min limit and x/z are the max/min limits taken from viewing STG/MTG IN Marsbar
box_centre1 = mean(box_limits1);
box_widths1 = abs(diff(box_limits1));
box_roi_STG = maroi_box(struct('centre', box_centre1, ...
                           'widths', box_widths1));

% Box to trim MTG
box_limits2 = [-74 -36; -39 50; -38 24]'; % -39 is the Ycentre for STG and x and z are the max and min limits
box_centre2 = mean(box_limits2);
box_widths2 = abs(diff(box_limits2));
box_roi_MTG = maroi_box(struct('centre', box_centre2, ...
                           'widths', box_widths2));

% Read anatomical ROIS
STG_name = fullfile(roi_dir, 'l_STG_-56_-25_9_roi.mat');
MTG_name = fullfile(roi_dir, 'l_MTG_-57_-39_-3_roi.mat');

roi_STG = maroi(STG_name);
roi_MTG = maroi(MTG_name);

% Combine BOX and anatomical ROI
trim_STG = roi_STG & ~ box_roi_STG;
trim_MTG = roi_MTG & ~ box_roi_MTG;

% Give it a name
trim_STG = label(trim_STG, 'pSTG');
trim_MTG = label(trim_MTG, 'pMTG');

% save new truncated ROI to MarsBaR ROI file, in current directory
saveroi(trim_STG, fullfile(roi_dir, 'pSTG_roi.mat'));
saveroi(trim_MTG, fullfile(roi_dir, 'pMTG_roi.mat'));

% Display pSTG and pMTG
mars_display_roi('display','pSTG_roi.mat');
mars_display_roi('display','pMTG_roi.mat');

% Display original STG/MTG
mars_display_roi('display','l_STG_-56_-25_9_roi.mat');
mars_display_roi('display','l_MTG_-57_-39_-3_roi.mat');

% Display STG and pSTG together
roi_array = {'l_STG_-56_-25_9_roi.mat';'pSTG_roi.mat'};
mars_display_roi('display',roi_array);

%  Display MTG and pSTG together
roi_array = {'l_MTG_-57_-39_-3_roi';'pMTG_roi.mat'};
mars_display_roi('display',roi_array);

