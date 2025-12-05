function options = getGroups(options)

positivePIDs = [161424,296363,509044,518640,559388,763499];
negativePIDs = [515344,587159,669258,705478,716408,974796];

for i = 1:options.dataSet.nParticipants

    if any(positivePIDs==options.dataSet.PIDs(i))
        options.dataSet.group{i} = 'positive';
        options.dataSet.groupID(i) = 1;
    else
        options.dataSet.group{i} = 'negative';
        options.dataSet.groupID(i) = -1;
    end

end


end