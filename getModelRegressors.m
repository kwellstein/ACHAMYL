function getModelRegressors(selectedModel)

[paths,options] = setOptions();

m = find(strcmp(options.model.space,selectedModel));
for n = 1:options.dataSet.nParticipants
    currPID  = options.dataSet.PIDs(n);
    load([options.participant(n).dir,filesep,options.model.space{m},'est.mat']);
    % (i) epsilon2, the precision-weighted PE about visual stimulus outcome 
    % (which updates the estimate of visual stimulus probability in logit
    % space). Difference between the actual visual outcome and its a priori
    % probability.
    chPE    =  traj.ud(:,1);
    PE_L2   =  traj.da(:,2);
    PE_L3   =  traj.da(:,3);
    pwPE_L2 =  traj.epsi(:,2);
    pwPE_L3 =  traj.epsi(:,3);
    estBeliefs_L1 = traj.muhat(:,1);
    estBeliefs_L2 = traj.muhat(:,2);
    estBeliefs_L3 = traj.muhat(:,3);
    data = [chPE PE_L2 PE_L3 pwPE_L2 pwPE_L3 estBeliefs_L1 estBeliefs_L2 estBeliefs_L3];
    modelRegressors = array2table(data,'VariableNames',...
        {'chPE','PE_L2','PE_L3','pwPE_L2','pwPE_L3','estBeliefs_L1','estBeliefs_L2','estBeliefs_L3'});
    writetable(modelRegressors,[options.participant(n).dir,filesep,'sub',num2str(currPID),'_modelRegressors.csv']);
    save([options.participant(n).dir,filesep,'sub',num2str(currPID),'_modelRegressors.mat'],'modelRegressors');
end


end