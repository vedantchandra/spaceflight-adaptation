%% 6/10/19: Keystroke Analysis: uses keysgen, keysmistake, WPM

clear all;
close;

subjfolders = uipickfiles;
%switchtimesheet = importdata('/Users/SYT/Documents/GitHub/spaceflight-adaptation/data/keystroke/switchtimes.csv');
uiwait(msgbox('Which swtich time sheet are you using?'))
st = uipickfiles;
switchtimesheet = importdata(st{1});
answer = inputdlg('What is your starting subject number?');

for subjcount = answer{1}:length(subjfolders)+answer{1}
    mkdir(['/Users/SYT/Documents/GitHub/spaceflight-adaptation/data/keystroke/newEpochAnalysis/subj' num2str(subjcount)])
    for filecount = 1:5
        filelist=ls(fullfile(subjfolders{1},'*.txt'));
        %filelist= strsplit(filelist);
        subjfile = fullfile(subjfolders{subjcount},filelist(filecount));
        
        % need to put these in order somehow
        % keysgen 
        [keypermin, cleanedintervals] = keystrokegen(subjfile,subjcount,switchtimesheet);

        %keysWPM
        [wpm,wpm_corrected,accuracy] = keystrokeWPM(subjfile,switchtimesheet);

        %keysMistake
        [totalmistakes, avgmistakes, percentmistake] = keysMistake(subjfile);
    end
    
end


