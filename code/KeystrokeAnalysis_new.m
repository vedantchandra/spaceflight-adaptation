%% 4/24/19; KeyStroke analysis

% 3/1/19: DONE
% 3/6/19: not done; added mistake percent

% 6/9/19: working on it again 
% ideas:
% - adding/revising key interval (continuous time b/w key strokes)
% - comparing avg time between key strokes in unperturbed to avg time b/w key strokes in perturbed (or b/w epochs) 
% >> need to parse out assignment times
% hold time for keys or flight time ( specifically time
% duration in between releasing a key and pressing the next key)
% ultimate: words per minute

clear; close all;

current = pwd;
uiwait(msgbox("Select your SPLIT data (one subject)"))

try
%load in the data
[file, path] = uigetfile('*.txt', 'multiselect', 'on');   
catch 
    disp('FIX: Make sure Current Folder matches where you get the data when prompted.')
    disp('You can do this by clicking Desktop above this and navigating in the Current Folder.')
end    
cd(path)
uiwait(msgbox("Select the destination directory for keystroke data (should be 'keystroke')"))
mainfolder = uigetdir;
answer = inputdlg('Enter subject folder name, e.g. subj1','Folder Name'); 

datafolder = strcat(mainfolder,'/',answer{1});
mkdir(datafolder);

for i = 1:length(file)
    KEYS = importdata(strcat(path,file{i}));
    EXkeys = extractBetween(KEYS(2:end), 11, 22);
    EXkeys = datetime(EXkeys, 'inputformat', 'HH:mm:ss.S'); 

    TIMES_sec = EXkeys.Hour*3600+EXkeys.Minute*60+EXkeys.Second; %seconds past midnight
    MINS = floor(TIMES_sec/60); %rounds down to the minute >> makes this into minutes past midnight
    start = min(MINS);
    finish = max(MINS);

    [numkeystrokespermin, binedge, binindex] = histcounts(MINS, start:finish);
    plot(numkeystrokespermin)
    
    average = mean(numkeystrokespermin); % 200 something makes sense
    
    
    
%% mistakes

    key = extractBetween(KEYS(2:end), 27, 32);
    totalmistakes = 0;
    er = ismember(key, 'Back ');
    
    % counts up total mistakes
    for j = 1:length(er)
        if er(j) == 1
            totalmistakes = totalmistakes+1;
        end
    end
    
    %new analysis (10/10); calculuates mistakes over total time
    averagemistakes = (totalmistakes/(finish-start));
    
    % find the indicies that correspond to the changing minutes
    indicies = zeros(1,length(binedge)-1);
    indexcount = 1;
    for ind = 1:length(MINS)-1
        if MINS(ind) ~= MINS(ind+1)
            indicies(indexcount) = ind;
            indexcount = indexcount+1;
        end
    end
    
    %% calculates avg mistake per min + mistake/key press freq
    datacount = 1;
    mistakepermin = zeros(1,length(binedge)-1);
    mistakepercent = zeros(1,length(binedge)-1); %wat is this
    for n = 1:length(indicies)
            while datacount <= indicies(n)
                if er(datacount) == 1
                    mistakepermin(n) = mistakepermin(n)+1;
                end
                datacount = datacount+1;
            end
            mistakepercent(n) = mistakepermin(n)./numkeystrokespermin(n);
    end
       
    %mistake percent overall
    
    
    % write into a file; this is one file per person    
    Tsingle = table(average,totalmistakes,averagemistakes);
    writetable(Tsingle,strcat(datafolder, '/',file{i}(1:end-4), '_avg+mistakes+avgcor.csv')); % NEED TO SPECIFY DIRECTORY: this will be determined after the shim data is done (there is one directory per person)
    
    Tmulti = table(numkeystrokespermin,mistakepercent,mistakepermin);
    writetable(Tmulti,strcat(datafolder,'/',file{i}(1:end-4),'numkeystroke+mistakefreq+mistakepermin.csv'));
    
    %dlmwrite(strcat(datafolder,'/',file{i}(1:end-4),'speed.csv'),numkeystrokespermin);

%% plots
    % would it be easier to put all plots together?
    % no, we want to compare b/w subjects 
    
    % plot number of keystrokes per min
    plot(histcounts(MINS, start:finish), 'color', 'red', 'linewidth', 1)
    title('Keystrokes per Minute')
    saveas(gcf, strcat(datafolder,'/',file{i}(1:end-4), '_speed.fig')); %already specifies the round type
    
    %plot time between keystroke
    key_diffs = diff(TIMES_sec);
    plot(TIMES_sec(2:end), key_diffs)
    title('Time intervals between keystrokes')
    saveas(gcf, strcat(datafolder,'/',file{i}(1:end-4), '_interval.fig')); %already specifies the round type

    %plot mistakes
    plot(TIMES_sec,er)
    title('Number of mistakes per time')
    saveas(gcf, strcat(datafolder,'/',file{i}(1:end-4), '_mistake.fig')); %already specifies the round type

    %plot avg mistakes per min
    plot(1:length(indicies),mistakepermin);
    title('Average mistakes per minute')
    saveas(gcf, strcat(datafolder,'/',file{i}(1:end-4), '_mistakerate.fig')); %already specifies the round type
    
    %plot mistakes over typing frequency
    plot(1:length(indicines),mistakepercent);
    title('Mistake Percentage per minute');
    saveas(gcf, strcat(datafolder,'/',file{i}(1:end-4), '_mistakepercent.fig')); 

end

cd(current)