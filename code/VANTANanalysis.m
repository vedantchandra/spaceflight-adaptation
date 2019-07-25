%% VanTan analysis, 2/28/19
% done per subject (so one run per subject)
% Fix: do for entire subject folder, and change to abs values. Also made compatible with mission control computer

%7/16/19: normalize to baseline data
%7/17/19: run on apollo and gemini 
clear; close all;

% try
% %load in the data
% [file, path] = uigetfile('*.txt','multiselect','on');   
% catch 
%     disp('FIX: Make sure Current Folder matches where you get the data when prompted.')
%     disp('You can do this by clicking Desktop above this and navigating in the Current Folder.')
% end    

% Instructions: multi-select subject files
subjects = uipickfiles('filterspec','C:/Users/Spaceexplorers/Documents/GitHub/spaceflight-adaptation/data');

uiwait(msgbox('Select destination folder (should be vantan_[trial])'));
van = uigetdir;
%answer = inputdlg('Enter folder name, e.g. subj1','Folder Name'); 

%writepath = [van '/' answer];          % subtle thing here, answer is a variable of
%type "cell" (you can look at your workspace to see what that is);
%basically it's a different kind of object than a simple string. More
%importantly it CONTAINS the string that you're looking for (the actual
%thing that the person types). See the fix below:

%writepath = [van '/' answer{1}]; 


%mkdir ../data/van_gemini subj11 
% you can make a directory this way, but an easier/more robust way is just to use the variables you have already; writepath IS the path you need to write in, so just make writepath 

%mkdir(writepath)

for subj = 1:length(subjects)
    currentsubjdata = ls([subjects{subj} '/VANTAN/*.txt']);
    averagevan = [];
    averagetan = [];
    namevan = {};
    nametan = {};
    for d = 1:min(size(currentsubjdata))
        data = importdata([subjects{subj} '/VANTAN/' currentsubjdata(d,1:end)]);
        headers = string(data.textdata(4,:));
        %take data from anything past the first three data points
        %thestuffwecareabout = data.data(3:end,3);
        if contains(currentsubjdata(d,1:end),'VAN')
            % for the future, if we have a baseline reference file
            % if contains(currentsubjdata(d,1:end),'baseline')
                % averagevan = [mean(abs(data.data(3:end,3)))];
            % end
            
            averagevan = [averagevan; mean(abs(data.data(3:end,3)))];
            namevan = [namevan; currentsubjdata(d,1:end)];

        else if contains(currentsubjdata(d,1:end),'TAN')
            % if contains(currentsubjdata(d,1:end),'baseline')
            % averagevan = [mean(abs(data.data(3:end,3)))];
            % end
            averagetan = [averagetan; mean(abs(data.data(3:end,4)))];
            nametan = [nametan; currentsubjdata(d,1:end)];
            end
        end
    end
    
    %"normalize" by subtracting an average baseline; eventually use code
    %above
    baseline = mean(averagevan(1:2));
    averagevan = averagevan-baseline;
    % normalize the data by subtracting baseline levels
    Tvan = table(namevan,averagevan);
    %Ttan = table(nametan,averagetan);
    mkdir(strcat(van, '/', currentsubjdata(d,1:6)))
    %writetable(Ttan,strcat(writepath,'/Average Torsional Alignments.csv'));
    writetable(Tvan,strcat(van, '/', currentsubjdata(d,1:6),'/Average Vertical Alignments.csv'));

end

