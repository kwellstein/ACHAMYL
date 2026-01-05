function plotPEs

%% SPECIFY paths and analysis options,
% the first one is the original HGF as it is used in Sandra's paper, the others are the enhanced HGFs,and then a RW
[paths,options] = setOptions;

for r = 1:options.model.nRuns
    for m = 1:numel(options.model.space)
            disp(['plotting ', ' run number',num2str(r),' of ',num2str(options.model.nRuns),' with model ', ...
                options.model.space{m}, '...']);
            figure;
        for n = 1:options.dataSet.nParticipants
            load([options.participant(n,r).resultsdir,filesep,options.model.space{m},'est.mat']);
            plot(traj.epsi(:,3));
            hold on
        end
            figName = fullfile([paths.env.resultsDir,'run',num2str(r),filesep,'run',num2str(r),'_PEs3L_',options.model.space{m}]);
            savefig(figName);
            print([figName,'.png'], '-dpng');
    end
        for m = 1:numel(options.model.space)
            disp(['plotting ', ' run number',num2str(r),' of ',num2str(options.model.nRuns),' with model ', ...
                options.model.space{m}, '...']);
            figure;
        for n = 1:options.dataSet.nParticipants
            
            load([options.participant(n,r).resultsdir,filesep,options.model.space{m},'est.mat']);
            plot(traj.epsi(:,2));
            hold on
        end
            figName = fullfile([paths.env.resultsDir,'run',num2str(r),filesep,'run',num2str(r),'_PEs2L_',options.model.space{m}]);
            savefig(figName);
            print([figName,'.png'], '-dpng');
    end
end
end