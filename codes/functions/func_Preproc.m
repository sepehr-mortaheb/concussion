function func_Preproc(inpfiles, Dirs, subj, ses, AcqParams)

save_path = Dirs.out; 
subj_name = subj.name;
TR = AcqParams.tr; 

%% Run Preprocessing Batch
spm fmri;
matlabbatch = func_PreprocBatch(inpfiles, AcqParams, Dirs);
spm_jobman('run', matlabbatch)

%% Deleting unnecessary files and moving results to the related folder
 
% Functional data
motionCorrectedDir = fullfile(save_path, subj_name, ses, 'func');
mkdir(motionCorrectedDir);
datapath = fullfile(subj.dir, ses, 'func');
delete(fullfile(datapath, ['rau' subj.name '_' ses '_task-rest_bold.nii']));
delete(fullfile(datapath, ['rau' subj.name '_' ses '_task-rest_bold.mat']));
delete(fullfile(datapath, ['meanrau' subj.name '_' ses '_task-rest_bold.nii']));
delete(fullfile(datapath, ['swmeanrau' subj.name '_' ses '_task-rest_bold.nii']));
delete(fullfile(datapath, ['u' subj.name '_' ses '_task-rest_bold.nii']));
delete(fullfile(datapath, ['wmeanrau' subj.name '_' ses '_task-rest_bold.nii']));
movefile(fullfile(datapath, ['swrau' subj.name '_' ses '_task-rest_bold.nii']), motionCorrectedDir);
movefile(fullfile(datapath, ['rp_' subj.name '_' ses '_task-rest_bold.txt']), motionCorrectedDir);
movefile(fullfile(datapath, ['wrau' subj.name '_' ses '_task-rest_bold.nii']), motionCorrectedDir);
 
% GRE-Field Data
peresDir = fullfile(save_path, subj_name, ses, 'fmap');
mkdir(peresDir);
datapath = fullfile(subj.dir, ses, 'fmap');
delete(fullfile(datapath, ['fpm_sc' subj.name '_' ses '_task-rest_phasediff.nii']));
delete(fullfile(datapath, ['sc' subj.name '_' ses '_task-rest_phasediff.nii']));
movefile(fullfile(datapath, ['vdm5_sc' subj.name '_' ses '_task-rest_phasediff.nii']), peresDir);
 
% Structural Data
stresDir = fullfile(save_path, subj_name, ses, 'anat');
mkdir(stresDir);
datapath = fullfile(subj.dir, ses, 'anat');
movefile(fullfile(datapath, 'report/'), stresDir);
movefile(fullfile(datapath, 'mri/'), stresDir);
 
%% Run Artifact Detection Batch
  
clear matlabbatch;
[matlabbatch, art_pth] = func_ArtDetection_batch(motionCorrectedDir, save_path, subj_name, ses, TR);
spm_jobman('serial', matlabbatch);
art_batch(fullfile(art_pth, 'SPM.mat'));