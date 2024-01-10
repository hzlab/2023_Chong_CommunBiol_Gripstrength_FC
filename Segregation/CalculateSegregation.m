% Compute segregation measures based on Chan et al. (2014) PNAS paper
% Both global and network-level measures are created

% Inputs to the script:
% 1) scriptdir: Path of folder containing systemsegregation.m and comAUC.m scripts
% 2) FCdir: Path of folder containing FC matrices of each subject
%    - Each subject's 142 x 142 FC matrix is saved as an individual mat variable, e.g., Subj001.mat of subject Subj001
%    - Each subject's mat variable contains a "z_mat" variable which is a 142 x 142 matrix 
% 3) sublist: Path of text file containing the subject IDs of all n subjects
% 4) networkfile: Name and path of file containing network assignments of the 142 ROIs (saved as a 1 x 142 numeric array 'p')
%    as well as the names of the 9 networks (saved as a 1 x 9 cell array 'networknames')
% 5) outputfile: Name and path of output csv file

% Output:
% 1) outputfile: a csv file containing the calculated global and
%    network-level measures for each subject. Contains the following columns:
%    - SubID: Subject ID
%    - Global: Global segregation
%    - Default: Default network segregation
%    - Con: Control network segregation
%    - Limbic: Limbic network segregation
%    - SalVentAttn: Salience/Ventral Attention network segregation
%    - DorsAttn: Dorsal Attention network segregation
%    - SomMot: Somatomotor network segregation
%    - Visual: Visual network segregation
%    - TempPar: Temporoparietal network segregation
%    - Subcortical: Subcortical network segregation


clear;clc;

%% User-specified parameters (PLEASE CHANGE THIS!!)
%Path of folder containing systemsegregation.m and comAUC.m scripts
scriptdir='/XXX/Segregation/'

%Path of folder containing 142 x 142 FC matrices of all subjects, with separate mat variables (the variable is named as z_mat) for each subject. 
%Example path of FC matrix of Subject Subj001: /XXX/FCmatrices/Subj001.mat, where the FC matrix is saved as z_mat
FCdir='/XXX/SampleData/FCmatrices/';

%Path of text file containing list of all subjects
sublist='/XXX/SampleData/FCmatrices/subjectlist.txt';

%Mat variable containing network assignments and names
networkfile='/XXX/Segregation/Parcellation_142ROIs_networkassignment.mat';

%Path of output csv file containing calculated segregation measures of all subjects
outputfile='/XXX/SampleData/Segregationmeasures.csv';

%% Load variables and paths
% Add path of folder containing function files
addpath(scriptdir)

% Import sublist variable as a cell array of subject IDs
sublist=importdata(sublist);

%Load network assignment (each region is assign a network number (from 1 to 9) which pertains to one of the nine networks)
% and corresponding network names (ordered in the same manner from 1 to 9)
load(networkfile,'p','networknames');


%% Obtain global and network-level segregation measures for each subject
clear seg globalseg
for s=1:length(sublist)
    
    %Load z mat
    load([FCdir, sublist{s} '.mat'],'z_mat');

    %compute segregation measure %negative correlations are removed within the function
    [seg(s,:),globalseg(s,1)]=systemsegregation(z_mat,p);
    
end


%% Write segregation measures of all subjects to a csv file
SegregationT=array2table([sublist, num2cell([globalseg, seg])],'VariableNames',['SubID','Global', networknames]);
writetable(SegregationT, [outputdir, 'Segregationmeasures.csv']);    



