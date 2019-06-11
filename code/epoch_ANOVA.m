clear; close all;
%% Import data from text file.
filename = '/Users/vedantchandra/JHM-Research/spaceflight-adaptation/data/trialdata.csv';
delimiter = ',';

% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';


fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);

fclose(fileID);

% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


rawNumericColumns = raw(:, [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]);
rawStringColumns = string(raw(:, 1));


R = cellfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {0.0}; % Replace non-numeric cells

idx = (rawStringColumns(:, 1) == "<undefined>");
rawStringColumns(idx, 1) = "";

trialdata = table;
trialdata.Phase = categorical(rawStringColumns(:, 1));
trialdata.Subj1 = cell2mat(rawNumericColumns(:, 1));
trialdata.Subj2 = cell2mat(rawNumericColumns(:, 2));
trialdata.Subj3 = cell2mat(rawNumericColumns(:, 3));
trialdata.Subj4 = cell2mat(rawNumericColumns(:, 4));
trialdata.Subj5 = cell2mat(rawNumericColumns(:, 5));
trialdata.Subj6 = cell2mat(rawNumericColumns(:, 6));
trialdata.Subj7 = cell2mat(rawNumericColumns(:, 7));
trialdata.Subj8 = cell2mat(rawNumericColumns(:, 8));
trialdata.Subj9 = cell2mat(rawNumericColumns(:, 9));
trialdata.Subj10 = cell2mat(rawNumericColumns(:, 10));
trialdata.Subj11 = cell2mat(rawNumericColumns(:, 11));
trialdata.Subj12 = cell2mat(rawNumericColumns(:, 12));
trialdata.Subj13 = cell2mat(rawNumericColumns(:, 13));
trialdata.Subj14 = cell2mat(rawNumericColumns(:, 14));
trialdata.Subj15 = cell2mat(rawNumericColumns(:, 15));
trialdata.Subj16 = cell2mat(rawNumericColumns(:, 16));
trialdata.Subj17 = cell2mat(rawNumericColumns(:, 17));
trialdata.Subj18 = cell2mat(rawNumericColumns(:, 18));
trialdata.Subj19 = cell2mat(rawNumericColumns(:, 19));
trialdata.Subj20 = cell2mat(rawNumericColumns(:, 20));
trialdata.Subj21 = cell2mat(rawNumericColumns(:, 21));
trialdata.Subj22 = cell2mat(rawNumericColumns(:, 22));
trialdata.Subj23 = cell2mat(rawNumericColumns(:, 23));
trialdata.Subj24 = cell2mat(rawNumericColumns(:, 24));
trialdata.Subj25 = cell2mat(rawNumericColumns(:, 25));
trialdata.Subj26 = cell2mat(rawNumericColumns(:, 26));
trialdata.Subj27 = cell2mat(rawNumericColumns(:, 27));
trialdata.Subj28 = cell2mat(rawNumericColumns(:, 28));
trialdata.Subj29 = cell2mat(rawNumericColumns(:, 29));
trialdata.Subj30 = cell2mat(rawNumericColumns(:, 30));

clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns R idx;


vas = [];
van = [];
puzzle = [];
memory=[];
meanHR=[];
meanTEMP=[];
meanEDA=[];
hredaz = [];
hrtempz = [];
tempedaz = [];

keyspeed = [];
keyerror = [];

rmsbody = [];
rmsright = [];
rmsleft = [];
rmshead = [];
p2pbody = [];
p2pright = [];
p2pleft = [];
p2phead = [];

for i = 1:30

    subjname = strcat('Subj',num2str(i));
    
    subjectvas = trialdata(3:7,subjname);
    vas = [vas,subjectvas];
    
    subjvan = trialdata(9:13,subjname);
    van = [van,subjvan];
    
    subjpuzzle = trialdata(15:19,subjname);
    puzzle = [puzzle,subjpuzzle];
    
    subjmemory = trialdata(21:25,subjname);
    memory = [memory,subjmemory];
    
    subjmeanHR = trialdata(51:55,subjname);
    meanHR=[meanHR,subjmeanHR];
    
    subjmeanTEMP = trialdata(57:61,subjname);
    meanTEMP = [meanTEMP,subjmeanTEMP];
    
    subjmeanEDA = trialdata(63:67,subjname);
    meanEDA = [meanEDA,subjmeanEDA];
    
    subjHREDAz = trialdata(106:110,subjname);
    hredaz = [hredaz,subjHREDAz];
    
    subjHRTEMPz = trialdata(112:116,subjname);
    hrtempz = [hrtempz,subjHRTEMPz];
    
    subjTEMPEDAz = trialdata(118:122,subjname);
    tempedaz = [tempedaz,subjTEMPEDAz];
    
    keyspeed = [keyspeed,trialdata(125:129,subjname)];
    keyerror = [keyerror,trialdata(131:135,subjname)];
    
    rmsbody = [rmsbody,trialdata(139:143,subjname)];
    rmsright = [rmsright,trialdata(146:150,subjname)];
    rmsleft = [rmsleft,trialdata(153:157,subjname)];
    rmshead = [rmshead,trialdata(160:164,subjname)];
    
    p2pbody = [p2pbody,trialdata(168:172,subjname)];
    p2pright = [p2pright,trialdata(175:179,subjname)];
    p2pleft = [p2pleft,trialdata(182:186,subjname)];
    p2phead = [p2phead,trialdata(189:193,subjname)];
    
end

%% One Way ANOVA

table = tempedaz; % Select which measure to perform ANOVA on

array = table2array(table).';
newtable = array2table(array);
newtable.Properties.RowNames = table.Properties.VariableNames;
table = newtable;
table.Properties.VariableNames = {'UP1','UP2','P1','P2','REC'};

data = table2array(table);
[p,tbl,stats] = anova1(data);

%% TWO WAY ANOVA
% we split the subjects into our colloquial sets. 

% table = removevars(table,11:30);
% 
% table = movevars(table,'Subj3','Before','Subj1');
% table = movevars(table,'Subj6','Before','Subj3');
% table = movevars(table,'Subj8','Before','Subj6');
% table = movevars(table,'Subj1','After','Subj10');
% table = movevars(table,'Subj2','After','Subj1');
% table = movevars(table,'Subj5','Before','Subj7');
% table = movevars(table,'Subj4','Before','Subj2');
% array = table2array(table).';
% newtable = array2table(array);
% newtable.Properties.RowNames = table.Properties.VariableNames;
% table = newtable;
% table.Properties.VariableNames = {'UP1','UP2','P1','P2','REC'};
% data = table2array(table);
% 
% [p,tbl,stats] = anova2(data,5);