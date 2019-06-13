% 6/12/19: Split for skylab (most code copied from splittrials_empa

clear all; close;

current = pwd;
rawfold = uipickfile('filterspec','/Users/SYT/Documents/GitHub/spaceflight-adaptation/data');

% zip out into the same subject folder, and put the split stuff into a
% separate folder, which is still inside subject folder


 for filecount = 1:length(subjects)
      subjectPath = [trialsPath '/' subjects{filecount} '/'];

     outPath = [trialsPath, '/', subjects{filecount} '/' subjects{filecount} 'EmpaticaData/'];
     zipPath = [trialsPath '/' subjects{filecount} '/' subjects{filecount} 'Empatica.zip'];
    
    %change names of zipfile to something better ONLY IF IT HASN'T BEEN DONE ALREADY
    zipfile = ls([subjectPath '*.zip']);
     if contains(zipfile, zipPath) == 0
        copyfile(zipfile, [subjectPath subjects{filecount} 'Empatica.zip'])
     end
    
     unzip(zipPath,outPath);
    
    string = ls(outPath);
    list = strsplit(string);
    prefile = list;
    file={};
    for i = 1:length(prefile)
        if isequal(prefile{i},'ACC.csv')
           file{1}=prefile{i};
         elseif isequal(prefile{i},'BVP.csv')
            file{2}=prefile{i};
         elseif isequal(prefile{i},'EDA.csv')
            file{3}=prefile{i};
         elseif isequal(prefile{i},'HR.csv')
             file{4}=prefile{i};
          elseif isequal(prefile{i},'TEMP.csv')
            file{5}=prefile{i};
        end
     end
    
    %     path = outPath
    %     cd(path)
    subjectSplit = [subjectPath '/' 'EmpaticaSplit'];
    mkdir(subjectSplit)
    %file =
    
    %% Empatica split
     if contains(outPath,'Empatica')
         for i = 1:length(file)
            header = 2; % this means start at line 2
            delim = ',';
            data = importdata(strcat(outPath,file{i}),delim,header);
             lendata = length(data.data);
            
            split_ind = uint64(round(lendata/153));
            
             %split 
             unpert1 = data.data(1:(split_ind)*32,:);
             plot(unpert1)
             saveas(gcf,strcat(subjectSplit, '/',file{i},'_','E4_UP1','.fig'));
             unpert2= data.data((split_ind)*32:(split_ind)*32*2,:);
             plot(unpert2)
             saveas(gcf,strcat(subjectSplit, '/',file{i},'_','E4_UP2','.fig'));
             pert1 = data.data((split_ind)*32*2:(split_ind)*32*3,:);
             plot(pert1)
             saveas(gcf,strcat(subjectSplit, '/',file{i},'_','E4_P1','.fig'));
             pert2 = data.data((split_ind)*32*3:(split_ind)*32*4,:);
             plot(pert2)
             saveas(gcf,strcat(subjectSplit, '/',file{i},'_','E4_P2','.fig'));
             recover = data.data((split_ind)*32*4:end,:);
             plot(recover)
             saveas(gcf,strcat(subjectSplit, '/',file{i},'_','E4_Rec','.fig'));
             
            dlmwrite(strcat(subjectSplit, '/',file{i},'_','E4_UP1','.csv'), unpert1,',');
            dlmwrite(strcat(subjectSplit, '/',file{i},'_','E4_UP2','.csv'), unpert2,',');
            dlmwrite(strcat(subjectSplit,'/',file{i},'_','E4_P1','.csv'), pert1,',');
            dlmwrite(strcat(subjectSplit,'/',file{i},'_','E4_P2','.csv'), pert2,',');
            dlmwrite(strcat(subjectSplit,'/',file{i},'_','E4_Rec','.csv'), recover,',');
            
             end
        end
end

cd(current);

