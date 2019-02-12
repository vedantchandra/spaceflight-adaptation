function [HDR] = getfiletype(arg1)
% GETFILETYPE get file type 
%
% HDR = getfiletype(Filename);
% HDR = getfiletype(HDR.FileName);
%
% HDR is the Header struct and contains stuff used by SOPEN. 
% HDR.TYPE identifies the type of the file [1,2]. 
%
% see also: SOPEN 
%
% Reference(s): 
%   [1] http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/eeg/
%   [2] http://www.dpmi.tu-graz.ac.at/~schloegl/biosig/TESTED 


% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

%	$Id: getfiletype.m,v 1.53 2006/08/12 19:35:11 schloegl Exp $
%	(C) 2004,2005 by Alois Schloegl <a.schloegl@ieee.org>	
%    	This is part of the BIOSIG-toolbox http://biosig.sf.net/

if ischar(arg1),
        HDR.FileName = arg1;
elseif isfield(arg1,'name')
        HDR.FileName = arg1.name;
	HDR.FILE = arg1; 
elseif isfield(arg1,'FileName')
        HDR = arg1;
end;
if ~isfield(HDR,'FILE')
        HDR.FILE.PERMISSION='r';
end; 
if ~isfield(HDR.FILE,'PERMISSION')
        HDR.FILE.PERMISSION='r';
end; 

HDR.TYPE = 'unknown';
HDR.FILE.OPEN = 0;
HDR.FILE.FID  = -1;
HDR.ERROR.status  = 0; 
HDR.ERROR.message = ''; 
if ~isfield(HDR.FILE,'stderr'),
        HDR.FILE.stderr = 2;
end;
if ~isfield(HDR.FILE,'stdout'),
        HDR.FILE.stdout = 1;
end;	

if exist(HDR.FileName,'dir') 
        [pfad,file,FileExt] = fileparts(HDR.FileName);
        HDR.FILE.Name = file; 
        HDR.FILE.Path = pfad; 
	HDR.FILE.Ext  = FileExt(2:end); 
	if strcmpi(FileExt,'.ds'), % .. & isdir(HDR.FileName)
	        f1 = fullfile(HDR.FileName,[file,'.meg4']);
	        f2 = fullfile(HDR.FileName,[file,'.res4']);
	        if (exist(f1,'file') & exist(f2,'file')), % & (exist(f3)==2)
            		HDR.FileName  = f1; 
			% HDR.TYPE = 'MEG4'; % will be checked below 
	        end;
        elseif exist(fullfile(HDR.FileName,'alpha.alp'),'file')
                HDR.FileName = fullfile(HDR.FileName,'rawhead');
        else
    		HDR.TYPE = 'DIR'; 
    		return; 
	end;
end;

%fid = fopen(HDR.FileName,PERMISSION,'ieee-le');
fid = fopen(HDR.FileName,HDR.FILE.PERMISSION);
if fid < 0,
	HDR.ERROR.status = -1; 
        HDR.ERROR.message = sprintf('Error GETFILETYPE: file %s not found.\n',HDR.FileName);
        return;
else
        [pfad,file,FileExt] = fileparts(HDR.FileName);
        if ~isempty(pfad),
                HDR.FILE.Path = pfad;
        else
                HDR.FILE.Path = pwd;
        end;
        HDR.FILE.Name = file;
        HDR.FILE.Ext  = char(FileExt(2:length(FileExt)));

        if ~any(HDR.FILE.PERMISSION=='z')
                fseek(fid,0,'eof');
        else
                fseek(fid,2^32,'bof');
        end;
	HDR.FILE.size = ftell(fid);
        
	fseek(fid,0,'bof');
        
        [s,c] = fread(fid,256,'uchar');
        if (c == 0),
                s = repmat(0,1,256-c);
        elseif (c < 256),
                s = [s', repmat(0,1,256-c)];
        else
                s = s';
        end;

        if c,
                %%%% file type check based on magic numbers %%%
		tmp = 256.^[0:3]*reshape(s(1:20),4,5);
		mat4.flag = (c>20) & (tmp(5)<256) & (tmp(5)>1) & (tmp(1)<4053) & any(s(13)==[0,1]) & any(tmp(4)==[0,1]);
		if mat4.flag,
			mat4.matrixname = lower(s(21:20+tmp(5)-1));
	                mat4.type = sprintf('%04i',tmp(1))-48;
                        mat4.size = tmp(2:3);
                        mat4.imagf= tmp(4);
			mat4.flag = mat4.flag & s(20+tmp(5));
			mat4.flag = all((mat4.matrixname>='0' & mat4.matrixname<='9') | (mat4.matrixname>='_' & mat4.matrixname<='z'));
			mat4.flag = mat4.flag & all(any(mat4.type(ones(6,1),:)==[0,0:4;zeros(1,6);0:5;0:2,0,0,0]'));
		end;
		pos1_ascii10 = min(find(s==10));
		FLAG.FS3 = any(s==10); 
		if FLAG.FS3, 
			FLAG.FS3=all((s(4:pos1_ascii10)>=32) & (s(4:pos1_ascii10)<128)); 	% FREESURVER TRIANGLE_FILE_MAGIC_NUMBER
                end; 
		ss = char(s);
                if 0,
                elseif all(s([1:2,155:156])==[207,0,0,0]);
                        HDR.TYPE='BKR';
                elseif strncmp(ss,'Version 3.0',11); % Neuroscan 
                        HDR.TYPE='CNT';
                elseif strncmp(ss,'NSI TFF',7); % Neuroscan 
                        HDR.TYPE='AST';
                elseif strncmp(ss,'Brain Vision Data Exchange Header File',38); 
                        HDR.TYPE = 'BrainVision';
                elseif strncmp(ss,'Brain Vision Data Exchange Marker File',38); 
                        HDR.TYPE = 'BrainVision_MarkerFile';
                elseif strncmp(ss,'0       ',8); 
                        HDR.TYPE='EDF';
                elseif all(s(1:8)==[255,abs('BIOSEMI')]); 
                        HDR.TYPE='BDF';
                        
                elseif strncmp(ss,'GDF',3); 
                        HDR.TYPE='GDF';
                elseif strncmp(ss,'EBS',3); 
                        HDR.TYPE='EBS';
                %elseif all(s(1:4) == [hex2dec(['5f';'09';'a7';'82'])]'); 
                        %HDR.TYPE='ASN.1';
                elseif strncmp(ss,'CEN',3) & all(s(6:8)==hex2dec(['1A';'04';'84'])') & (all(s(4:5)==hex2dec(['13';'10'])') | all(s(4:5)==hex2dec(['0D';'0A'])')); 
                        HDR.TYPE='FEF';
                        HDR.VERSION   = str2double(ss(9:16))/100;
                        HDR.Encoding  = str2double(ss(17:24));
                        if any(str2double(ss(25:32))),
                                HDR.Endianity = 'ieee-be';
                        else
                                HDR.Endianity = 'ieee-le';
                        end;
                        if any(s(4:5)~=[13,10])
                        %        fprintf(2,'Warning GETFILETYPE (FEF): incorrect preamble in file %s\n',HDR.FileName);
                        end;
                        
                elseif strncmp(ss,'MEG41CP',7); 
                        HDR.TYPE='CTF';
                elseif strncmp(ss,'MEG41RS',7) | strncmp(ss,'MEG4RES',7); 
                        HDR.TYPE='CTF';
                elseif strncmp(ss,'MEG4',4); 
                        HDR.TYPE='CTF';
                elseif strncmp(ss,'CTF_MRI_FORMAT VER 2.2',22); 
                        HDR.TYPE='CTF';
                elseif 0, strncmp(ss,'PATH OF DATASET:',16); 
                        HDR.TYPE='CTF';
                        
                elseif strcmp(ss(1:10),'EEG-1100C ') & strcmp(ss(16+(1:length(HDR.FILE.Name))),HDR.FILE.Name);      % Nihon-Kohden
                        HDR.TYPE='EEG-1100';
                        HDR.VERSION = ss(11:16);
                elseif strcmp(ss(1:10),'EEG-1100C ') & strcmp(ss(32+(1:length(HDR.FILE.Name))),HDR.FILE.Name);      % Nihon-Kohden
                        HDR.TYPE='EEG-1100+';
                        HDR.VERSION = ss(11:16);
                elseif strcmp(ss(1:10),'EEG-1100C ')     % Nihon-Kohden
                        HDR.TYPE='EEG-1100-';
                        HDR.VERSION = ss(11:16);
                elseif strncmp(ss,'GALILEO EEG TRACE FILE',22)     % Galilea EEG (from ESAOTE, EBNeuro spa) 
                        HDR.TYPE='GTF';
                elseif strcmp(ss(3:11),'COHERENCE') & strcmp(ss(43+[1:length(HDR.FILE.Name)]),HDR.FILE.Name); 
                        HDR.TYPE='Delta';
                        
                elseif strcmp(ss(1:8),'@  MFER '); 
                        HDR.TYPE='MFER';
                elseif strcmp(ss(1:6),'@ MFR '); 
                        HDR.TYPE='MFER';
                elseif all(s([4:7,14:19])==[232,3,12,0,0,0,0,0,0,0]); 
                        HDR.TYPE='PathFinder710_HighResolutionECG';
                elseif all(s([9:22])==[0,0,136,0,0,0,13,13,abs('SCPECG')]); 
                        HDR.TYPE='SCP';
                        HDR.VERSION = 1.3; 
                elseif all(s([9:10,17:22])==[0,0,abs('SCPECG')]); 
                        HDR.TYPE='SCP';
                        HDR.VERSION = -1; 
                elseif all(s(17:22)==abs('SCPECG')); 
                        HDR.TYPE='SCP';
                        HDR.VERSION = -2; 
                elseif strncmp(ss,'# EN1064 Lead Identification Table of the SCP-ECG format',6); 
                        HDR.TYPE='EN1064:LeadId';
                        tmp = fread(fid,[1,inf],'char'); 
                        s = char([s(:);tmp(:)])';
                        fclose(fid);
                        k = 0; 
                        while ~isempty(s),
                                [t,s] = strtok(s,[10,13]);
                                if ~length(t)
                                elseif ~strncmp(t,'#',1)    
                                        ix3 = strfind(t,'MDC_ECG_LEAD_');
                                        [t1,t2] = strtok(t(1:ix3-1),[9,32]);
                                        [t2,t3] = strtok(t2,[9,32]);
                                        id = str2double(t2);
                                        k = k+1;
                                        HDR.EN1064.SCP_Name{k}    = t1;
                                        HDR.EN1064.Code(k)        = id;
                                        HDR.EN1064.Description{k} = deblank(t3);
                                        HDR.EN1064.MDC_ECG_LEAD{k}= t(ix3+13:end);
                                end;
                        end;
                        return;
                elseif strncmp(ss,'ATES MEDICA SOFT. EEG for Windows',32);	% ATES MEDICA SOFTWARE, NeuroTravel 
                        HDR.TYPE='ATES';
                        HDR.VERSION = ss(35:42);
                elseif all(s([1:24,29:31])==[abs('POLY SAMPLE FILEversion '),13,10,26]) & (str2double(ss(25:28))==(s([32:33])*[1;256]/100)); % Poly5/TMS32 sample file format.
                        HDR.TYPE='TMS32';
                elseif strncmp(ss,'"Snap-Master Data File"',23);	% Snap-Master Data File .
                        HDR.TYPE='SMA';
                elseif 0, all(s([1:2,20])==[1,0,0]) & any(s(19)==[2,4]); 
                        HDR.TYPE='TEAM';	% Nicolet TEAM file format
                elseif strncmp(ss,HDR.FILE.Name,length(HDR.FILE.Name)) & strcmpi(HDR.FILE.Ext,'HEA'); 
                        HDR.TYPE='MIT';
                elseif strncmp(ss,'DEMG',4);	% www.Delsys.com
                        HDR.TYPE='DEMG';
                elseif strcmp(ss(35:38),'BLSC') % CeeGraph, Bio-Logic Systems Corp. 
                        if strcmpi(ss(44+[0:length(HDR.FILE.Name)+length(HDR.FILE.Ext)]),[HDR.FILE.Name,'.',HDR.FILE.Ext]);
                        else
                                warning('BLSC: ????');
                        end;
                        HDR.TYPE='BLSC';
                        
                elseif any(s(1)==[100:103]) & all(s([2:8])==[0,0,0,176,1,0,0]) & strcmpi(HDR.FILE.Ext,'DDT'); 
                        HDR.TYPE='DDT';
                elseif all(s([1:4])==abs('NEX1')); 
                        HDR.TYPE='NEX';
                elseif all(s([1:4,6:132])==[abs('PLEX'),zeros(1,127)]); 	% http://WWW.PLEXONINC.COM
                        HDR.TYPE='PLEXON';                        
                        
                elseif strcmp(ss([1:4]),'fLaC'); 
                        HDR.TYPE='FLAC';
                elseif strcmp(ss([1:4]),'OggS'); 
                        HDR.TYPE='OGG';
                elseif strcmp(ss([1:4]),'.RMF'); 
                        HDR.TYPE='RMF';

                elseif strncmp(ss,'AON4',4); 
                        HDR.TYPE='AON4';
                elseif all(s(3:7)==abs('-lh5-')); 
                        HDR.TYPE='LHA';
                elseif strncmp(ss,'PSID',4); 
                        HDR.TYPE='SID';
			HDR.Title = ss(23:54);    
			HDR.Author = ss(55:86);    
			HDR.Copyright = ss(87:118);    

                elseif strncmp(ss,'.snd',4); 
                        HDR.TYPE='SND';
                        HDR.Endianity = 'ieee-be';
                elseif strncmp(ss,'dns.',4); 
                        HDR.TYPE='SND';
                        HDR.Endianity = 'ieee-le';
                elseif strcmp(ss([1:4,9:12]),'RIFFWAVE'); 
                        HDR.TYPE='WAV';
                        HDR.Endianity = 'ieee-le';
                elseif strcmp(ss([1:4,9:11]),'FORMAIF'); 
                        HDR.TYPE='AIF';
                        HDR.Endianity = 'ieee-be';
                elseif strcmp(ss([1:4,9:12]),'RIFFAVI '); 
                        HDR.TYPE='AVI';
                        HDR.Endianity = 'ieee-le';
                elseif all(s([1:4,9:21])==[abs('RIFFRMIDMThd'),0,0,0,6,0]); 
                        HDR.TYPE='RMID';
                        HDR.Endianity = 'ieee-be';
                elseif all(s(1:9)==[abs('MThd'),0,0,0,6,0]) & any(s(10)==[0:2]); 
                        HDR.TYPE='MIDI';
			HDR.Endianity = 'ieee-be';
                elseif ~isempty(findstr(ss(1:16),'8SVXVHDR')); 
                        HDR.TYPE='8SVX';
                elseif strcmp(ss([1:4,9:12]),'RIFFILBM'); 
                        HDR.TYPE='ILBM';
                elseif strcmp(ss([1:4]),'2BIT'); 
                        HDR.TYPE='AVR';
                elseif all(s([1:4])==[26,106,0,0]); 
                        HDR.TYPE='ESPS';
                        HDR.Endianity = 'ieee-le';
                elseif all(s([1:4])==[0,0,106,26]); 
                        HDR.TYPE='ESPS';
                        HDR.Endianity = 'ieee-le';
                elseif strcmp(ss([1:15]),'IMA_ADPCM_Sound'); 
                        HDR.TYPE='IMA ADPCM';
                elseif all(s([1:8])==[abs('NIST_1A'),0]); 
                        HDR.TYPE='NIST';
                elseif all(s([1:7])==[abs('SOUND'),0,13]); 
                        HDR.TYPE='SNDT';
                elseif strcmp(ss([1:18]),'SOUND SAMPLE DATA '); 
                        HDR.TYPE='SMP';
                elseif strcmp(ss([1:19]),'Creative Voice File'); 
                        HDR.TYPE='VOC';
                elseif strcmp(ss([5:8]),'moov'); 	% QuickTime movie 
                        HDR.TYPE='QTFF';
                elseif strncmp(ss,'FWS',3) | strncmp(ss,'CWS',3); 	% Macromedia 
                        HDR.TYPE='SWF';
			HDR.VERSION = s(4); 
			HDR.SWF.size = s(5:8)*256.^[0:3]';
                elseif all(s(1:16)==hex2dec(reshape('3026b2758e66cf11a6d900aa0062ce6c',2,16)')')
                        %'75B22630668e11cfa6d900aa0062ce6c'
                        HDR.TYPE='ASF';
                        
                elseif strncmp(ss,'MPv4',4); 
                        HDR.TYPE='MPv4';
                        HDR.Date = ss(65:87);
                elseif strncmp(ss,'RG64',4); 
                        HDR.TYPE='RG64';
                elseif strncmp(ss,'DTDF',4); 
                        HDR.TYPE='DDF';
                elseif strncmp(ss,'RSRC',4);
                        HDR.TYPE='LABVIEW';
                elseif strncmp(ss,'IAvSFo',6); 
                        HDR.TYPE='SIGIF';
                elseif any(s(4)==(2:7)) & all(s(1:3)==0); % [int32] 2...7
                        HDR.TYPE='EGI';
                        
                elseif all(s(1:4)==hex2dec(reshape('AFFEDADA',2,4)')');        % Walter Graphtek
                        HDR.TYPE='WG1';
                        HDR.Endianity = 'ieee-le';
                elseif all(s(1:4)==hex2dec(reshape('DADAFEAF',2,4)')'); 
                        HDR.TYPE='WG1';
                        HDR.Endianity = 'ieee-le';
                        
                elseif strncmp(ss,'HeaderLen=',10); 
                        HDR.TYPE    = 'BCI2000'; 
                        HDR.VERSION = 1;
                elseif strncmp(ss,'BCI2000',7); 
                        HDR.TYPE    = 'BCI2000'; 
                        HDR.VERSION = 1.1;
                        
                elseif strcmp(ss([1:4,9:12]),'RIFFCNT ')
                        HDR.TYPE='EEProbe-CNT';     % continuous EEG in EEProbe format, ANT Software (NL) and MPI Leipzig (DE)
                elseif all(s(1:4)==[38 0 16 0])
                        HDR.TYPE='EEProbe-AVR';     % averaged EEG in EEProbe format, ANT Software (NL) and MPI Leipzig (DE)
                        
                elseif strncmp(ss,'ISHNE1.0',8);        % ISHNE Holter standard output file.
                        HDR.TYPE='ISHNE';
                elseif strncmp(ss,'rhdE',4);	% Holter Excel 2 file, not supported yet. 
                        HDR.TYPE='rhdE';          
                        
                elseif strncmp(ss,'RRI',3);	% R-R interval format % Holter Excel 2 file, not supported yet. 
                        HDR.TYPE='RRI';          
                elseif strncmp(ss,'Repo',4);	% Repo Holter Excel 2 file, not supported yet. 
                        HDR.TYPE='REPO';          
                elseif strncmp(ss,'Beat',4);	% Beat file % Holter Excel 2 file, not supported yet. 
                        HDR.TYPE='Beat';          
                elseif strncmp(ss,'Evnt',4);	% Event file % Holter Excel 2 file, not supported yet. 
                        HDR.TYPE='EVNT';          
                        
                elseif strncmp(ss,'CFWB',4); 	% Chart For Windows Binary data, defined by ADInstruments. 
                        HDR.TYPE='CFWB';
                elseif strncmp(ss,'FILE FORMAT=RigSys',18); 	% RigSys file format 
                        HDR.TYPE='RigSys';
                        
                elseif any(s(3:6)*(2.^[0;8;16;24]) == (30:42))
                        HDR.VERSION = s(3:6)*(2.^[0;8;16;24]);
                        offset2 = s(7:10)*(2.^[0;8;16;24]);
                        
                        if     HDR.VERSION < 34, offset = 150;
                        elseif HDR.VERSION < 35, offset = 164; 
                        elseif HDR.VERSION < 36, offset = 326; 
                        elseif HDR.VERSION < 38, offset = 886; 
                        elseif HDR.VERSION < 39, offset = 1894; 
                        elseif HDR.VERSION < 41, offset = 1896; 
                        elseif HDR.VERSION ==41, offset = 1944; 
                        else   offset = -1;
                               fprintf(2,'Warning: Version %i of ACQ format not supported (yet).\n',HDR.VERSION);
                        end;
                        if (offset==offset2),  
                                HDR.TYPE = 'ACQ';
                        end;
                        
                elseif (s(1) == 253) & (HDR.FILE.size==(s(6:7)*[1;256]+7));
                        HDR.TYPE='AKO+';
                elseif all(s(1:4) == [253, 174, 45, 5]); 
                        HDR.TYPE='AKO';
                elseif all(s(1:8) == [1,16,137,0,0,225,165,4]);
                        HDR.TYPE='ALICE4';
                        
                elseif strfind(ss,'ALPHA-TRACE-MEDICAL');
                        HDR.TYPE='alpha';
                        
                elseif strfind(ss,'W1N10936.');
                        ss(1:20),
                        
                elseif all(s(1:4) == [27,153,153,153]);
                        HDR.TYPE='???';
                        %ss(1:20),
                elseif all(s(1:4) == [28,153,153,153]);
                        HDR.TYPE='???';
                        %ss(1:20),
                        
                elseif all(s(1:2)==[hex2dec('55'),hex2dec('AA')]);
                        HDR.TYPE='RDF'; % UCSD ERPSS aquisition system 
                elseif strncmp(ss,'Stamp',5)
                        HDR.TYPE='XLTEK-EVENT';
                        
                elseif all(s(1:2)==[hex2dec('55'),hex2dec('3A')]);      % little endian 
                        HDR.TYPE='SEG2';
                        HDR.Endianity = 'ieee-le';
                elseif all(s(1:2)==[hex2dec('3A'),hex2dec('55')]);      % big endian 
                        HDR.TYPE='SEG2';
                        HDR.Endianity = 'ieee-be';
                        
                elseif strncmp(ss,'MATLAB Data Acquisition File.',29);  % Matlab Data Acquisition File 
                        HDR.TYPE='DAQ';
                elseif strncmp(ss,'MATLAB 5.0 MAT-file',19); 
                        HDR.TYPE='MAT5';
                        if (s(127:128)==abs('MI')),
                                HDR.Endianity = 'ieee-le';
                        elseif (s(127:128)==abs('IM')),
                                HDR.Endianity = 'ieee-be';
                        end;
                elseif strncmp(ss,'Model {',7); 
                        HDR.TYPE='MDL';
                elseif all(s(85:92)==abs('SAS FILE')); 	% FREESURVER TRIANGLE_FILE_MAGIC_NUMBER
                        HDR.TYPE='SAS';
                
                elseif all(s(1:16)==[15   195   123    28   207    45   109    75   138   234    31   100   206  210   185    23])
                        HDR.TYPE='no spec (nicolet?)';
                        
                elseif any(s(1)==[49:51]) & all(s([2:4,6])==[0,50,0,0]) & any(s(5)==[49:50]),
                        HDR.TYPE = 'WFT';	% nicolet
                        
                elseif all(s(1:3)==[255,255,254]) & FLAG.FS3,
		%any(s==10) & all((s(4:pos1_ascii10)>=32) & (s(4:pos1_ascii10)<128)); 	% FREESURVER TRIANGLE_FILE_MAGIC_NUMBER
                        HDR.TYPE='FS3';
                elseif all(s(1:3)==[255,255,255]); 	% FREESURVER QUAD_FILE_MAGIC_NUMBER or CURVATURE
                        HDR.TYPE='FS4';
                elseif all(s(2:6)==[134,1,0,2,0]) & any(s(1)==[162:164]); 	% SCAN *.TRI file 
                        HDR.TYPE='TRI';
                        
                elseif all(s(1:16)==[162 134 1 0 0 0 1 0 205 204 76 63 0 0 192 63]); 
                        HDR.TYPE='3DD';

                elseif all((s(1:4)*(2.^[24;16;8;1]))==1229801286); 	% GE 5.X format image 
                        HDR.TYPE='5.X';
                        
                elseif all(s(1:2)==[105,102]); 
                        HDR.TYPE='669';
                elseif all(s(1:2)==[234,96]); 
                        HDR.TYPE='ARJ';
                elseif 0, s(1)==2; 
                        HDR.TYPE='DB2';
                elseif 0, any(s(1)==[3,131]); 
                        HDR.TYPE='DB3';
                elseif strncmp(ss,'DDMF',4); 
                        HDR.TYPE='DMF';
                elseif strncmp(ss,'DMS',4); 
                        HDR.TYPE='DMS';
                elseif strncmp(ss,'FAR',3); 
                        HDR.TYPE='FAR';
                elseif all(ss(5:6)==[175,18]); 
                        HDR.TYPE='FLC';
                elseif strncmp(ss,'GF1PATCH110',12); 
                        HDR.TYPE='GF1';
                elseif strcmp(ss([1:6,12]),'(DWF V)'); 
                        HDR.VERSION = str2double(ss(7:11));
                        if ~isnan(HDR.VERSION),
                                HDR.TYPE='IMAGE:DWF';           % Design Web Format  from Autodesk
                        end;
                elseif strncmp(ss,'GIF87a',6); 
                        HDR.TYPE='IMAGE:GIF';
                elseif strncmp(ss,'GIF89a',6); 
                        HDR.TYPE='IMAGE:GIF';
                elseif strncmp(ss,'CPT9FILE',8);        % Corel PhotoPaint Format
                        HDR.TYPE='CPT9';
                        
                elseif all(s(21:28)==abs('ACR-NEMA')); 
                        HDR.TYPE='ACR-NEMA';

                elseif all(s(129:132)==abs('DICM')); 
                        HDR.TYPE='DICOM';
                elseif all(s([2,4,6:8])==0) & all(s([1,3,5]));            % DICOM candidate
                        HDR.TYPE='DICOM';
                elseif all(s(1:18)==[8,0,5,0,10,0,0,0,abs('ISO_IR 100')])             % DICOM candidate
                        HDR.TYPE='DICOM';
                elseif all(s(12+[1:18])==[8,0,5,0,10,0,0,0,abs('ISO_IR 100')])             % DICOM candidate
                        HDR.TYPE='DICOM';
                elseif all(s([1:8,13:20])==[8,0,0,0,4,0,0,0,8,0,5,0,10,0,0,0])            % DICOM candidate
                        HDR.TYPE='DICOM';
		% more about the heuristics to identify DICOM files at
		%<http://groups.google.com/groups?hl=fr&lr=&frame=right&th=cb048de7b4459bd3&seekm=9h9jrs%247jf%40news.Informatik.Uni-Oldenburg.DE#link1>
                        
                elseif strncmp(ss,'*3DSMAX_ASCIIEXPORT',19)
                        HDR.TYPE='ASE';
                elseif strncmp(ss,'999',3)
                        HDR.TYPE='DXF-Ascii';
                elseif all(s([1:4])==[32,32,48,10])
                        HDR.TYPE='DXF?';
                elseif all(s([1:4])==[103,23,208,113])
                        HDR.TYPE='DXF13';
                elseif strncmp(ss,'AutoCAD Binary DXF',18)
                        HDR.TYPE='DXF-Binary';

                elseif all(s(1:24)==[0,0,39,10,zeros(1,20)])    
                        HDR.TYPE='SHAPE';
                        
                elseif strncmp(ss,'%!PS-Adobe',10)
                        HDR.TYPE='PS/EPS';
                elseif strncmp(ss,'HRCH: Softimage 4D Creative Environment',38)
                        HDR.TYPE='HRCH';
                elseif strncmp(ss,'#Inventor V2.0 ascii',11)
                        HDR.TYPE='IV2';
			HDR.VERSION = ss(12:14);
                elseif strncmp(ss,'HRCH: Softimage 4D Creative Environment',38)
                        HDR.TYPE='HRCH';
                elseif all(s([1:2])==[1,218])
                        HDR.TYPE='RGB';
                elseif strncmp(ss,'#$SMF',5)
                        HDR.TYPE='SMF';
			HDR.VERSION = str2double(ss(7:10));
                elseif strncmp(ss,'#SMF',4)
                        HDR.TYPE='SMF';
			HDR.VERSION = str2double(ss(5:8));
                        
                elseif all(s([1:4])==[127,abs('ELF')])
                        HDR.TYPE='ELF';
                elseif all(s([1:4])==[77,90,192,0])
                        HDR.TYPE='EXE';
                elseif all(s([1:4])==[77,90,80,0])
                        HDR.TYPE='EXE/DLL';
                elseif all(s([1:4])==[77,90,128,0])
                        HDR.TYPE='DLL';
                elseif all(s([1:4])==[77,90,144,0])
                        HDR.TYPE='DLL';
                elseif all(s(1:4)==hex2dec(['CA';'FE';'BA';'BE'])')
                        HDR.TYPE='JAVA';
                elseif all(s([1:8])==[254,237,250,206,0,0,0,18])
                        HDR.TYPE='MEXMAC';

                elseif all(s(1:24)==[208,207,17,224,161,177,26,225,zeros(1,16)]);	% MS-EXCEL candidate
                        HDR.TYPE='BIFF';
                        
                elseif strncmp(lower(ss),'<?php',5)
                        HDR.TYPE='PHP';
                elseif strncmp(ss,'<WORLD>',7)
                        HDR.TYPE='XML';
                elseif all(s(1:2)==[255,254]) & all(s(4:2:end)==0)
                        HDR.TYPE='XML-UTF16';
                elseif ~isempty(findstr(ss,'?xml version'))
                        HDR.TYPE='XML-UTF8';

                elseif strncmp(ss,'ABF',3)
                        HDR.TYPE = 'ABF';
                elseif strncmp(ss,'CLPX',3)
                        HDR.TYPE = 'ABF';
                elseif strncmp(ss,'FTCX',3)
                        HDR.TYPE = 'ABF';
                elseif all(s(1:4)==[0,0,128,63])        %float(1)
                        HDR.TYPE = 'ABF';
                elseif all(s(1:4)==[0,0,32,65])         %float(10)
                        HDR.TYPE = 'ABF';
                        
                elseif all(s(1:4)==abs(['ATF',9]))
                        HDR.TYPE='ATF'; % axon text file 
                        [tmp,t]=strtok(ss,[9,10,13,32]);
                        [tmp,t]=strtok(t,[9,10,13,32]);
                        HDR.Version = str2double(tmp);
                        
                elseif strncmp(ss,'binterr1.3',10)
                        HDR.TYPE='BT1.3';
                elseif all(s([1:2,7:10])==[abs('BM'),zeros(1,4)])
                        HDR.TYPE='IMAGE:BMP';
                        HDR.Endianity = 'ieee-le';
                elseif strncmp(ss,'#FIG',4)
                        HDR.TYPE='FIG';
			HDR.VERSION = strtok(ss(6:end),[10,13]);
                elseif strncmp(ss,'SIMPLE  =                    T / Standard FITS format',30)
                        HDR.TYPE='IMAGE:FITS';
                elseif all(s(1:40)==[137,abs('HDF'),13,10,26,10,0,0,0,0,0,8,8,0,4,0,16,0,3,zeros(1,11),repmat(255,1,8)]) & (HDR.FILE.size==s(41:44)*2.^[0:8:24]')
                        HDR.TYPE='HDF';
                elseif strncmp(ss,'CDF',3)
                        HDR.TYPE='NETCDF';
                elseif strncmp(ss,'%%MatrixMarket matrix coordinate',32)
                        HDR.TYPE='MatrixMarket';
                elseif s(1:4)*2.^[0:8:24]'==5965600,	 % Kodac ICC format
                        HDR.TYPE='ICC';
			HDR.HeadLen = s(5:8)*2.^[0:8:24];
			HDR.T0 = s([20,19,18,17,24,23]);
                elseif strncmp(ss,'IFS',3)
                        HDR.TYPE='IMAGE:IFS';
                elseif strncmp(ss,'OFF',3)
                        HDR.TYPE='OFF';
			HDR.ND = 3;
                elseif strncmp(ss,'4OFF',4)
                        HDR.TYPE='OFF';
			HDR.ND = 4;
                elseif strncmp(ss,'.PBF',4)      
                        HDR.TYPE='PBF';
                elseif all(s([1,3])==[10,1]) & any(s(2)==[0,2,3,5]) & any(s(4)==[1,4,8,24]) & any(s(59)==[4,3])
                        HDR.TYPE='PCX';
			tmp = [2.5, 0, 2.8, 2.8, 0, 3];
                        HDR.VERSION=tmp(s(2)+1);
			HDR.Encoding = s(3);
			HDR.BitsPerPixel = s(4);
			HDR.NPlanes = s(65);
			
                elseif all(s(1:8)==[139,74,78,71,13,10,26,10])
                        HDR.TYPE='IMAGE:JNG';
                elseif all(s(1:8)==[137,80,78,71,13,10,26,10]) 
                        HDR.TYPE='IMAGE:PNG';
		elseif (ss(1)=='P') & any(ss(2)=='123')	% PBMA, PGMA, PPMA
                        HDR.TYPE='IMAGE:PBMA';
			id = 'BGP';
			HDR.TYPE(8)=id(s(2)-48);
			
		elseif (ss(1)=='P') & any(ss(2)=='456')	% PBMB, PGMB, PPMB
                        HDR.TYPE='IMAGE:PBMB';
			id = 'BGP';
			HDR.TYPE(8) = id(s(2)-abs('3'));
			[t,ss] = strtok(ss,[10,13]);
			lt = length(t) + 1;
			[t,ss] = strtok(ss,[10,13]);
			lt = lt + length(t) + 1;
			while strncmp(t,'#',1)
				[t,ss] = strtok(ss,[10,13]);
				lt = lt + length(t) + 1; 
			end;	
			HDR.IMAGE.Size = str2double(t);
			[t,ss] = strtok(ss,[10,13]);
			lt = lt + length(t) + 1;
			HDR.DigMax  = str2double(t);
			HDR.HeadLen = lt;

                elseif strcmpi(HDR.FILE.Ext,'XBM') & ~isempty(strfind(ss,'bits[]')) & ~isempty(strfind(ss,'width')) & ~isempty(strfind(ss,'height'))
                        HDR.TYPE='IMAGE:XBM';
                elseif strncmp(ss,'/* XBM ',7)
                        HDR.TYPE='IMAGE:XBM';
                elseif strncmp(ss,'#define icon_width',7)
                        HDR.TYPE='IMAGE:XBM';

                elseif strncmp(ss,'/* XPM */',9)
                        HDR.TYPE='IMAGE:XPM';

                elseif strncmp(ss,['#  ',HDR.FILE.Name,'.poly'],8+length(HDR.FILE.Name)) 
                        HDR.TYPE='POLY';
                elseif all(s([1,3,7:12])==[255,255,abs('Exif'),0,0]) & any(s(2)==[216:217]) & any(s(4)==[224:225]); 
                        HDR.TYPE='IMAGE:EXIF';
                        HDR.Endianity = 'ieee-be';
                elseif all(s([1:4,7:12])==[255,216,255,225,abs('Exif'),0,0]); 
                        HDR.TYPE='IMAGE:EXIF';
                        HDR.Endianity = 'ieee-be';
                elseif all(s([1:3])==[255,216,255])
                        HDR.TYPE='IMAGE:JPG-';
                        HDR.Endianity = 'ieee-be';
                elseif all(s([1:4,7:11])==[255,217,255,224,abs('JFIF'),0])
                        HDR.TYPE='IMAGE:JPG1';
                        HDR.Endianity = 'ieee-be';
                elseif all(s([1:4,7:11])==[255,216,255,224,abs('JFIF'),0])
                        HDR.TYPE='IMAGE:JPG2';
                        HDR.Endianity = 'ieee-be';
                elseif all(s(1:4)==[216,255,224,255])
                        HDR.TYPE='IMAGE:JPG3';
                        HDR.Endianity = 'ieee-le';
                elseif all(s([1,3,65])==[10,1,0]) & any(s(2)==[0,2,3,4,5]) & any(s(4)==[1,2,4,8]) & any(s(66)==[1:4]) & any(s(69)==[1:2])
                        HDR.TYPE='IMAGE:PCX';
                        HDR.Endianity = 'ieee-le';
                elseif all(s(1:4)==[149, 106, 166, 89])
                        HDR.TYPE='IMAGE:SunRasterfile';
                        HDR.Endianity = 'ieee-be';
                elseif all(s(1:20)==['L',0,0,0,1,20,2,0,0,0,0,0,192,0,0,0,0,0,0,70])
                        HDR.TYPE='LNK';
                        tmp = fread(fid,inf,'char');
                        HDR.LNK=[s,tmp'];
                elseif all(s(1:3)==[0,0,1])	
                        HDR.TYPE='MPG2MOV';
                elseif strcmp(ss([3:5,7]),'-lh-'); 
                        HDR.TYPE='LZH';
                elseif strcmp(ss([3:5,7]),'-lz-'); 
                        HDR.TYPE='LZH';
                elseif strcmp(ss(1:3),'MMD'); 
                        HDR.TYPE='MED';
                elseif 0, % conflict with some WFDB-data
			%(s(1)==255) & any(s(2)>=224); 
                        HDR.TYPE='MPEG';
                elseif strncmp(ss(5:8),'mdat',4); 
                        HDR.TYPE='MOV';
                elseif all(s(1:2)==[26,63]); 
                        HDR.TYPE='OPT';
                elseif strncmp(ss,'%PDF',4); 
                        HDR.TYPE='PDF';
                elseif strncmp(ss,'QLIIFAX',7); 
                        HDR.TYPE='QFX';
                elseif strncmp(ss,'.RMF',4); 
                        HDR.TYPE='RMF';
                elseif strncmp(ss,'IREZ',4); 
                        HDR.TYPE='RMF';
                elseif strncmp(ss,'{\rtf',5); 
                        HDR.TYPE='RTF';
                elseif all(s(1:4)==[73,73,42,0]); 
                        HDR.TYPE='IMAGE:TIFF';
                        HDR.Endianity = 'ieee-le';
                        HDR.FLAG.BigTIFF = 0; 
                elseif all(s(1:4)==[77,77,0,42]); 
                        HDR.TYPE='IMAGE:TIFF';
                        HDR.Endianity = 'ieee-be';
                        HDR.FLAG.BigTIFF = 0; 
                elseif all(s(1:8)==[73,73,43,0,8,0,0,0]); 
                        HDR.TYPE='IMAGE:TIFF';
                        HDR.Endianity = 'ieee-le';
                        HDR.FLAG.BigTIFF = 1; 
                elseif all(s(1:8)==[77,77,0,43,0,8,0,0]); 
                        HDR.TYPE='IMAGE:TIFF';
                        HDR.Endianity = 'ieee-be';
                        HDR.FLAG.BigTIFF = 1; 
                elseif strncmp(ss,'StockChartX',11); 
                        HDR.TYPE='STX';
                elseif all(ss(1:2)==[25,149]); 
                        HDR.TYPE='TWE';
                elseif strncmp(ss,'TVF 1.1A',7); 
                        HDR.TYPE = ss(1:8);
                elseif all(s(1:12)==[abs('TVF 1.1B'),1,0,0,0]); 
                        HDR.TYPE = ss(1:8);
			HDR.Endianity = 'ieee-le';
                elseif all(s(1:12)==[abs('TVF 1.1B'),0,0,0,1]); 
                        HDR.TYPE = ss(1:8);
			HDR.Endianity = 'ieee-be';
                elseif strncmp(ss,'#VRML',5); 
                        HDR.TYPE='VRML';
                elseif strncmp(ss,'# vtk DataFile Version ',23); 
                        HDR.TYPE='VTK';
			HDR.VERSION = ss(24:26);
                elseif all(ss(1:5)==[0,0,2,0,4]); 
                        HDR.TYPE='WKS';
                elseif all(ss(1:5)==[0,0,2,0,abs('Q')]); 
                        HDR.TYPE='WQ1';
                elseif all(s(1:8)==hex2dec(['30';'26';'B2';'75';'8E';'66';'CF';'11'])'); 
                        HDR.TYPE='WMV';
                        
                	% compression formats        
                elseif strncmp(ss,'BZh91AH&SY',10); 
                        HDR.TYPE='BZ2';
                elseif all(s(1:3)==[66,90,104]); 
                        HDR.TYPE='BZ2';
                elseif strncmp(ss,'MSCF',4); 
                        HDR.TYPE='CAB';
                elseif all(s(1:3)==[31,139,8]); 
                        HDR.TYPE='gzip';
                        if exist('OCTAVE_VERSION','builtin')
                                fclose(fid); 
                                HDR.FILE.PERMISSION = [HDR.FILE.PERMISSION ,'z'];
                                HDR = getfiletype(HDR);
                                return; 
                        end;
                elseif all(s(1:3)==[31,157,144]); 
                        HDR.TYPE='Z';
                elseif all(s([1:4])==[80,75,3,4]) & (c>=30)
                        HDR.TYPE='ZIP';
                        HDR.VERSION = s(5:6)*[1;256];
                        HDR.ZIP.FLAG = s(7:8);
                        HDR.ZIP.CompressionMethod = s(9:10);
                        
                        % converting MS-Dos Date*Time format
                        tmp = s(11:14)*2.^[0:8:31]';
                        HDR.T0(6) = rem(tmp,2^5)*2;	tmp=floor(tmp/2^5);
                        HDR.T0(5) = rem(tmp,2^6);	tmp=floor(tmp/2^6);
                        HDR.T0(4) = rem(tmp,2^5);	tmp=floor(tmp/2^5);
                        HDR.T0(3) = rem(tmp,2^5);	tmp=floor(tmp/2^5);
                        HDR.T0(2) = rem(tmp,2^4); 	tmp=floor(tmp/2^4);
                        HDR.T0(1) = 1980+tmp; 
                        
                        HDR.ZIP.CRC = s(15:18)*2.^[0:8:31]';
                        HDR.ZIP.size2 = s(19:22)*2.^[0:8:31]';
                        HDR.ZIP.size1 = s(23:26)*2.^[0:8:31]';
                        HDR.ZIP.LengthFileName = s(27:28)*[1;256];
                        HDR.ZIP.filename = char(s(31:min(c,30+HDR.ZIP.LengthFileName)));
                        HDR.ZIP.LengthExtra = s(29:30)*[1;256];
                        HDR.HeadLen = 30 + HDR.ZIP.LengthFileName + HDR.ZIP.LengthExtra;
                        HDR.ZIP.tmp = char(s);
                        HDR.ZIP.Extra = s(31+HDR.ZIP.LengthFileName:min(c,HDR.HeadLen));
                        if 1, 
                        elseif strncmp(ss(31:end),'mimetypeapplication/vnd.sun.xml.writer',38)
                                HDR.TYPE='SWX';
                        elseif strncmp(ss(31:end),'mimetypeapplication/vnd.oasis.opendocument.spreadsheet',38)
                                HDR.TYPE='ODS';
                        end;
                elseif strncmp(ss,'ZYXEL',5); 
                        HDR.TYPE='ZYXEL';
                elseif strcmpi([HDR.FILE.Name,' '],ss(1:length(HDR.FILE.Name)+1)) & any(ss(length(HDR.FILE.Name)+2)==' 0123456789');
                        HDR.TYPE='MIT';
                elseif strcmpi(HDR.FILE.Name,ss(1:length(HDR.FILE.Name)))
                        HDR.TYPE='TAR?';
                elseif strncmp(ss,['# ',HDR.FILE.Name],length(HDR.FILE.Name)+2); 
                        HDR.TYPE='SMNI';
			
                elseif mat4.flag,
		%(c>20) & (s(1:4)*256.^[0:3]'<4053) & any(s(13)==[0,1]) & all(s(14:16)==0) & any(s(17:20)>0) & all(mat4.matrixname>='0' & mat4.matrixname<='z') & ~mat4.matrixname(20+mat4.matrixname_len) & all(any(mat4.type(ones(6,1),:)==[0,0:4;zeros(1,6);0:5;0:2,0,0,0]')),  
		%& (type_mat4(1)==(0:4)) & (type_mat4(2)==0) & (type_mat4(3)==(0:5)) & (type_mat4(4)==(0:2)) 
			% should be last, otherwise to many false detections
                        HDR.TYPE = 'MAT4';
                        HDR.MAT4 = mat4; 
			if mat4.type(1)=='0'
				HDR.MAT4.opentyp = 'ieee-le';
			elseif mat4.type(1)=='1'
				HDR.MAT4.opentyp = 'ieee-be';
			elseif mat4.type(1)=='2'
				HDR.MAT4.opentyp = 'vaxd';
			elseif mat4.type(1)=='3'
				HDR.MAT4.opentyp = 'vaxg';
			elseif mat4.type(1)=='4'
				HDR.MAT4.opentyp = 'cray';
                        end;
			
                elseif ~isempty(findstr(ss,'### Table of event codes.'))
                        fseek(fid,0,-1);
                        line = fgetl(fid);
                        N1 = 0; N2 = 0; 
                        while ~feof(fid),%length(line),
                                if 0, 
                                elseif strncmp(line,'0x',2),
                                        N1 = N1 + 1;
                                        [ix,desc] = strtok(line,char([9,32,13,10]));
                                        ix = hex2dec(ix(3:end));
                                        HDR.EVENT.CodeDesc{N1,1} = desc(2:end);
                                        HDR.EVENT.CodeIndex(N1,1) = ix;
                                elseif strncmp(line,'### 0x',6)
                                        N2 = N2 + 1;
                                        HDR.EVENT.GroupDesc{N2,1} = line(12:end);
                                        tmp = line(7:10);
                                        HDR.EVENT.GroupIndex{N2,1} = tmp;
                                        tmp1 = tmp; tmp1(tmp~='_') = 'F'; tmp1(tmp=='_')='0';
                                        HDR.EVENT.GroupMask(N2,1)  = bitand(hex2dec(tmp1),hex2dec('7FFF'));
                                        tmp1 = tmp; tmp1(tmp=='_') = '0';
                                        HDR.EVENT.GroupValue(N2,1) = hex2dec(tmp1);
                                end;	
                                line = fgetl(fid);
                        end;
                        HDR.TYPE = 'EVENTCODES';
			
                else
                        HDR.TYPE='unknown';

                        status = fseek(fid,3228,-1);
                        [s0,c]=fread(fid,[1,4],'uint8'); 
			if (status & (c==4)) 
			if all((s0(1:4)*(2.^[24;16;8;1]))==1229801286); 	% GE LX2 format image 
                                HDR.TYPE='LX2';
                        end;
			end;
                end;

                if strcmp(HDR.TYPE,'unknown')
                        frewind(fid);
                        s = fread(fid,[1,1e5],'uint8');
                        HDR.FLAG.ASCII = all((s>=32) | (s==9) | (s==10) | (s==13));
                        if HDR.FLAG.ASCII,
                                HDR.s = char(s);
                                s = HDR.s; 
                        end; 
                end;
        end;
        fclose(fid);

        if strcmpi(HDR.TYPE,'unknown'),
                % alpha-TRACE Medical software
                if exist(fullfile(HDR.FILE.Path,'alpha.alp'),'file')
                        %HDR.TYPE = 'alpha'; %alpha trace medical software 
                        HDR = getfiletype(fullfile(HDR.FILE.Path,'alpha.alp'));
                        if strcmp(HDR.TYPE,'alpha')
                                return;
                        end;
                end;
                
                %%% this is the file type check based on the file extionsion, only.  
                if 0, 
                        
                        % MIT-ECG / Physiobank format
                elseif strcmpi(HDR.FILE.Ext,'HEA'), HDR.TYPE='MIT';

			% Physiobank annotation files 
		elseif length(HDR.FILE.Ext) & strmatch(HDR.FILE.Ext,{'16a','abp','al','apn','ari','atr','atr-','ecg','pap','ple','qrs','qrsc','sta','stb','stc'},'exact'),  
			HDR.TYPE='MIT-ATR';
			
                elseif strcmpi(HDR.FILE.Ext,'DAT') 
                        tmp = dir(fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.hea']));
                        if isempty(tmp), 
                                tmp = dir(fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.HEA']));
                        end
                        if ~isempty(tmp), 
                                HDR.TYPE='MIT';
                                [tmp,tmp1,tmp2] = fileparts(tmp.name);
                                HDR.FILE.Ext = tmp2(2:end);
                        end
                        if isempty(tmp), 
                                tmp = dir(fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.set']));      % EEGLAB file
                        end
                        if isempty(tmp), 
                                tmp = dir(fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.vhdr']));
                        end
                        if isempty(tmp), 
                                tmp = dir(fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.VHDR']));
                        end
                        if ~isempty(tmp), 
                                HDR = getfiletype(tmp);
                        end
                        
                elseif strcmpi(HDR.FILE.Ext,'rhf'),
                        HDR.FileName=fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.',HDR.FILE.Ext]);
                        HDR.TYPE = 'RG64';
                elseif strcmp(HDR.FILE.Ext,'rdf'),
                        HDR.FileName=fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.',HDR.FILE.Ext(1),'h',HDR.FILE.Ext(3)]);
                        HDR.TYPE = 'RG64';
                elseif strcmp(HDR.FILE.Ext,'RDF'),
                        HDR.FileName=fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.',HDR.FILE.Ext(1),'H',HDR.FILE.Ext(3)]);
                        HDR.TYPE = 'RG64';
                        
                elseif strcmpi([HDR.FILE.Name,'.',HDR.FILE.Ext],'alldata.bin')
                	if exist(fullfile(HDR.FILE.Path,'alldata.bin'),'file')
                	if exist(fullfile(HDR.FILE.Path,'lefttrain.events'),'file')
                	if exist(fullfile(HDR.FILE.Path,'righttrain.events'),'file')
                	if exist(fullfile(HDR.FILE.Path,'test.events'),'file')
	                	HDR.TYPE = 'BCI2002b';
                	end;end;end;end; 
                        
                elseif strcmpi(HDR.FILE.Ext,'txt') & (any(strfind(HDR.FILE.Path,'a34lkt')) | any(strfind(HDR.FILE.Path,'egl2ln'))) & any(strmatch(HDR.FILE.Name,{'Traindata_0','Traindata_1','Testdata'}))
                        HDR.TYPE = 'BCI2003_Ia+b';
                        
                elseif any(strmatch(HDR.FILE.Name,{'x_train','x_test'}))
                        HDR.TYPE = 'BCI2003_III';
                        
                elseif strcmpi(HDR.FILE.Ext,'hdm')
                        
                elseif strcmpi(HDR.FILE.Ext,'hc')
                        
                elseif strcmpi(HDR.FILE.Ext,'shape')
                        
                elseif strcmpi(HDR.FILE.Ext,'shape_info')
                        
                elseif strcmpi(HDR.FILE.Ext,'trg') & HDR.FLAG.ASCII
                	HDR.TYPE = 'EEProbe-TRG';
                        
                elseif strcmpi(HDR.FILE.Ext,'rej')
                        
                elseif strcmpi(HDR.FILE.Ext,'vol')
                        
                elseif strcmpi(HDR.FILE.Ext,'bnd')
                        
                elseif strcmpi(HDR.FILE.Ext,'msm')
                        
                elseif strcmpi(HDR.FILE.Ext,'msr')
                        HDR.TYPE = 'ASA2';    % ASA version 2.x, see http://www.ant-software.nl
                        
                elseif strcmpi(HDR.FILE.Ext,'dip')
                        
                elseif strcmpi(HDR.FILE.Ext,'mri')
                        
                elseif strcmpi(HDR.FILE.Ext,'iso')
                        
                elseif strcmpi(HDR.FILE.Ext,'hdr')
                        
                elseif strcmpi(HDR.FILE.Ext,'img')
                        
                elseif strcmpi(HDR.FILE.Ext,'ddt')
%                        HDR.TYPE = 'DDT';
                elseif strcmpi(HDR.FILE.Ext,'sx')
                        HDR.TYPE = 'SXI';
                elseif strcmpi(HDR.FILE.Ext,'sxi')
                        HDR.TYPE = 'SXI';
                        
                elseif strcmpi(HDR.FILE.Ext,'ent')
			HDR.TYPE = 'XLTEK-EVENT';		
                elseif strcmpi(HDR.FILE.Ext,'erd')
			HDR.TYPE = 'XLTEK';		

                elseif strcmpi(HDR.FILE.Ext,'etc')
			HDR.TYPE = 'XLTEK-ETC';
			fid = fopen(HDR.FileName,'r');
			fseek(fid,355,'bof');
			HDR.TIMESTAMP = fread(fid,1,'int32');
			fclose(fid);

                        % the following are Brainvision format, see http://www.brainproducts.de
                elseif strcmpi(HDR.FILE.Ext,'seg') | strcmpi(HDR.FILE.Ext,'vmrk')
                        % If this is really a BrainVision file, there should also be a
                        % header with the same name and extension *.vhdr.
                        tmp = fullfile(HDR.FILE.Path, [HDR.FILE.Name '.vhdr']);
                        if exist(tmp, 'file')
                                tmp = fullfile(HDR.FILE.Path, [HDR.FILE.Name '.VHDR']);
                        end;
                        if exist(tmp, 'file')
                                HDR = getfiletype(tmp);
                        end
                        
                elseif strcmpi(HDR.FILE.Ext,'vabs')
                                                
                elseif strcmpi(HDR.FILE.Ext,'bni')        %%% Nicolet files
                        tmp = fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.eeg']);  % nicolet
                        if exist(tmp,'file'),      % Nicolet
                                HDR = getfiletype(tmp);
                        end
                        
                elseif strcmpi(HDR.FILE.Ext,'eeg')      
                        tmp = fullfile(HDR.FILE.Path,[HDR.FILE.Name,'.vhdr']);  % brainvision header file 
                        if exist(tmp,'file'),          % brain vision
                                HDR = getfiletype(tmp);
                        else
                                fn = fullfile(HDR.FILE.Path, [HDR.FILE.Name '.bni']);   % nicolet 
                                if exist(fn, 'file')
                                        fid = fopen(fn,'r','ieee-le');
                                        HDR.Header = char(fread(fid,[1,1e6],'uchar'));
                                        fclose(fid);
                                end;
                                fn = fullfile(HDR.FILE.Path, [HDR.FILE.Name '.eeg']);
                                if exist(fn,'file')
                                        HDR.FileName = fn;
                                        fid = fopen(HDR.FileName,'r','ieee-le');
                                        status = fseek(fid,-4,'eof');
                                        if status,
                                                fprintf(2,'Error GETFILETYPE: file %s\n',HDR.FileName);
                                                return;
                                        end
                                        datalen = fread(fid,1,'uint32');
                                        status  = fseek(fid,datalen,'bof');
                                        HDR.Header = char(fread(fid,[1,1e6],'uchar'));
                                        fclose(fid);
                                end;
                                pos_rate = strfind(HDR.Header,'Rate =');
                                pos_nch  = strfind(HDR.Header,'NchanFile =');
                                if ~isempty(pos_rate) & ~isempty(pos_nch),
                                        HDR.SampleRate = str2double(HDR.Header(pos_rate + (6:9)));
                                        HDR.NS = str2double(HDR.Header(pos_nch +(11:14)));
                                        HDR.SPR = datalen/(2*HDR.NS);
                                        HDR.AS.endpos = HDR.SPR;
                                        HDR.GDFTYP = 3; % int16;
                                        HDR.HeadLen = 0;
                                        HDR.TYPE = 'Nicolet';
                                end;
                        end;

                elseif strcmpi(HDR.FILE.Ext,'fif')
                        HDR.TYPE = 'FIF';	% Neuromag MEG data (company is now part of 4D Neuroimaging)
                        
                elseif strcmpi(HDR.FILE.Ext,'bdip')
                        
                elseif strcmpi(HDR.FILE.Ext,'ela')
                        
                elseif strcmpi(HDR.FILE.Ext,'trl')
                        
                elseif (length(HDR.FILE.Ext)>2) & all(s>31),
                        if all(HDR.FILE.Ext(1:2)=='0') & any(abs(HDR.FILE.Ext(3))==abs([48:57])),	% WSCORE scoring file
                                x = load('-ascii',HDR.FileName);
                                HDR.EVENT.POS = x(:,1);
                                HDR.EVENT.WSCORETYP = x(:,2);
                                HDR.TYPE = 'WCORE_EVENT';
                        end;

                elseif strcmpi(HDR.FILE.Ext,'hgt') & (rem(sqrt(HDR.FILE.size/2),1)==0)
                	HDR.TYPE = 'IMAGE:HGT'; 
                        
                end;
        end;
        
        if 0, strcmpi(HDR.TYPE,'unknown'),
                try
                        [status, HDR.XLS.sheetNames] = xlsfinfo(HDR.FileName)
                        if ~isempty(status)
                                HDR.TYPE = 'EXCEL';
                        end;
                catch
                end;
        end;
end;
