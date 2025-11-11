function options = setup_configFiles(options)

%    IN: cohortNo:  integer, cohort number, see options for what cohort
%                            corresponds to what number in the
%                            options.cohort(cohortNo).name struct. This
%                            allows to run the pipeline and its functions for different
%                            cohorts whose expcifications have been set in runOptions.m

%% SETUP config files for Perceptual models

    modelSpace = struct();
    for m = 1:numel(options.model.space)
        modelSpace(m).prc           = options.model.prc{m};
        modelSpace(m).prc_config    = eval(options.model.prc_config{m});
        pr = priorPrep(options.model.inputs);

        % Replace placeholders in parameter vectors with their calculated values
        modelSpace(m).prc_config.priormus(modelSpace(m).prc_config.priormus==99991)  = pr.plh.p99991;
        modelSpace(m).prc_config.priorsas(modelSpace(m).prc_config.priorsas==99991)  = pr.plh.p99991;

        modelSpace(m).prc_config.priormus(modelSpace(m).prc_config.priormus==99992)  = pr.plh.p99992;
        modelSpace(m).prc_config.priorsas(modelSpace(m).prc_config.priorsas==99992)  = pr.plh.p99992;

        modelSpace(m).prc_config.priormus(modelSpace(m).prc_config.priormus==99993)  = pr.plh.p99993;
        modelSpace(m).prc_config.priorsas(modelSpace(m).prc_config.priorsas==99993)  = pr.plh.p99993;

        modelSpace(m).prc_config.priormus(modelSpace(m).prc_config.priormus==-99993) = -pr.plh.p99993;
        modelSpace(m).prc_config.priorsas(modelSpace(m).prc_config.priorsas==-99993) = -pr.plh.p99993;

        modelSpace(m).prc_config.priormus(modelSpace(m).prc_config.priormus==99994)  = pr.plh.p99994;
        modelSpace(m).prc_config.priorsas(modelSpace(m).prc_config.priorsas==99994)  = pr.plh.p99994;

        % Get fieldnames. If a name ends on 'mu', that field defines a prior mean.
        % If it ends on 'sa', it defines a prior variance.
        names  = fieldnames(modelSpace(m).prc_config);
        fields = struct2cell(modelSpace(m).prc_config);

        % Loop over names
        for n = 1:length(names)
            if regexp(names{n}, 'mu$')
                priormus = [];
                priormus = [priormus, modelSpace(m).prc_config.(names{n})];
                priormus(priormus==99991)  = pr.plh.p99991;
                priormus(priormus==99992)  = pr.plh.p99992;
                priormus(priormus==99993)  = pr.plh.p99993;
                priormus(priormus==-99993) = -pr.plh.p99993;
                priormus(priormus==99994)  = pr.plh.p99994;
                modelSpace(m).prc_config.(names{n}) = priormus;
                clear priormus;

            elseif regexp(names{n}, 'sa$')
                priorsas = [];
                priorsas = [priorsas, modelSpace(m).prc_config.(names{n})];
                priorsas(priorsas==99991)  = pr.plh.p99991;
                priorsas(priorsas==99992)  = pr.plh.p99992;
                priorsas(priorsas==99993)  = pr.plh.p99993;
                priorsas(priorsas==-99993) = -pr.plh.p99993;
                priorsas(priorsas==99994)  = pr.plh.p99994;
                modelSpace(m).prc_config.(names{n}) = priorsas;
                clear priorsas;
            end
        end
        % find parameter names of mus and sas:
        expnms_mu_prc=[];
        expnms_sa_prc=[];
        n_idx      = 0;
        for k = 1:length(names)
            if regexp(names{k}, 'mu$')
                for l= 1:length(fields{k})
                    n_idx = n_idx + 1;
                    expnms_mu_prc{1,n_idx} = [names{k},'_',num2str(l)];
                end
            elseif regexp(names{k}, 'sa$')
                for l= 1:length(fields{k})
                    n_idx = n_idx + 1;
                    expnms_sa_prc{1,n_idx} = [names{k},'_',num2str(l)];
                end
            end
        end
        modelSpace(m).expnms_mu_prc=expnms_mu_prc(~cellfun('isempty',expnms_mu_prc));
        modelSpace(m).expnms_sa_prc=expnms_sa_prc(~cellfun('isempty',expnms_sa_prc));
    end
    % SETUP config files for Observational models
    for m = 1:numel(options.model.space)
        modelSpace(m).name       = options.model.space{m};
        modelSpace(m).obs        = options.model.obs{m};
        modelSpace(m).obs_config = eval(options.model.obs_config{m});

        % Get fieldnames. If a name ends on 'mu', that field defines a prior mean.
        % If it ends on 'sa', it defines a prior variance.
        names  = fieldnames(modelSpace(m).obs_config);
        fields = struct2cell(modelSpace(m).obs_config);
        % find parameter names of mus and sas:
        expnms_mu_obs=[];
        expnms_sa_obs=[];
        n_idx      = 0;
        for k = 1:length(names)
            if regexp(names{k}, 'mu$')
                for l= 1:length(fields{k})
                    n_idx = n_idx + 1;
                    expnms_mu_obs{1,n_idx} = [names{k},'_',num2str(l)];
                end
            elseif regexp(names{k}, 'sa$')
                for l= 1:length(fields{k})
                    n_idx = n_idx + 1;
                    expnms_sa_obs{1,n_idx} = [names{k},'_',num2str(l)];
                end
            end
        end
        modelSpace(m).expnms_mu_obs=expnms_mu_obs(~cellfun('isempty',expnms_mu_obs));
        modelSpace(m).expnms_sa_obs=expnms_sa_obs(~cellfun('isempty',expnms_sa_obs));
    end
    % Find free parameters & convert parameters to native space
    for m = 1:numel(options.model.space)

        % Perceptual model
        prc_idx = modelSpace(m).prc_config.priorsas;
        prc_idx(isnan(prc_idx)) = 0;
        modelSpace(m).prc_idx = find(prc_idx);
        % find names of free parameters:
        modelSpace(m).free_expnms_mu_prc=modelSpace(m).expnms_mu_prc(modelSpace(m).prc_idx);
        modelSpace(m).free_expnms_sa_prc=modelSpace(m).expnms_sa_prc(modelSpace(m).prc_idx);
        c.c_prc = (modelSpace(m).prc_config);
        % transform values into natural space for the simulations
        modelSpace(m).prc_mus_vect_nat = c.c_prc.transp_prc_fun(c, c.c_prc.priormus);
        modelSpace(m).prc_sas_vect_nat = c.c_prc.transp_prc_fun(c, c.c_prc.priorsas);

        % Observational model
        obs_idx = modelSpace(m).obs_config.priorsas;
        obs_idx(isnan(obs_idx)) = 0;
        modelSpace(m).obs_idx = find(obs_idx);
        % find names of free parameters:
        modelSpace(m).free_expnms_mu_obs=modelSpace(m).expnms_mu_obs(modelSpace(m).obs_idx);
        modelSpace(m).free_expnms_sa_obs=modelSpace(m).expnms_sa_obs(modelSpace(m).obs_idx);
        c.c_obs = (modelSpace(m).obs_config);
        % transform values into natural space for the simulations
        modelSpace(m).obs_vect_nat = c.c_obs.transp_obs_fun(c, c.c_obs.priormus);
    end

    options.modelSpace = modelSpace;

    % colors for plotting
    options.col.wh   = [1 1 1];
    options.col.gry  = [0.5 0.5 0.5];
    options.col.tnub = [186 85 211]/255;  %186,85,211 purple %blue 0 110 182
    options.col.tnuy = [255 166 22]/255;
    options.col.grn  = [0 0.6 0];

    options.doOptions = 0;


%% NOTE: THIS IS A COPY from hgf function tapas_fitModel:
% --------------------------------------------------------------------------------------------------
    function pr = priorPrep(options)

        % Initialize data structure to be returned
        pr = struct;

        % Store responses and inputs
        pr.u  = options;

        % Calculate placeholder values for configuration files

        % First input
        % Usually a good choice for the prior mean of mu_1
        pr.plh.p99991 = pr.u(1,1);

        % Variance of first 20 inputs
        % Usually a good choice for the prior variance of mu_1
        if length(pr.u(:,1)) > 20
            pr.plh.p99992 = var(pr.u(1:20,1),1);
        else
            pr.plh.p99992 = var(pr.u(:,1),1);
        end

        % Log-variance of first 20 inputs
        % Usually a good choice for the prior means of log(sa_1) and alpha
        if length(pr.u(:,1)) > 20
            pr.plh.p99993 = log(var(pr.u(1:20,1),1));
        else
            pr.plh.p99993 = log(var(pr.u(:,1),1));
        end

        % Log-variance of first 20 inputs minus two
        % Usually a good choice for the prior mean of omega_1
        if length(pr.u(:,1)) > 20
            pr.plh.p99994 = log(var(pr.u(1:20,1),1))-2;
        else
            pr.plh.p99994 = log(var(pr.u(:,1),1))-2;
        end

    end % function priorPrep
% --------------------------------------------------------------------------------------------------

%% SAVE options file
% save([options.paths.projDir,'options.mat'],'options');

end