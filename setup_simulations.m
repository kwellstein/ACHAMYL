function setup_simulations

%% setup_simulations
%  Simulat synthetic agents using priors determined from pilot dataset
%
%   SYNTAX:       setup_simulations
%
% Original: Katharina V. Wellstein
%           https://github.com/kwellstein
% -------------------------------------------------------------------------
% Copyright (C) 2025
%
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

disp('************************************** SETUP_SIMULATIONS **************************************');
disp('*');
disp('*');

% load or run options for running this function
[paths,options] = setOptions;
options = setup_configFiles(options);

% prespecify variables needed for running this function
nModels  = numel(options.model.space);
nSamples = 10;
sim.agent = struct();
sim.input = struct();


%% GENERATE synthetic agents using default priors from toolbox

for iAgent = 1:10
    for iModel = 1:nModels
        % sample free parameter values
        input.prc.transInp = options.modelSpace(iModel).prc_config.priormus;
        input.obs.transInp = options.modelSpace(iModel).obs_config.priormus;

        for iPerc = 1:size(options.modelSpace(iModel).prc_idx,2)
            input.prc.transInp(options.modelSpace(iModel).prc_idx(iPerc)) = ...
                normrnd(options.modelSpace(iModel).prc_config.priormus(options.modelSpace(iModel).prc_idx(iPerc)),...
                abs(sqrt(options.modelSpace(iModel).prc_config.priorsas(options.modelSpace(iModel).prc_idx(iPerc)))));
        end

        for iObs = 1:size(options.modelSpace(iModel).obs_idx,2)
            input.obs.transInp(options.modelSpace(iModel).obs_idx(iObs)) = ...
                normrnd(options.modelSpace(iModel).obs_config.priormus(options.modelSpace(iModel).obs_idx(iObs)),...
                abs(sqrt(options.modelSpace(iModel).obs_config.priorsas(options.modelSpace(iModel).obs_idx(iObs)))));
        end

        c.c_prc = options.modelSpace(iModel).prc_config;
        input.prc.nativeInp = options.modelSpace(iModel).prc_config.transp_prc_fun(c, input.prc.transInp);
        c.c_obs = options.modelSpace(iModel).obs_config;
        input.obs.nativeInp = options.modelSpace(iModel).obs_config.transp_obs_fun(c, input.obs.transInp);

        % simulate predictions for SNR calculation
        stable = 0;


        while stable == 0
            % try %sim = tapas_simModel(inputs, prc_model, prc_pvec, obs_model, obs_pvec)
                data = tapas_simModel(options.model.inputs,...
                    options.modelSpace(iModel).prc,...
                    input.prc.nativeInp,...
                    options.modelSpace(iModel).obs,...
                    input.obs.nativeInp,...
                    options.rng.settings.State(options.rng.idx));
                stable = 1;

            % catch
            %     fprintf('simulation failed for Model %1.0f, synth. Sub %1.0f \n', [iModel, iAgent]);
            %     fprintf('Prc Param Values: \n');
            %     input.prc.nativeInp
            %     fprintf('Obs Param Values: \n');
            %     input.obs.nativeInp
            %     % re-sample prc param values
            %     for j = 1:size(options.modelSpace(iModel).prc_idx,2)
            %         input.prc.transInp(options.modelSpace(iModel).prc_idx(j)) = ...
            %             normrnd(options.modelSpace(iModel).prc_config.priormus(options.modelSpace(iModel).prc_idx(j)),...
            %             abs(sqrt(options.modelSpace(iModel).prc_config.priorsas(options.modelSpace(iModel).prc_idx(j)))));
            %     end
            %     input.prc.nativeInp = options.modelSpace(iModel).prc_config.transp_prc_fun(c, input.prc.transInp);
            %     stable = 0;
            % end
            % save simulation input
            sim.agent(iAgent,iModel).data  = data;
            sim.agent(iAgent,iModel).input = input;

            % Update the rng state idx
            options.rng.idx     = options.rng.idx+1;
            if options.rng.idx == (length(options.rng.settings.State)+1)
                options.rng.idx = 1;
            end

        end
    end % END MODEL loop
end % END AGENTS loop

%% SAVE model simulation specs as struct
save([paths.env.data,filesep,'sim.mat'], '-struct', 'sim');

%% PLOT predictions
for iModel = 1:nModels
    for iAgent = 1:nSamples

        if any(strcmp('muhat',fieldnames(sim.agent(iAgent,iModel).data.traj)))
            plot(sim.agent(iAgent,iModel).data.traj.muhat(:,1), 'color', options.col.tnub);
            ylabel('$\hat{\mu}_{1}$', 'Interpreter', 'Latex')
        else
            plot(sim.agent(iAgent,iModel).data.traj.vhat(:,1), 'color', options.col.tnub);
            ylabel('v_hat')
        end

        hold on;
    end

    %Create figure of trajectory
    ylim([-0.1 1.1])
    plot(sim.agent(1,iModel).data.u,'o','Color','b');
    % plot(options.task.probStr,'Color','b');
    xlabel('Trials');
    ylabel('Reward Probability');
    txt = ['Simulation results from',num2str(nSamples),'with ', options.model.prc{iModel}];
    title(txt)
    hold on
    set(gcf, 'color', 'none');   %transparent background
    set(gca, 'color', 'none');   %transparent background
    xticks(0:40:numel(options.model.inputs))
    hold on;

    figdir = fullfile([char(paths.env.resultsDir),'sim',filesep,'predictions_',options.model.space{iModel}]);
    save([figdir,'.fig'])
    print(figdir, '-dpng');
    close;
end
% reset rng state idx
options.rng.idx = 1;


disp('simulated data for cohort  successfully created.');

end