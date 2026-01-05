function runBMS

%% performBMS
%  Performs Bayesian Model Selection to determine what model in the model
%  space describes the data acquired in the current dataset (cohort) best
%
%   SYNTAX:       preformBMS(cohortNo)
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
%       >>!! NOTE: All the above variables are saved inf the optionsFile struct and specifed here: setDatasetSpecifics.m << !!
%
% Original: 29-05-2024; Katharina V. Wellstein,
%           katharina.wellstein@newcastle.edu.au
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

%% INITIALIZE Variables for running this function

disp('************************************** BAYESIAN MODEL SELECTION **************************************');
disp('*');
disp('*');

% load or run options for running this function
[paths,options] = setOptions;
options = setup_configFiles(options);

% prespecify variables needed for running this function
nModels  = numel(options.model.space);
% model settings
addpath(genpath(paths.env(1).spmDir));

%% LOAD participants
for r = 1:options.model.nRuns
    for n = 1:options.dataSet.nParticipants
        currPID = options.dataSet.PIDs(n);
        for m = 1:nModels
            % load results from real data model inversion
            est = load([options.participant(n,r).resultsdir,filesep,options.model.space{m},'est.mat']);
            if options.model.nRuns>1
                if r==1 
                res.LME(n,m)   = est.optim.LME;
                res.prc_param(n,m).ptrans = est.p_prc.ptrans(options.modelSpace(m).prc_idx);
                res.obs_param(n,m).ptrans = est.p_obs.ptrans(options.modelSpace(m).obs_idx);
                else
                m2 = nModels+m*r;
                res.LME(n,m2)   = est.optim.LME;
                res.prc_param(n,m2).ptrans = est.p_prc.ptrans(options.modelSpace(m).prc_idx);
                res.obs_param(n,m2).ptrans = est.p_obs.ptrans(options.modelSpace(m).obs_idx);
                end
            else
                res.LME(n,m)   = est.optim.LME;
                res.prc_param(n,m).ptrans = est.p_prc.ptrans(options.modelSpace(m).prc_idx);
                res.obs_param(n,m).ptrans = est.p_obs.ptrans(options.modelSpace(m).obs_idx);
            end
        end
    end
end

%% PERFORM rfx BMS
[res.BMS.alpha,res.BMS.exp_r,res.BMS.xp,res.BMS.pxp,res.BMS.bor] = spm_BMS(res.LME);

    % Create figure
    %     pos0 = get(0,'screenSize');
    %     pos = [1,pos0(4)/2,pos0(3)/1.2,pos0(4)/1.2];

    %Plotting details

    figure('WindowState','maximized','Name','BMS individual','Color',[1 1 1]);

    % plot BMS results
    hold on; subplot(1,4,1); bar(1, res.BMS.exp_r(1),'FaceColor',[0.266666666666667 0.447058823529412 0.768627450980392],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,1); bar(2, res.BMS.exp_r(2),'FaceColor',[0.929411764705882 0.490196078431373 0.192156862745098],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,1); bar(3, res.BMS.exp_r(3),'FaceColor',[0.43921568627451 0.67843137254902 0.27843137254902],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,1); bar(4, res.BMS.exp_r(4),'FaceColor',[0.9294    0.6941    0.1255],'EdgeColor',[0.149 0.149 0.149]);
    ylabel ('Posterior probability', 'FontSize', 14,'FontName','Arial'); ylim([0 1]);

    set(gca, 'XTick', []);
    set(gca,'box','off'); get(gca, 'YTick'); set(gca, 'FontSize', 13);
    ax1       = subplot(1,4,1);
    ax1.YTick = [0 0.25 0.5 0.75 1.0];
    ax1.GridLineStyle = ":";
    ax1.XTick = [];
    ax1.YGrid ="on";
    ax1.YTick = [0 0.25 0.5 0.75 1];
    % h_leg     = legend(options.model.space{1},options.model.space{2},options.model.space{3},options.model.space{4}, 'Location', 'northeast');
    % set(h_leg,'box','off','FontSize', 13);
    set(gca, 'color','none');

    hold on; subplot(1,4,2); bar(1, res.BMS.xp(1),'FaceColor',[0.266666666666667 0.447058823529412 0.768627450980392],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,2); bar(2, res.BMS.xp(2),'FaceColor',[0.929411764705882 0.490196078431373 0.192156862745098],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,2); bar(3, res.BMS.xp(3),'FaceColor',[0.43921568627451 0.67843137254902 0.27843137254902],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,2); bar(4, res.BMS.xp(4),'FaceColor',[0.9294    0.6941    0.1255],'EdgeColor',[0.149 0.149 0.149]);
    ylabel('Exceedance probability', 'FontSize', 14,'FontName','Arial'); ylim([0 1]);
    set(gca, 'XTick', []);
    set(gca,'box','off'); get(gca, 'YTick'); set(gca, 'FontSize', 13);
    ax2 = subplot(1,4,2);
    ax2.YTick = [0 0.25 0.5 0.75 1.0];
    ax2.GridLineStyle = ":";
    ax2.XTick = [];
    ax2.YGrid ="on";
    ax2.YTick = [0 0.25 0.5 0.75 1];
    % h_leg2 = legend(options.model.space{1},options.model.space{2},options.model.space{3},options.model.space{4}, 'Location', 'northeast');
    % set(h_leg2,'box','off','FontSize', 13);
    set(gca, 'color', 'none');

    hold on; subplot(1,4,3); bar(1, res.BMS.pxp(1),'FaceColor',[0.266666666666667 0.447058823529412 0.768627450980392],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,3); bar(2, res.BMS.pxp(2),'FaceColor',[0.929411764705882 0.490196078431373 0.192156862745098],'EdgeColor',[0.149 0.149 0.149]);
    hold on; subplot(1,4,3); bar(3, res.BMS.pxp(3),'FaceColor',[0.43921568627451 0.67843137254902 0.27843137254902],'EdgeColor',[0.149 0.149 0.149]);
     hold on; subplot(1,4,3); bar(4, res.BMS.pxp(4),'FaceColor',[0.9294    0.6941    0.1255],'EdgeColor',[0.149 0.149 0.149]);
    ylabel('Protected exceedance probability', 'FontSize', 14,'FontName','Arial'); ylim([0 1]);
    set(gca, 'XTick', []);
    set(gca,'box','off'); get(gca, 'YTick'); set(gca, 'FontSize', 13);
    ax2       = subplot(1,4,3);
    ax2.YTick = [0 0.25 0.5 0.75 1.0];
    ax2.GridLineStyle = ":";
    ax2.XTick = [];
    ax2.YGrid ="on";
    ax2.YTick = [0 0.25 0.5 0.75 1];
    % h_leg2    = legend(options.model.space{1},options.model.space{2},options.model.space{3},options.model.space{4}, 'Location', 'northeast');
    % set(h_leg2,'box','off','FontSize', 13);

    sgtitle('Bayesian Model Selection', 'FontSize', 18,'FontName','Arial');
    set(gcf, 'color', 'white');
    set(gca, 'color', 'none');

    %Save plot
    figdir = fullfile([paths.env.resultsDir,'_BMS']);
    print(figdir, '-dpng', '-r300'); % Higher resolution for publication (300 dpi)
    close all;


    %% Create a new figure for the GROUPED plot
    figure('WindowState','maximized','Name','BMS Grouped','Color',[1 1 1]);

    data = [res.BMS.exp_r; res.BMS.xp; res.BMS.pxp]';

    % Create grouped bar chart
    h = bar(data, 'grouped');
    h(1).FaceColor = [0.266666666666667 0.447058823529412 0.768627450980392]; % Blue for posterior probability
    h(2).FaceColor = [0.929411764705882 0.490196078431373 0.192156862745098]; % Orange for exceedance probability
    h(3).FaceColor = [0.43921568627451 0.67843137254902 0.27843137254902];   % Green for protected exceedance probability

    grid on;
    xlabel('Model', 'FontSize', 14, 'FontName', 'Arial');
    ylabel('Probability', 'FontSize', 14, 'FontName', 'Arial');
    title('Grouped BMS parameters', 'FontSize', 18, 'FontName', 'Arial');
    set(gca, 'XTickLabel', options.model.space, 'FontSize', 13);
    ylim([0 1]);
    set(gca, 'YTick', [0 0.25 0.5 0.75 1.0]);
    legend('Posterior probability', 'Exceedance probability', 'Protected exceedance probability', 'Location', 'best', 'FontSize', 13, 'Box', 'off');
    set(gca, 'Box', 'off');
    set(gcf, 'color', 'white');

    % Save grouped plot
    figdir_grouped = fullfile([paths.env.resultsDir,'BMS_Grouped']);
    print(figdir_grouped, '-dpng', '-r300');

    close all;

    %% Subject-Level Model Comparison Heatmap
    figure('WindowState', 'maximized', 'Name', 'Subject-Level Model Comparison', 'Color', [1 1 1]);

    % Normalise LME per subject to make values comparable
    % Subtract the maximum LME value for each subject (row)
    normalised_lme = res.LME - max(res.LME, [], 2);

    % Create  heatmap
    h = heatmap(options.model.names, subject_labels, normalised_lme);
    h.Title = 'Subject-Level Model Comparison';
    h.XLabel = 'Model';
    h.YLabel = 'Subject ID';
    h.ColorbarVisible = 'on';

    % Using a diverging colormap where:
    % - Best model (0) is dark blue
    % - Slightly worse models are lighter blue
    % - Much worse models are white to red
    colormap(flipud(brewermap(64, '-RdBu')));  % Use ColorBrewer's Red-Blue diverging map (flipped using "-" infront of RdBu)

    max_diff = max(abs(min(normalised_lme(:))), 1);  % Max difference or at least 1
    h.ColorLimits = [-max_diff, 0];  % Scale from most negative value to 0

    h.CellLabelFormat = '%.1f';     % Format cell labels with 1 decimal place
    h.FontSize = 12;
    h.FontName = 'Arial';
    h.GridVisible = 'on';

    annotation('textbox', [0.15, 0.01, 0.7, 0.03], ...
        'String', 'Values show log evidence difference from best model per subject. 0 = best model (blue), more negative = worse fit (white to red).', ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontName', 'Arial');

    % Save the subject-level comparison plot
    figdir_subject = fullfile([paths.env.resultsDir, 'Subject_Level_Comparison']);
    print(figdir_subject, '-dpng', '-r300');
    close all;

disp(['*** Bayesian Model Selection of complete and plots successfully saved to ', paths.env.resultsDir,'. ***']);
end
