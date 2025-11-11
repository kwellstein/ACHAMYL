function plotPEs

%% SPECIFY paths and analysis options,

paths.env.workingDir = pwd;
paths.env.data       = ['..',filesep,'data',filesep]; % path to your datafiles
paths.env.resultsDir = ['..',filesep,'data',filesep];
options.model.space  = {'HGF_3L','eHGF_3L','eHGF_2L'}; % the first one is the original HGF as it is used in Sandra's paper, the others are the enhanced HGFs,and then a RW

dm = dir([paths.env.data,filesep,'run*']);
options.model.nPriorSettings = 3;%size(dm,1);

for r = 3:options.model.nPriorSettings
    options.modelRun(r).dir = [paths.env.data,dm(r).name];
    digits = regexp(dm(r).name, '[0-9]'); % this is where my IDs appear, your may be different
    runNo = str2double(dm(r).name(digits)); % get PIDs from datafiles found in folder
    options.model.runs(r)  = runNo;

    d = dir([options.modelRun(r).dir,filesep,'main*']); % find all files that start with the naming convention for datafiles of thing project
    options.dataSet.nParticipants = size(d,1);

    for m = 1:numel(options.model.space)-1
            disp(['plotting ', ' run number',num2str(runNo),' of ',num2str(options.model.nPriorSettings),' with model ', ...
                options.model.space{m}, '...']);
            figure;
        for n = 1:options.dataSet.nParticipants
            options.participant(n).dir = [options.modelRun(r).dir,filesep,d(n).name];
            digits = regexp(d(n).name, '[0-9]'); % this is where my IDs appear, your may be different
            PID = str2double(d(n).name(digits)); % get PIDs from datafiles found in folder
            options.dataSet.PIDs(n)  = PID;
            load([options.participant(n).dir,filesep,options.model.space{m},'est.mat']);
            plot(traj.epsi(:,3));
            hold on
        end
            figName = fullfile([options.modelRun(r).dir,filesep,'PEs3L_',options.model.space{m}]);
            savefig(figName);
            print([figName,'.png'], '-dpng');
    end
        for m = 1:numel(options.model.space)
            disp(['plotting ', ' run number',num2str(runNo),' of ',num2str(options.model.nPriorSettings),' with model ', ...
                options.model.space{m}, '...']);
            figure;
        for n = 1:options.dataSet.nParticipants
            options.participant(n).dir = [options.modelRun(r).dir,filesep,d(n).name];
            digits = regexp(d(n).name, '[0-9]'); % this is where my IDs appear, your may be different
            PID = str2double(d(n).name(digits)); % get PIDs from datafiles found in folder
            options.dataSet.PIDs(n)  = PID;
            load([options.participant(n).dir,filesep,options.model.space{m},'est.mat']);
            plot(traj.epsi(:,2));
            hold on
        end
            figName = fullfile([options.modelRun(r).dir,filesep,'PEs2L_',options.model.space{m}]);
            savefig(figName);
            print([figName,'.png'], '-dpng');
    end
end
end