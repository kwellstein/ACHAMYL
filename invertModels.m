function invertModels

%% SPECIFY paths and analysis options,

paths.env.workingDir = pwd;
paths.env.toolboxDir = ['..',filesep,'..',filesep,'Toolboxes',filesep]; % Path to you toolbox
paths.env.modelDir   = [paths.env.toolboxDir,'tapas-6.0.1',filesep];
paths.env.spmDir     = [paths.env.toolboxDir,'spm',filesep];
 paths.env.data      = ['..',filesep,'data',filesep]; % path to your datafiles
paths.env.resultsDir = ['..',filesep,'data',filesep]; 

%% SPECIFY MODELS and related functions
options.setupModels       = [];
options.model.space       = {'HGF_3L','eHGF_3L','eHGF_2L','RW'}; % the first one is the original HGF as it is used in Sandra's paper, the others are the enhanced HGFs,and then a RW
options.model.prc         = {'tapas_hgf_binary','tapas_ehgf_binary','tapas_ehgf_binary','tapas_rw_binary'};
options.model.prc_config  = {'tapas_hgf_binary_config_3L','tapas_ehgf_binary_config_3L','tapas_ehgf_binary_config_2L','tapas_rw_binary_config'};
options.model.obs	      = {'tapas_unitsq_sgm','tapas_unitsq_sgm','tapas_unitsq_sgm','tapas_unitsq_sgm'};
options.model.obs_config  = {'tapas_unitsq_sgm_config','tapas_unitsq_sgm_config','tapas_unitsq_sgm_config','tapas_unitsq_sgm_config'};
options.model.opt_config  = {'tapas_quasinewton_optim_config'};
options.plot(1).plot_fits = @tapas_ehgf_plotTraj_mod;
options.plot(2).plot_fits = @tapas_ehgf_plotTraj_mod;
options.plot(3).plot_fits = @tapas_ehgf_plotTraj_mod;
options.plot(4).plot_fits = @tapas_rw_binary_plotTraj;

% optimization algorithm
addpath(genpath(paths.env.modelDir));
savepath((paths.env.modelDir));
% seed for random number generator
options.rng.idx        = 1; % Set counter for random number states
options.rng.settings   = rng(123, 'twister');
options.rng.nRandInit  = 50;

%% SETUP Data file structure
% options.dataSet.acronym = 'DATAFILE_STARTSTRING';
d = dir([paths.env.data,filesep,'pilot*']); % find all files that start with the naming convention for datafiles of thing project
options.dataSet.nParticipants = size(d,1);
% options.dataSet.PIDs = zeros(options.dataSet.nParticipants,1); % setup participant ID array for all participants

for i = 1:options.dataSet.nParticipants
    options.participant(i).dir = [paths.env.data,d(i).name];
    digits = regexp(d(i).name, '[0-9]'); % this is where my IDs appear, your may be different
    PID = str2double(d(i).name(digits)); % get PIDs from datafiles found in folder
    options.dataSet.PIDs(i)  = PID;
    options.participant(i).dataFile = [options.participant(i).dir,filesep,'behav.mat'];

    % make participant specific directories (just in case you
    % wanna use any of this)
    % paths.participant(i).behavDir  = [paths.env.data,d(i).name,filesep,'expData',filesep];
    % paths.participant(i).periphDir = [paths.env.data,d(i).name,filesep,'peripheral',filesep];
    % paths.participant(i).neuroDir  = [paths.env.data,d(i).name,filesep,'neuro',filesep];
    % paths.participant(i).questDir  = [paths.env.data,d(i).name,filesep,'questionnaires',filesep];
    % paths.participant(i).modelDir  = [paths.env.data,d(i).name,filesep,'modeling',filesep];
    % paths.participant(i).resultsDir = [paths.env.data,d(i).name,filesep,'results',filesep];
end

%% INVERT MODELS

for m = 1:numel(options.model.space)
    for n = 1:options.dataSet.nParticipants
        currPID  = options.dataSet.PIDs(n);
        disp(['fitting ', num2str(currPID), ' (',num2str(n),' of ',num2str(options.dataSet.nParticipants),')']);
        load(options.participant(n).dataFile);

        if ~isempty(behav)
            strct              = eval('tapas_quasinewton_optim_config');
            strct.maxStep      = inf;
            strct.nRandInit    = options.rng.nRandInit;
            strct.seedRandInit = options.rng.settings.State(options.rng.idx, 1);

            %% model fit
            est = tapas_fitModel(behav.resp, ...
                behav.outcome, ...
                options.model.prc_config{m}, ...
                options.model.obs_config{m}, ...
                strct); % info for optimization and multistart

            % Plot standard trajectory plot
            options.plot(m).plot_fits(est);
            figName = fullfile([options.participant(n).dir,filesep,'modelInv_',options.model.space{m}]);
            savefig(figName);
            print([figName,'.png'], '-dpng');
            close all
            %Save model fit
            save([options.participant(n).dir,filesep,options.model.space{m},'est.mat'],'-struct','est');
            clear behav;
        else
            disp('datafile was empty....')
        end
    end
end
end
