clc 
clear 

%% Initialization 

% --- Set the following directories --- 

% Directory of the BIDS formated data:
bids_dir = '/data/project/concussion/Data/research/raw/';
% Save directory of the fMRI processing:
save_dir = '/data/project/concussion/Data/research/preprocessed/';

%##########################################################################
% --- Set the Acquisition Parameters --- 

% The name of the functional task
task_name = 'rest';
% Repetition Time (RT) of the functional acquisition (seconds)
func_TR = 0.728; 
% Echo time of (TE) of the functional data (ms)
echo_time = [4.92 7.38];
% Total EPI read-out time (ms)
total_EPI_rot = 17.01;

%##########################################################################
% --- Set the Participants Information --- 

% Subjects list [Ex: {'sub-XXX'; 'sub-YYY'}]
subj_list = {'sub-TCLA002'};
% subj_list = {'sub-TCLA005'; 'sub-TCLA006'; 'sub-TCLA007'; 'sub-TCLA008';
%              'sub-TCLA009'; 'sub-TCLA012'; 'sub-TCLA013'; 'sub-TCLA014';
%              
%              'sub-TCLC001'; 'sub-TCLC002'; 'sub-TCLC003'; 'sub-TCLC004';
%              'sub-TCLC005'; 'sub-TCLC006'; 'sub-TCLC007'; 'sub-TCLC008'; 
%              'sub-TCLC009'; 'sub-TCLC010'; 'sub-TCLC011'; 'sub-TCLC012'; 
%              'sub-TCLC013'; 'sub-TCLC014'; 'sub-TCLC015'; 'sub-TCLC016'; 
%              'sub-TCLC017'; 'sub-TCLC018'; 'sub-TCLC019'; 'sub-TCLC020'; 
%              'sub-TCLC022'; 'sub-TCLC023'; 'sub-TCLC024'; 'sub-TCLC026'; 
%              'sub-TCLC027'; 'sub-TCLC028'; 'sub-TCLC029'; 'sub-TCLC030'; 
%              'sub-TCLC031'; 'sub-TCLC032'; 'sub-TCLC033'; 'sub-TCLC034'; 
%              'sub-TCLC035'; 'sub-TCLC036'; 'sub-TCLC037'; 
%              
%              'sub-TCLH354'; 'sub-TCLH361'; 'sub-TCLH371'; 'sub-TCLH377'; 
%              'sub-TCLH409'; 'sub-TCLH457'; 'sub-TCLH476'; 'sub-TCLH490'; 
%              'sub-TCLH492'; 'sub-TCLH520'; 'sub-TCLH593'; 'sub-TCLH725'; 
%              'sub-TCLH840'; 'sub-TCLH851'; 'sub-TCLH867'; 'sub-TCLH958';
%              'sub-TCLH964'; 'sub-TCLH980'; 'sub-TCLH991'; };

% Sessions list [Ex: {'ses-ZZZ'; 'ses-TTT'}]
ses_list = {'ses-2'};

%##########################################################################
% --- Creating Handy Variables and AddPath Required Directories ---

% Directories Struct
art_dir = which('art');
art_dir(end-4:end) = []; 
spm_dir = which('spm');
spm_dir(end-4:end) = [];
Dirs = struct();
Dirs.bids = bids_dir; 
Dirs.out = save_dir;
Dirs.spm = spm_dir;
Dirs.art = art_dir;

% Acquisition Parameters Struct
AcqParams = struct();
AcqParams.name = task_name;
AcqParams.tr = func_TR; 
AcqParams.et = echo_time;
AcqParams.trot = total_EPI_rot; 

% Subject Information Struct
Subjects(length(subj_list)) = struct();
for i=1:length(subj_list)
    Subjects(i).name = subj_list{i};
    Subjects(i).dir = fullfile(bids_dir, subj_list{i});
    Subjects(i).sessions = ses_list; 
end

% Adding required paths 
addpath(art_dir);
addpath(spm_dir);
addpath(fullfile(spm_dir, 'src'));
addpath('./functions');

%% Functional Pipeline 

for subj_num = 1:numel(subj_list)
    subj = subj_list{subj_num};
    func_PipelineSS(Dirs, Subjects(subj_num), AcqParams);
end