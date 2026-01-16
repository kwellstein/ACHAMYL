function getModelRegressors(selectedModel,r)



[paths,options] = setOptions();

m = find(strcmp(options.model.space,selectedModel));
for n = 1:options.dataSet.nParticipants
    currPID  = options.dataSet.PIDs(n);
    load([options.participant(n,r).resultsdir,filesep,options.model.space{m},'est.mat']);
    % (i) epsilon2, the precision-weighted PE about visual stimulus outcome
    % (which updates the estimate of visual stimulus probability in logit
    % space). Difference between the actual visual outcome and its a priori
    % probability.

    % choice PE
    iConsist = find(u==1);
    iInconsist = find(u==0);
    iCorrPred = find(y==1);
    iIncorrPred = find(y==0);
    iConsistCorrPred = intersect(iCorrPred,iConsist);
    iConsistIncorrPred = intersect(iIncorrPred,iConsist);
    iInconsistCorrPred = intersect(iCorrPred,iInconsist);
    iInconsistIncorrPred = intersect(iIncorrPred,iInconsist);
    iFace = find(options.model.outcome==1);
    iHouse = find(options.model.outcome==0);
    iHigh = find(options.model.sound==1);
    iLow  = find(options.model.sound==0);

    if any(isnan(y))
        iNaN =find(isnan(y));
    end

    choicePE(iConsistCorrPred)     = 1-traj.muhat(iConsistCorrPred,1);
    choicePE(iInconsistCorrPred)   = traj.muhat(iInconsistCorrPred,1);
    choicePE(iConsistIncorrPred)   = -1*(1-traj.muhat(iConsistIncorrPred,1));
    choicePE(iInconsistIncorrPred) = -1*traj.muhat(iInconsistIncorrPred,1);
    choicePE(iNaN)                 = -1*traj.muhat(iNaN,1);
    if size(choicePE,1)==1
        choicePE = choicePE';
    end

    % outcomePEs
    outcomePE(iConsist)    = 1-traj.muhat(iConsist,1);
    outcomePE(iInconsist) = traj.muhat(iInconsist,1);
    if size(outcomePE,1)==1
        outcomePE = outcomePE';
    end

    % PEs on second and third level
    PE_L2   =  traj.da(:,2);
    PE_L3   =  traj.da(:,3);

    % precision-weighted PEs on second and third level
    pwPE_L2 =  traj.epsi(:,2);
    pwPE_L3 =  traj.epsi(:,3);

    % belief estimates on all levels
    estBeliefs_L1 = traj.muhat(:,1);
    estBeliefs_L2 = traj.muhat(:,2);
    estBeliefs_L3 = traj.muhat(:,3);

    data = [choicePE outcomePE PE_L2 PE_L3 pwPE_L2 pwPE_L3 estBeliefs_L1 estBeliefs_L2 estBeliefs_L3];
    modelRegressors = array2table(data,'VariableNames',...
        {'choicePE','outcomePE','PE_L2','PE_L3','pwPE_L2','pwPE_L3','estBeliefs_L1','estBeliefs_L2','estBeliefs_L3'});
    writetable(modelRegressors,[options.participant(n).resultsdir,filesep,'sub',num2str(currPID),'_modelRegressors.csv']);
    save([options.participant(n,r).resultsdir,filesep,'sub',num2str(currPID),'_modelRegressors.mat'],'modelRegressors');

    est(n).chPE = choicePE;
    est(n).PE_L2 = PE_L2;
    est(n).PE_L3 = PE_L3;
    est(n).pwPE_L2 = pwPE_L2;
    est(n).pwPE_L3 = pwPE_L3;
    est(n).estBeliefs_L1 = estBeliefs_L1;
    est(n).estBeliefs_L2 = estBeliefs_L2;
    est(n).estBeliefs_L3 = estBeliefs_L3;

    plot([1:320],abs(traj.muhat(:,1)));

    hold on
end
PIDs = string(options.dataSet.PIDs);
legend(PIDs);

save([paths.env(1).resultsDir,selectedModel,'_run',num2str(r),'_trialByTrialQuantities.mat'],'est');
figName = fullfile([paths.env(1).resultsDir,filesep,'posteriors_',selectedModel,'_run',num2str(r)]);

savefig(figName);
print([figName,'.png'], '-dpng')
close all
end