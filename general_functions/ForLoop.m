addpath('X:\eblab\Matlab\get_ALLdata')
clear all
close figure(2)

% SET MONKEY HERE
monkey = 'Dorothy';

if strcmp(monkey,'Dorothy')
        mondir = ['X:\Cortex Data\Dorothy\'];
elseif strcmp(monkey,'Timmy')
    mondir = ['X:\Cortex Data\Timmy\'];
elseif strcmp(monkey,'Tobii')
    mondir = ['X:\Cortex Data\Tobii\'];
elseif strcmp(monkey,'Vivian')
    mondir = ['X:\Cortex Data\Vivian\'];
elseif strcmp(monkey,'Wilbur')
    mondir = ['X:\Cortex Data\Wilbur\'];
elseif strcmp(monkey,'Red')
    mondir = ['X:\Cortex Data\Red\'];
elseif strcmp(monkey,'Manfred')
    mondir = ['X:\Cortex Data\Manfred\'];
end


% Isolate the last 5 days of saved files
files = dir(mondir);
files = {files.name};
dates = zeros(1,length(files)-3);
for i = 4:length(files)
    name = files{i};
    dates(i-3) = str2num(name(3:8));
end
sorteddates = sort(unique(dates));
lastdays = sorteddates(end-4:end);
filelist = cell(1,length(lastdays));
for day = 1:length(lastdays)
    filelist{day} = strcat('DO',num2str(lastdays(day)),'.2');
end


% OVERRIDE FILE LIST HERE!!!!!!!!
% filelist=['DO170109.2'; 'DO170110.2'; 'DO170111.2'; 'DO170112.2'];

% Initiate Matrix to store the percentage of trials correct
nonmatch = 0:6;
fampct = zeros(size(filelist,1),7); 
nonpct = zeros(size(filelist,1),7); 
fam_totpct = zeros(size(filelist,1),1);

for fillop=1:size(filelist,2);
    fidd=filelist{fillop};
    
    ini=fidd(1:2);
   
    if strcmp(ini,'DO')==1 || strcmp(ini,'do')==1
        mondir = ['X:\Cortex Data\Dorothy\'];
        datfil=[mondir fidd];
        monkey='Dorothy';
    elseif strcmp(ini,'TT')==1 || strcmp(ini,'tt')==1
        mondir = ['X:\Cortex Data\Timmy\'];
        datfil=[mondir fidd];
        monkey='Timmy';
    elseif strcmp(ini,'TO')==1 || strcmp(ini,'to')==1
        mondir = ['X:\Cortex Data\Tobii\'];
        datfil=[mondir fidd];
        monkey='Tobii';
    elseif strcmp(ini,'PW')==1 || strcmp(ini,'pw')==1
        mondir = ['X:\Cortex Data\Vivian\'];
        datfil=[mondir fidd];
        monkey='Vivian';
    elseif strcmp(ini,'WR')==1 || strcmp(ini,'wr')==1
        mondir = ['X:\Cortex Data\Wilbur\'];
        datfil=[mondir fidd];
        monkey='Wilbur';
    elseif strcmp(ini,'RR')==1 || strcmp(ini,'rr')==1
        mondir = ['X:\Cortex Data\Red\'];
        datfil=[mondir fidd];
        monkey='Red';
    elseif strcmp(ini,'MF')==1 || strcmp(ini,'mf')==1
        mondir = ['X:\Cortex Data\Manfred\'];
        datfil=[mondir fidd];
        monkey='Manfred';        
    end
    
    [time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_ALLdata(datfil);
    
    % Array of all trials that include important information.
    numrpt = size(event_arr,2);
    trl= [];
    for rptlop = 1:numrpt
        %% Organizes data into catagories
        if ~isempty(find(event_arr(:,rptlop) == 15,1))
            cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=4999);
            blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
            nmnumind = find(event_arr(:,rptlop) >=300 & event_arr(:,rptlop) <=399);
            test6ind= find(event_arr(:,rptlop) == 48);
            respind = find(event_arr(:,rptlop) >= 200 & event_arr(:,rptlop) <= 209);
            cnd       = event_arr(cndnumind,rptlop);
            blk       = event_arr(blknumind,rptlop);
            nm        = event_arr(nmnumind,rptlop)-301;
            typ       = event_arr(8,rptlop);
            resp      = event_arr(respind,rptlop);
            trl = [trl; [cnd blk nm typ resp rptlop]];
        end
    end
    
    % Isolate the familiar and novel trials
    famtrl= [];
    novtrl= [];
    for lop = 1:numrpt
        if ~isempty(find(trl(lop,4) == 0,1))
            ftrial = trl(lop,:);
            famtrl = [famtrl; ftrial];
        elseif ~isempty(find(trl(lop,4) == 1,1))
            trial = trl(lop,:);
            novtrl = [novtrl; trial];
        end
    end
    
    % Calculate the correctness for each day and level of nonmatch
    for nm = nonmatch
        familiar = find(famtrl(:,3)==nm); % finds the trials with nm number of nonmatch
        famnm = size(familiar); % sum of the number of nonmatch trials
        fampct(fillop,nm+1) = (sum(famtrl(familiar,5)==200))/famnm(1)*100; % percentage correct for nm nonmatch trials
    end
    
    fam_totpct(fillop) = 100*sum(famtrl(:,5)==200)/sum(famtrl(:,5)==205|200);
end

% Total Percentage Correct


%% Plots
figure(2);
subplot(1,3,1:2)
bar(fampct');
hold on 
box off
set(gca,'XTickLabel',{'Fam0';'Fam1';'Fam2';'Fam3';'Fam4';'Fam5';'Fam6'}); 
ylabel('Percent Correct'); 
title('Performance by # Nonmatch')
legend1 = (filelist)

subplot(1,3,3)
bar(fam_totpct);
title('Total Performance');
xlabel('Day'); 
set(gca,'XTickLabel',1:size(filelist,2));