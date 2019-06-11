%% 6/10/19: Keystroke gen analysis, multifunction

function [keypermin, cleanedintervals, keyhold] = keystrokegenAnalysis(subjdatafold, subjnum, switchtimesheet)
    % function takes in a subject folder with split data (so one subject folder)
    
    % subj23folder = '/Users/SYT/Documents/GitHub/spaceflight-adaptation/data/keystroke/Splitdata/subj23';
    % subj23folder =     'C:\Users\Spaceexplorers\Documents\GitHub\spaceflight-adaptation\data\keystroke\Splitdata\subj23';
    
    st = importdata(switchtimesheet);
    switchtimes = rmmissing(st.data);

    %cd(subj23folder)
    list=ls(fullfile(subjdatafold,'*.txt'));
    list= strsplit(list);
    %list = ls('*.txt');

    % temporary fix
    subjcol = switchtimes(:,find(contains(st.textdata,['Subj' subjnum])));

    for i = 1:1

        KEYS = importdata(list{i});
        %KEYS = importdata(list(i,:));
        EXkeys = extractBetween(KEYS(2:end), 11, 22);
        EXkeys = datetime(EXkeys, 'inputformat', 'HH:mm:ss.SSS'); 

        TIMES_sec = EXkeys.Hour*3600+EXkeys.Minute*60+EXkeys.Second; %seconds past midnight: ex 14:06:79 >> just seconds
        MINS = floor(TIMES_sec/60); %rounds down to the minute >> makes this into minutes past midnight
        start = min(MINS);
        finish = max(MINS);

        %% key speed

        [keypermin, binedge, binindex] = histcounts(MINS, start:finish);
    %     figure
    %     plot(keypermin)
    %     title('Number of keystroke per min')
    
        %% intervals

        intervals = diff(TIMES_sec);
%         figure
%         plot(TIMES_sec(2:end), intervals)
%         title('Time intervals between keystrokes')

        %% parsing out activity

        ind = find(intervals > min(subjcol));
        cleanedintervals = intervals;
        cleanedintervals(ind) = [];

%         figure
%         plot(cleanedintervals)
%         title('Key Intervals Cleaned');


        %% hold times? DO LATER

        % do per second
        keys = extractBetween(KEYS(2:end), 27, end);
        for holdcount = 1:length(keys)
        end

            % - subtract time between DOWN/UP for the SAME character
            % - if two characters in a row down, find the earliest time it comes
            % back UP (
            % - if more than two characters are the same and are both hold (i.e.
            % hold DOWN for a long time), then find when the next time it is that that
            % character comes UP


    end

    cd(current)