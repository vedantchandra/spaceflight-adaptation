% 7/15/19: plot entropy

clear all;
close;

%pick all subject folders
trialfold = uipickfiles('filterspec','C:/Users/Spaceexplorers/Documents/GitHub/spaceflight-adaptation/data');
apenfold = 'ApEn';

for subj = 1:length(trialfold)
    filelist = dir(fullfile(trialfold{subj},apenfold,'*.csv'));
    for f = 1:length(filelist)
        data = importdata(fullfile(trialfold{subj},apenfold,filelist(f).name)); %this actually tracks the sides as headers too :O
        en = data.data(:,1:end);
        figure
    end
end
