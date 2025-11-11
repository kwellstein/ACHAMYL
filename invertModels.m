function invertModels

[~,options] = setOptions;
options = setup_configFiles(options);

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
