clc
clear

%% Initialization

preproc_dir = '/data/project/concussion/Data/research/preprocessed/';
denoised_dir = '/data/project/concussion/Data/research/denoised';

func_TR = 0.728;

subj_list = {'sub-TCLA002'; 'sub-TCLA003'; 'sub-TCLA004'; 'sub-TCLA005';
    'sub-TCLA006'; 'sub-TCLA007'; 'sub-TCLA008'; 'sub-TCLA009';
    'sub-TCLA011'; 'sub-TCLA012'; 'sub-TCLA013'; 'sub-TCLA014';
    
    'sub-TCLC001'; 'sub-TCLC002'; 'sub-TCLC003'; 'sub-TCLC004';
    'sub-TCLC005'; 'sub-TCLC006'; 'sub-TCLC007'; 'sub-TCLC008';
    'sub-TCLC009'; 'sub-TCLC010'; 'sub-TCLC011'; 'sub-TCLC012';
    'sub-TCLC013'; 'sub-TCLC014'; 'sub-TCLC015'; 'sub-TCLC016';
    'sub-TCLC017'; 'sub-TCLC018'; 'sub-TCLC019'; 'sub-TCLC020';
    'sub-TCLC022'; 'sub-TCLC023'; 'sub-TCLC024'; 'sub-TCLC026';
    'sub-TCLC027'; 'sub-TCLC031'; 'sub-TCLC032'; 'sub-TCLC033';
    'sub-TCLC034'; 'sub-TCLC036';
    
    'sub-TCLH354'; 'sub-TCLH361'; 'sub-TCLH371'; 'sub-TCLH377';
    'sub-TCLH409'; 'sub-TCLH457'; 'sub-TCLH476'; 'sub-TCLH490';
    'sub-TCLH492'; 'sub-TCLH520'; 'sub-TCLH593'; 'sub-TCLH725';
    'sub-TCLH840'; 'sub-TCLH851'; 'sub-TCLH867'; 'sub-TCLH958';
    'sub-TCLH964'; 'sub-TCLH980'; 'sub-TCLH991'; };

ses_list = {'ses-1', 'ses-2'};

%% Run the Denoising Loop 
for i = 1:length(subj_list)
    subj = subj_list{i};
    for j =1:length(ses_list)
        ses = ses_list{j};
        if isfolder(fullfile(preproc_dir, subj, ses))
            % =====================================================================
            % reading files
            
            % reading smoothed functional data in the MNI space
            fname = dir(fullfile(preproc_dir, subj, ses, ...
            'func/swra*.nii'));
            func_file = cellstr(fullfile(fname.folder, fname.name));
            % reading structural data in the MNI space
            sname = dir(fullfile(preproc_dir, subj, ses, 'anat/mri/wmsub*.nii'));
            struct_file = cellstr(fullfile(sname.folder, sname.name));
            % reading GM mask in the MNI space
            gname = dir(fullfile(preproc_dir, subj, ses, 'anat/mri/mwp1*.nii'));
            gm_file = cellstr(fullfile(gname.folder, gname.name));
            % reading WM mask in the MNI space
            wname = dir(fullfile(preproc_dir, subj, ses, 'anat/mri/mwp2*.nii'));
            wm_file = cellstr(fullfile(wname.folder, wname.name));
            % reading CSF mask in the MNI space
            cname = dir(fullfile(preproc_dir, subj, ses, 'anat/mri/mwp3*.nii'));
            csf_file = cellstr(fullfile(cname.folder, cname.name));
            
            % reading movement regressors
            movname = dir(fullfile(preproc_dir, subj, ses, ...
                'func/rp_*.txt'));
            mov_file = cellstr(fullfile(movname.folder, movname.name));
            % reading outlier volumes
            outname = dir(fullfile(preproc_dir, subj, ses, ...
                'func/art_regression_outliers_swra*.mat'));
            out_file = cellstr(fullfile(outname.folder, outname.name));
            
            
            % =====================================================================
            % CONN batch initialization
            batch.filename = fullfile(fullfile(preproc_dir, subj, ses, 'conn_temp.mat'));
            
            % =====================================================================
            % CONN Setup
            batch.Setup.nsubjects=1;
            batch.Setup.functionals{1}{1} = func_file;
            batch.Setup.structurals{1} = struct_file;
            batch.Setup.RT = func_TR;
            batch.Setup.conditions.names = {'rest'};
            batch.Setup.conditions.onsets{1}{1}{1} = 0;
            batch.Setup.conditions.durations{1}{1}{1} = inf;
            batch.Setup.masks.Grey{1} = gm_file;
            batch.Setup.masks.White{1} = wm_file;
            batch.Setup.masks.CSF{1} = csf_file;
            batch.Setup.covariates.names = {'movement'; 'outliers'};
            batch.Setup.covariates.files = {mov_file; out_file};
            batch.Setup.analyses = 2;
            batch.Setup.analysisunits = 2;
            batch.Setup.isnew = 1;
            batch.Setup.done = 1;
            
            % =====================================================================
            % CONN Denoising
            batch.Denoising.filter=[0.008, 0.09];
            batch.Denoising.detrending = 1;
            batch.Denoising.confounds.names = {'White Matter'; 'CSF'; ...
                'movement'; 'outliers'};
            batch.Denoising.confounds.deriv = {0, 0, 1, 0};
            batch.Denoising.confounds.dimensions{1} = 5;
            batch.Denoising.confounds.dimensions{2} = 5;
            batch.Denoising.done=1;
            
            % =====================================================================
            % running batch
            conn_batch(batch);
            
            % =====================================================================
            % converting the output to the nifti format and saving it to the save
            % directory
            curr_path = pwd;
            cd(fullfile(preproc_dir, subj, ses, 'conn_temp/results/preprocessing/'));
            conn_matc2nii
            if ~isfolder(fullfile(denoised_dir, subj, ses))
                mkdir(fullfile(denoised_dir, subj, ses));
            end
            movefile('niftiDATA*.nii', fullfile(denoised_dir, subj, ses));
            delete(fullfile(preproc_dir, subj, ses, 'conn_temp.mat'));
            rmdir(fullfile(preproc_dir, subj, ses, 'conn_temp*'), 's');
            cd(curr_path)
            
            % =====================================================================
            % removing unnecessary files and directories
            
        end
    end
end