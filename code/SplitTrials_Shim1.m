%% Trial Split: 5 outputs
% DONE 

clear all; close;
% 3/5/19: writes to a split folder within the raw/subj# folder

%% NOTES

% 3/6/19

% i haTE SHImmer dATA

% When copying the files over, make sure you download them all at once from BOX so
% that the file you're downloading says something like subj#-selected.zip

% Copy the whole thing over into the raw/subj# folder

% If you get an error running the script, it's probably because the zip
% file has already been opened (or something)

% There are 2 folders that will be made when you unzip the files; first, the
% subj#-selected.zip will zip out to a folder called ShimmerData; this
% contains the SUBFOLDERS that contain the CSV files. (because shimmer hates
% us.)

% The code will move those CSV files out of those subfolders and into the
% main ShimmerData folder. Have yet to write a line to remove the now empty
% folder. Not sure if copying instead of moving might be safer.

% When the data is read, the headers are automatically taken into account
% (seems like a nice thing but a lil sus about it). So, WE have to keep
% track of what each column of data means. The split files will have all
% the different columns, but no header. 

% I hope this works. ugh. uGH

% raw data stays in raw file, everything else will be in shimmer file

%be careful: the size of the data that comes out matches what is coming from box, not
%from zipped file in the raw folder (size is not comparable for some reason)

% I THINK IT WORKS 3/24/19
%% actual code

current = pwd;
uiwait(msgbox('Select your raw folder'))
trialsPath = uigetdir; % SELECT THE FOLDER 'raw' OVER HERE
cd(trialsPath);
string = ls;
list = strsplit(string);
subjects = list(~cellfun('isempty',list));

%shimmer has one col of data, so no dot indexing

% must copy file as group, make sure file is zipped
%files are within folder, which is within the previously zipped folder (2
%folder layers within subj# before file)

for subjectCount = 1:length(subjects)
     cd(trialsPath) % helps keeps things organized as you loop through subsequent subject folders
     subjectPath = [trialsPath '/' subjects{subjectCount} '/'];
     cd(subjectPath) % now working in subject folder
           
% zip out into one shimmer folder           
     zipPath = [subjects{subjectCount} '-selected.zip']; %assuming name is something like subj4-selected.zip   
     outPath = [trialsPath '/' subjects{subjectCount} '/' 'ShimmerData/'];

     unzip(zipPath,outPath);
     mkdir(outPath);
     
     % now grab all the files within the folders and put them into the ShimmerData folder    
     file = dir('**/*SD.csv');
     lenfile = length(file);
     cd(outPath)
     
     if ~contains(ls(pwd),'.csv')
        for i = 1:lenfile         
            movefile(fullfile(file(i).folder,file(i).name))
        end
     end
     cd(subjectPath) % go back to working in subject folder

    subjectSplit = [trialsPath(1:end-3) 'shimmer/' subjects{subjectCount} '/' 'ShimmerSplit'];
    mkdir(subjectSplit)
    
     
%% shimmer split
   for i = 1:length(file)
            
        if contains(strcat(outPath,file(i).name),'Body','IgnoreCase',true)
             %if contains(file,'body')
             data = importdata(strcat(outPath,file(i).name));
             lendata = length(data.data);

             split_ind = uint64(round(lendata/14))*3;

             %split into perturbed and unperturbed
              unpert1 = data.data(1:split_ind,:);
%               plot(unpert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP1','.fig'));
              unpert2= data.data(split_ind:split_ind*2,:);
%               plot(unpert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP2','.fig'));
              pert1 = data.data(split_ind*2:split_ind*3,:);
%               plot(pert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_P1','.fig'));
              pert2 = data.data(split_ind*3:split_ind*4,:);
%               plot(pert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_P2','.fig'));
              recover = data.data(split_ind*4:end,:);
%               plot(recover)
%               saveas(gcf,strcat(subjectSplit, '/','body_Rec','.fig'));

              dlmwrite(strcat(subjectSplit, '/','body_UP1','.csv'), unpert1,','); 
              dlmwrite(strcat(subjectSplit, '/','body_UP2','.csv'), unpert2,',');
              dlmwrite(strcat(subjectSplit,'/','body_P1','.csv'), pert1,',');
              dlmwrite(strcat(subjectSplit,'/','body_P2','.csv'), pert2,',');
              dlmwrite(strcat(subjectSplit,'/','body_Rec','.csv'), recover,',');
        
            elseif contains(strcat(outPath,file(i).name),'Right','IgnoreCase',true) 
             
             data = importdata(strcat(outPath,file(i).name));
                %data = importdata(strcat(outPath,file));

               lendata = length(data.data);
               split_ind = uint64(round(lendata/14))*3;

              %split into perturbed and unperturbed
              unpert1 = data.data(1:split_ind,:);
%               plot(unpert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP1','.fig'));
              unpert2= data.data(split_ind:split_ind*2,:);
%               plot(unpert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP2','.fig'));
              pert1 = data.data(split_ind*2:split_ind*3,:);
%               plot(pert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_P1','.fig'));
              pert2 = data.data(split_ind*3:split_ind*4,:);
%               plot(pert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_P2','.fig'));
              recover = data.data(split_ind*4:end,:);
%               plot(recover)
%               saveas(gcf,strcat(subjectSplit, '/','body_Rec','.fig'));

                dlmwrite(strcat(subjectSplit, '/','right_arm_UP1','.csv'), unpert1,','); % manually change where you write to
                dlmwrite(strcat(subjectSplit, '/','right_arm_UP2','.csv'), unpert2,',');
                dlmwrite(strcat(subjectSplit,'/','right_arm_P1','.csv'), pert1,',');
                dlmwrite(strcat(subjectSplit,'/','right_arm_P2','.csv'), pert2,',');
                dlmwrite(strcat(subjectSplit,'/','right_arm_Rec','.csv'), recover,',');
                
          elseif contains(strcat(outPath,file(i).name),'Left','IgnoreCase',true) 
             
             data = importdata(strcat(outPath,file(i).name));
                %data = importdata(strcat(outPath,file));

               lendata = length(data.data);
               split_ind = uint64(round(lendata/14))*3;

                            %split into perturbed and unperturbed
              unpert1 = data.data(1:split_ind,:);
%               plot(unpert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP1','.fig'));
              unpert2= data.data(split_ind:split_ind*2,:);
%               plot(unpert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP2','.fig'));
              pert1 = data.data(split_ind*2:split_ind*3,:);
%               plot(pert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_P1','.fig'));
              pert2 = data.data(split_ind*3:split_ind*4,:);
%               plot(pert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_P2','.fig'));
              recover = data.data(split_ind*4:end,:);
%               plot(recover)
%               saveas(gcf,strcat(subjectSplit, '/','body_Rec','.fig'));

                dlmwrite(strcat(subjectSplit, '/','left_arm_UP1','.csv'), unpert1,','); % manually change where you write to
                dlmwrite(strcat(subjectSplit, '/','left_arm_UP2','.csv'), unpert2,',');
                dlmwrite(strcat(subjectSplit,'/','left_arm_P1','.csv'), pert1,',');
                dlmwrite(strcat(subjectSplit,'/','left_arm_P2','.csv'), pert2,',');
                dlmwrite(strcat(subjectSplit,'/','left_arm_Rec','.csv'), recover,',');
                                
            elseif contains(strcat(outPath,file(i).name),'Head','IgnoreCase',true) 
               data = importdata(strcat(outPath,file(i).name));
                %data = importdata(strcat(outPath,file));

               lendata = length(data.data);
               split_ind = uint64(round(lendata/14))*3;

                 %split into perturbed and unperturbed
              unpert1 = data.data(1:split_ind,:);
%               plot(unpert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP1','.fig'));
              unpert2= data.data(split_ind:split_ind*2,:);
%               plot(unpert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_UP2','.fig'));
              pert1 = data.data(split_ind*2:split_ind*3,:);
%               plot(pert1)
%               saveas(gcf,strcat(subjectSplit, '/','body_P1','.fig'));
              pert2 = data.data(split_ind*3:split_ind*4,:);
%               plot(pert2)
%               saveas(gcf,strcat(subjectSplit, '/','body_P2','.fig'));
              recover = data.data(split_ind*4:end,:);
%               plot(recover)
%               saveas(gcf,strcat(subjectSplit, '/','body_Rec','.fig'));

                dlmwrite(strcat(subjectSplit, '/','head_UP1','.csv'), unpert1,','); % manually change where you write to
                dlmwrite(strcat(subjectSplit, '/','head_UP2','.csv'), unpert2,',');
                dlmwrite(strcat(subjectSplit,'/','head_P1','.csv'), pert1,',');
                dlmwrite(strcat(subjectSplit,'/','head_P2','.csv'), pert2,',');
                dlmwrite(strcat(subjectSplit,'/','head_REC','.csv'), recover,',');
         end
   end
end

cd(current);

