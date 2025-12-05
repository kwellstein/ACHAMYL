function getParameters(selectedModel)

[paths,options] = setOptions();
options = getGroups(options);

m = find(strcmp(options.model.space,selectedModel));
for n = 1:options.dataSet.nParticipants
    currPID  = options.dataSet.PIDs(n);
    load([options.participant(n).dir,filesep,options.model.space{m},'est.mat']);
    zeta(n,:)= p_obs.ze;
    om2(n,:) = p_prc.om(2);
    om3(n,:) =p_prc.om(3);
end
    data = [options.dataSet.PIDs options.dataSet.groups zeta om2 om3];
    modelParameters = array2table(data,'VariableNames',{'ID','group','zeta','om2','om3'});
    writetable(modelParameters,[paths.env.resultsDir,'modelParameters.csv']);
    save([paths.env.resultsDir,'modelRegressors.mat'],'modelParameters');

end