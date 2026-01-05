function [] = parameterRecovery(selectedModel)

%% parameter_recovery
%  Parameter recovery analysis based on simulations. This step will be
%  executed if optionsFile.doSimulations = 1;
%
%   SYNTAX:       parameter_recovery(cohortNo,{'treatment','controls',[]})
%
%   IN: cohortNo:  integer, cohort number, see optionsFile for what cohort
%                            corresponds to what number in the
%                            optionsFile.cohort(cohortNo).name struct.
%
%       subCohort: string, {'control','treatment'} OR [], if you are running this
%                           function for all subCohorts use [], otherwise specify using the appropriate string
%
%       iTask: integer, task number see optionsFile for what task
%                            corresponds to what number.
%
%       iCondition: integer, condition number. See optionsFile for what what place in the cell {cond1, cond2...}
%                            the condition that you want to run this function for in appears. If you are calling
%                            this function from the runAnalysis.m or another wrapper function, loop through
%                            conditions there.
%
%       iRep:       integer, repetition number. iRep= 1 if the current Task is not repeated more than once in this cohort.
%
%       nReps:      integer, number or repetitions this cohort has. nReps = 1 if the current Task is not repeated more than once in this cohort.
%                            This is needed for the getFileName.m function.
%
%       >>!! NOTE: All the above variables are saved inf the optionsFile struct and specifed here: setDatasetSpecifics.m << !!
%
%
% Coded by: 2025; Katharina V. Wellstein,
%           katharina.wellstein@newcastle.edu.au
%           https://github.com/kwellstein
%
% -------------------------------------------------------------------------
% This file is released under the terms of the GNU General Public Licence
% (GPL), version 3. You can redistribute it and/or modify it under the
% terms of the GPL (either version 3 or, at your option, any later version).
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details:
% <http://www.gnu.org/licenses/>
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% _________________________________________________________________________
% =========================================================================

%% INITIALIZE options and variables needed to run this function
disp('************************************** PARAMETER RECOVERY **************************************');
disp('*');
disp('*');


% load or run options for running this function
[paths,options] = setOptions();
options         = getGroups(options);
options         = setup_configFiles(options);

% prespecify variables needed for running this function



%% LOAD inverted participant data
m = find(strcmp(options.model.space,selectedModel));

for r = 1:options.model.nRuns
    % load simulated responses with current model
    simResp = load([paths.env(r).simulationsDir,'sim.mat']);
    for n = 1:options.dataSet.nParticipants
        currPID  = options.dataSet.PIDs(n);
        % load results from real data model inversion
        rec.est(n).data = load([options.participant(n,r).resultsdir,filesep,options.model.space{m},'est.mat']);

        % param values in transformed space (assumption of Gaussian prior)
        rec.param.prc.estAgent(n,:) = rec.est(n).data.p_prc.ptrans(options.modelSpace(m).prc_idx);
        rec.param.obs.estAgent(n,:) = rec.est(n).data.p_obs.ptrans(options.modelSpace(m).obs_idx);

        rec.param.prc.simAgent(n,:) = simResp.input(n).input.prc.transInp(options.modelSpace(m).prc_idx);
        rec.param.obs.simAgent(n,:) = simResp.input(n).input.obs.transInp(options.modelSpace(m).obs_idx);
    end % END PARTICIPANT Loop

    %% CALCULATE Pearson's Correlation Coefficient

    % Perceptual Model parameters
    for pRec = 1:length(options.modelSpace(m).prc_idx)
        [prc_coef,prc_p] = corr(rec.param.prc.simAgent(:,pRec),...
            rec.param.prc.estAgent(:,pRec));
        rec.param.prc.pcc(pRec)  = diag(prc_coef);
        rec.param.prc.pval(pRec) = diag(prc_p);

        % Observational Model parameters
        for pObs= 1:length(options.modelSpace(m).obs_idx)
            [obs_coef,obs_p] = corr(rec.param.obs.simAgent(:,pObs),...
                rec.param.obs.estAgent(:,pObs));
            rec.param.obs.pcc(pObs)  = diag(obs_coef);
            rec.param.obs.pval(pObs) = diag(obs_p);
        end
    end

    %% PLOT correlation plot
    tiledlayout('flow');
    figure('Color',[1,1,1],'pos',[10 10 1050 500]);
    % Perceptual Model
    for pPrc = 1:size(options.modelSpace(m).prc_idx,2)
        nexttile;
        scatter(rec.param.prc.simAgent(:,pPrc),rec.param.prc.estAgent(:,pPrc),'filled');
        lsline;
        ylim([(min(rec.param.prc.estAgent(:,pPrc))-0.1) (max(rec.param.prc.estAgent(:,pPrc))+0.1)]);
        [t,~] = title([options.model.space{m},' ',options.modelSpace(m).free_expnms_mu_prc{pPrc},...
            'rho = ' num2str(rec.param.prc.pcc(pPrc))]);
        t.FontSize = 18;
        xlabel('simulated data')
        ylabel('estimated data')
        hold on;
    end

    % Observational Model
    for pObs = 1:size(options.modelSpace(m).obs_idx,2)
        nexttile;
        scatter(rec.param.obs.simAgent(:,pObs),rec.param.obs.estAgent(:,pObs),'filled');
        lsline;
        ylim([(min(rec.param.obs.estAgent(:,pObs))-0.1) (max(rec.param.obs.estAgent(:,pObs))+0.1)]);
        [t,~] = title([options.model.space{m},' ',options.modelSpace(m).free_expnms_mu_obs{pObs},...
            'rho = ' num2str(rec.param.obs.pcc(pObs))]);
        t.FontSize = 18;
        hold on;
        xlabel('simulated data')
        ylabel('estimated data')
        hold on;
    end

    if options.model.nRuns>1
        figDir = fullfile([char(paths.env(1).resultsDir),'run',num2str(r),filesep,'run',num2str(r),'_',selectedModel,'_Parameter_recovery']);
    else
        figDir = fullfile([char(paths.env(1).resultsDir),'Parameter_recovery']);
    end
    savefig([figDir,'.fig']);
    print([figDir, '.png'],'-dpng');
    close all;
    %% PLOT PRIORS AND POSTERIORS
    % perceptual model
    % for j = 1:size(options.modelSpace(m).prc_idx,2) %rec.est(iMouse,iModel).task(iTask,iRep).data
    %     hgf_plot_param_pdf(options.modelSpace(m).free_expnms_mu_prc,rec.est(:,m),options.modelSpace(m).prc_idx(j),j,'prc');
    % 
    %     if options.model.nRuns>1
    %         figdir   = fullfile(char(paths.env(1).resultsDir),['run',num2str(r),filesep,'prc_priors_posteriors',...
    %             char(options.model.space{m}),'_',options.modelSpace(m).free_expnms_mu_prc{j}]);
    %     else
    %         figdir   = fullfile(char(paths.env(1).resultsDir),['prc_priors_posteriors',...
    %             char(options.model.space{m}),'_',options.modelSpace(m).free_expnms_mu_prc{j}]);
    %     end
    %     print(figdir, '-dpng');
    %     close;
    % end
    % 
    % % observational model
    % for k = 1:size(options.modelSpace(m).obs_idx,2)
    %     hgf_plot_param_pdf(options.modelSpace(m).free_expnms_mu_prc,rec.est(:,m),options.modelSpace(m).obs_idx(k),'obs');
    %     if options.model.nRuns>1
    %         figdir   = fullfile(char(paths.env(1).resultsDir),['run',num2str(r),filesep,'obs_priors_posteriors_model_',...
    %             char(options.model.space{m}),'_',options.modelSpace(m).free_expnms_mu_obs{k}]);
    %     else
    %         figdir   = fullfile(char(paths.env(1).resultsDir),['obs_priors_posteriors_model_',...
    %             char(options.model.space{m}),'_',options.modelSpace(m).free_expnms_mu_obs{k}]);
    %     end
    %     print(figdir, '-dpng');
    %     close;
    % end
    %% SAVE results as struct
    if options.model.nRuns>1
        save([char(paths.env(1).resultsDir),'run',num2str(r),filesep,'run',num2str(r),'_',selectedModel,'_rec.mat'], '-struct', 'rec');
    else
        save(char(paths.env(1).resultsDir), '-struct', 'rec');
    end

end %END runs loop
close all



disp('recovery analysis complete.')

end
