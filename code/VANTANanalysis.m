% VanTan analysis
% done per subject (so one run per subject)


clear; close all;

try
%load in the data
[file, path] = uigetfile('*.txt','multiselect','on');   
catch 
    disp('FIX: Make sure Current Folder matches where you get the data when prompted.')
    disp('You can do this by clicking Desktop above this and navigating in the Current Folder.')
end    

averagevan = [];
averagetan = [];
namevan = [];
nametan = [];
for i = 1:length(file)
    data = importdata(strcat(path,file{i}));
    headers = string(data.textdata(4,:));
    %take data from anything past the two data points
    %thestuffwecareabout = data.data(3:end,3);
    if contains(file{i},'VAN')
        averagevan = [averagevan; mean(data.data(3:end,3))];
        namevan = [namevan ;file{i}];
        
    else if contains(file{i},'TAN')
        averagetan = [averagetan; mean(data.data(3:end,4))];
        nametan = [nametan; file{i}];
        end
    end
end

Tvan = table(namevan,averagevan);
Ttan = table(nametan,averagetan);

mkdir('EM_vantananalysis'); % manually put name

writetable(Ttan,'EM_vantananalysis/Average Torsional Alignments.csv');
writetable(Tvan,'EM_vantananalysis/Average Vertical Alignments.csv')
% also do one for torsional




