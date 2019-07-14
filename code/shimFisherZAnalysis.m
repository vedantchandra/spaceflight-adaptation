clear; close all;
origin = pwd;
addpath('.')
master = [];
paths = uipickfiles('FilterSpec','/Users/vedantchandra/JHM-Research/spaceflight-adaptation/data/*.csv','output','cell');

for j = 1:length(paths)
    path = paths{j};
    cd(path)
    prefiles = dir('*.csv');
    files = {prefiles.name};
    str = pwd;
    idx = strfind(str,'/');
    subjname = str(idx(end)+1:end);


    file1 = cell(5);
    file2 = cell(5);
    c1 = 1;
    c2 = 1;
    param1 = 'head';
    param2 = 'body';
    

    for i = 1:length(files)
        if startsWith(files{i},'.')
            continue;
        elseif contains(files{i},param1)
            file1{c1} = files{i};
            c1 = c1+1;
        elseif contains(files{i},param2)
            file2{c2} = files{i};
            c2 = c2+1;
        end
    end


    file1 = epochsort(file1);
    file2 = epochsort(file2);

    fisherzs = [];
    errs = [];
    try
        for i = 1:5

           signal1 = load(file1{i});
           signal2 = load(file2{i});
           signal1 = signal1(:,3);
           signal2 = signal2(:,3);

           signal1 = resample(signal1,1,5);
           signal2 = resample(signal2,1,5);

           [z,surrzs] = fisherz(signal1,signal2,0);

           fisherzs = [fisherzs z];
           errs = [errs; surrzs];
        end
    catch
        disp(strcat('Missing file or error in FisherZ Calculation for ',subjname));
        cd(origin)
        break;
    end
    master = [master; fisherzs];
    hold on
    plot(fisherzs,'MarkerSize',12)
    xlim([0,6])
    xlabel('Epoch')
    ylabel('Fisher Z Score')
    xticks([0:6])
    xticklabels({'','UP1', 'UP2' ,'P1','P2' ,'REC',''})
    title(strcat('Fisher Z Correlation Across Epoch-',subjname,'-',param1,'-',param2))
    drawnow;
    cd(origin)
%     savefig(strcat('./plots/fisherZ/',param1,'-',param2,'Fisher_Z_Correlation_Across_Epoch-',subjname))
%     csvwrite(strcat('./meta/',param1,'-',param2,'-fisherz',subjname,'.csv'),fisherzs)
end