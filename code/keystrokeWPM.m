%% 6/10/19 Calculates WPM
% takes in one text file (split data)
% https://www.speedtypingonline.com/typing-equations 
% avg person types ~30-40 wpm (look up)

function [wpm,wpm_corrected,accuracy,totalwords] = keystrokeWPM(subjdatafile,subjnum,switchtimesheet)
    
    KEYS = importdata(subjdatafile);
    EXkeys = extractBetween(KEYS(2:end), 11, 22);
    EXkeys = datetime(EXkeys, 'inputformat', 'HH:mm:ss.SSS'); 
    TIMES_sec = EXkeys.Hour*3600+EXkeys.Minute*60+EXkeys.Second;

    switchtimes = rmmissing(switchtimesheet.data); %gets rid of NANs
    subjcol = switchtimes(:,find(contains(switchtimesheet.textdata,['Subj' num2str(subjnum)])));
    
    intervals = diff(TIMES_sec);
    ind = find(intervals > min(subjcol));
    cleanedintervals = intervals;
    cleanedintervals(ind) = [];

    totalmins = sum(cleanedintervals)/60;

    % no backspace, no shift, no enter
    % arrow keys???
    notkeys = find(contains(KEYS,'RShiftKey�') | contains(KEYS,'Return�') | contains(KEYS,'Back�'));
    newkeys = KEYS;
    newkeys(notkeys) = [];
    totalkeys = length(newkeys);
    
    % wpm
    wpm = (totalkeys/5)/totalmins;
    
    % wpm with corrections 
    backkey = find(contains(KEYS,'Back�'));
    wpm_corrected = ((totalkeys/5) - length(backkey))/totalmins;
    
    % accuracy
    accuracy = ((length(KEYS) - length(backkey))/length(KEYS))*100;
    
    totalwords = totalkeys/5;
    
    

    