function getModelRegressors(selectedModel)

[paths,options] = setOptions();

m = find(strcmp(options.model.space,selectedModel));
for n = 1:options.dataSet.nParticipants
    currPID  = options.dataSet.PIDs(n);
    load([options.participant(n).dir,filesep,options.model.space{m},'est.mat']);
    PE_L1   =  traj.da(:,1);
    pwPE_L2 =  traj.epsi(:,2);
    pwPE_L3 =  traj.epsi(:,3);
    estBeliefs_L1 = traj.muhat(:,1);
    estBeliefs_L2 = traj.muhat(:,2);
    data = [PE_L1 pwPE_L2 pwPE_L3 estBeliefs_L1 estBeliefs_L2];
    modelRegressors = array2table(data,'VariableNames',...
        {'PE_L1','pwPE_L2','pwPE_L3','estBeliefs_L1','estBeliefs_L2'});
    writetable(modelRegressors,[options.participant(n).dir,filesep,'sub',num2str(currPID),'_modelRegressors.csv']);
    save([options.participant(n).dir,filesep,'sub',num2str(currPID),'_modelRegressors.mat'],'modelRegressors');
end


end