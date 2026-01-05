function getParameters(selectedModel)

[paths,options] = setOptions();
options         = getGroups(options);

bopars = tapas_fitModel([],...
                        options.model.inputs,...
                         'tapas_hgf_binary_config_3L',...
                         'tapas_bayes_optimal_binary_config',...
                         'tapas_quasinewton_optim_config');

m = find(strcmp(options.model.space,selectedModel));
for n = 1:options.dataSet.nParticipants
    currPID  = options.dataSet.PIDs(n);
    load([options.participant(n).resulltsdir,filesep,options.model.space{m},'est.mat']);
    zeta(n,:)= p_obs.ze;
    om2(n,:) = p_prc.om(2);
    ka2(n,:) = p_prc.ka(2);
    om3(n,:) = p_prc.om(3);
    dabsbo_om2(n,:) = abs(bopars.p_prc.om(2))-abs(p_prc.om(2));
    dabsbo_ka2(n,:) = abs(bopars.p_prc.ka(2))-abs(p_prc.ka(2));
    dabsbo_om3(n,:) = abs(bopars.p_prc.om(3))-abs(p_prc.om(3));
    dbo_om2(n,:) = bopars.p_prc.om(2)-p_prc.om(2);
    dbo_ka2(n,:) = bopars.p_prc.ka(2)-p_prc.ka(2);
    dbo_om3(n,:) = bopars.p_prc.om(3)-p_prc.om(3);
end
    data = [string(options.dataSet.PIDs)' options.dataSet.groupID' zeta om2 ka2 om3 dabsbo_om2 dabsbo_ka2 dabsbo_om3 dbo_om2 dbo_ka2 dbo_om3];
    modelParameters = array2table(data,'VariableNames',{'ID','group','zeta','om2','ka2','om3', 'dabsbo_om2','dabsbo_ka2', 'dabsbo_om3', 'dbo_om2','dbo_ka2', 'dbo_om3'});
    writetable(modelParameters,[paths.env.resultsDir,'modelParameters.csv']);
    save([paths.env.resultsDir,'modelRegressors.mat'],'modelParameters');

end