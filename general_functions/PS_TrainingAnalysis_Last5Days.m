addpath('\\buffalotower.wanprc.org\Buffalo\eblab\Matlab\get_ALLdata')
try 
    close(h)
catch
end

%% SETUP PARAMETERS HERE
% ========================== SET MONKEY HERE ==============================
monkey = 'Tabitha';

% ================ SET DMS TRAINING FILE EXTENSION HERE ===================
ext = '.2'; %ie: '.2' for files ending as in DO161201.2

% ================== SPECIFY HOW MANY DAYS TO INCLUDE =====================
n = 5;

%% PULL FILES TO BE ANALYZED

% Monkey code
if strcmp(monkey,'Dorothy')
    mc = 'DO';
elseif strcmp(monkey,'Blanche')
    mc = 'BL';
elseif strcmp(monkey,'Tabitha')
    mc = 'TB';
end

% Set working directories
mondir = ['\\buffalotower.wanprc.org\Buffalo\Cortex Data\' monkey '\'];
imgdir = '\\buffalotower.wanprc.org\Buffalo\eblab\Cortex Programs\DMS PS Yassa\DMSPS Training\Training Image Sets\';

% Isolate the last 5 days of saved files
files = dir(mondir);
files = {files.name};
dates = zeros(1,length(files)-3);
for i = 4:length(files)
    name = files{i};
    dates(i-3) = str2num(name(3:8));
end
sorteddates = sort(unique(dates));
lastdays = sorteddates(end-n+1:end); %%%%%%%%%%%%%%%%%%%%%%%%%%%
filelist = cell(1,length(lastdays));
lgnd = cell(1,length(lastdays));

files(1:3) = [];
dmspstfiles = cellfun(@(x) strcmp(x(9:10),ext), files);
dmspst = files(dmspstfiles);
filelist = dmspst(end-n+1:end);
lgnd = filelist;

% for fillop = 1:length(lastdays)
%     
%     filelist{fillop} = strcat(mc,num2str(lastdays(fillop)),ext);
%     lgnd{fillop} = strcat(mc,num2str(lastdays(fillop)),ext,' (', num2str(n*-1+fillop-1), ')');
% end

% -----------------------------------------------------------
% ============= OVERRIDE FILE LIST HERE!!!!!!!! =============
% filelist=['BL170421.3'; 'BL170424.3'; 'BL170425.3'; 'BL170426.3';'BL170427.3'];
% -----------------------------------------------------------

%% ANALYZE PERFORMANCE IN TRAINING
% Initiate Matrix to store the percentage of trials correct
nonmatch = 0:6;
fampct = zeros(size(filelist,1),7); 
nonpct = zeros(size(filelist,1),7); 
fam_totpct = zeros(size(filelist,1),1);
rptmistakes = zeros(size(filelist,1),7);

% structure of img_timing: each cell represents a single day of the file.
% Within that cell is a single matrix pulling the early/correct trials,
% eye start, novel image on, novel image off, release image on, released image off.
img_timing = cell(size(filelist,2));

% Structure of the img_eye: each cell represents a single day of the file.
% Within that cell is a secondary cell mapping in the same way as the
% img_timing cell.  The third level isolates the values into x (1) and y (2).
% Example: img_eye{1}{1,1}{1} -- eye data for the first file, novel image
% on, first  trial, and x data.
img_eye = cell(size(filelist,2));

for fillop=1:size(filelist,2)
    datfil=[mondir [filelist{fillop}]];
    
    [time_arr,event_arr,eog_arr,~,~,~]  = get_ALLdata(datfil);
    
    % =====================================================================
    % Only look at the last p percent of the dms trials (as a decimal)
    p = 0.90;
    % =====================================================================
    
    event_arr = event_arr(:,round(size(event_arr,2)*(1-p)):end);
    time_arr = time_arr(:,round(size(time_arr,2)*(p)):end);
    
    %% CALCULATE NOVEL AND REPEAT STATISTICS
    
    % Find the trials that are early and correct
    [~, correcttrls] = find(event_arr == 200);
    [earlytrlind, earlytrls] = find(event_arr == 205);
    alltrls = 1:size(event_arr,2);
    incorrecttrls = setdiff(alltrls,correcttrls);
    early_correcttrls = sort([earlytrls' correcttrls']);
    
    % Initiate the array to hold eye data -- structured such that every
    % column is a different trials.  The rows represent if the trial was 
    % either correct or early (0/1), eye start, the first image on,
    % first image off, released image on, released image off respectivley.
    img_timing{fillop} = zeros(6,size(event_arr,2));
    img_eye{fillop} = cell(6,size(event_arr,2));
    
    % Array of all trials that include important information.
    numrpt = size(event_arr,2);
    trl= zeros(numrpt,6);
    for rptlop = 1:numrpt
        % Organizes data into catagories 
        if ~isempty(find(event_arr(:,rptlop) == 15,1))
            % Isolate the data for the novel and repeat images for
            % performance comparison
            cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=4999);
            blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
            nmnumind = find(event_arr(:,rptlop) >=300 & event_arr(:,rptlop) <=399);
            test6ind= find(event_arr(:,rptlop) == 48);
            respind = find(event_arr(:,rptlop) >= 200 & event_arr(:,rptlop) <= 209);
            cnd       = event_arr(cndnumind,rptlop);
            blk       = event_arr(blknumind,rptlop);
            nonmat    = event_arr(nmnumind,rptlop)-301;
            if event_arr(cndnumind,rptlop) <= 1007
                typ = 0;
            elseif event_arr(cndnumind,rptlop) > 1007
                typ = event_arr(nmnumind,rptlop);
            end
            % typ       = event_arr(8,rptlop); %only use if logging the
                                               %event in row 8 -- ie 302, 303, 304... 
            resp      = event_arr(respind,rptlop);
            trl(rptlop,:) = [cnd blk nonmat typ resp rptlop];
            
%             %% Isolate the eye data to determine the viewing behavior between the
%             % novel and released image
%             eye_start = time_arr(4,rptlop);
% 
%             % Isolate the eye trace for the first image that comes on the screen
%             img_on = find(event_arr(:,rptlop) == 23,1);
%             img_off = find(event_arr(:,rptlop) == 24,1);
% 
%             % Isolate the eye trace for the released image
%             if sum(find(correcttrls == rptlop))==1 % logging for correct trials
%                 release_img_on = find(event_arr(:,rptlop) == 23,2);
%                 bar_release  = find(event_arr(:,rptlop) == 4); % encode is 4 when the trial is correct
%                 img_timing(1,rptlop) = 1;
%             elseif sum(find(earlytrls == rptlop))==1 % if the trial is early
%                 bar_release = find(event_arr(:,rptlop) == 205);
%                 release_img_on = bar_release - 1;
%                 img_timing(1, rptlop) = 1;
%             end
%             
%             % Place all indexed values into a single matrix for recall
%             % later
%             img_timing{fillop}(2,rptlop) = time_arr(eye_start,rptlop);
%             img_timing{fillop}(3,rptlop) = time_arr(img_on,rptlop);
%             img_timing{fillop}(4,rptlop) = time_arr(img_off,rptlop);
%             img_timing{fillop}(5,rptlop) = time_arr(release_img_on,rptlop);
%             img_timing{fillop}(6,rptlop) = time_arr(bar_release,rptlop);
%             
%             % Pull out the corresponding x and y eye postiions for the
%             % indices for the images on screen
%             img_eye{fillop}{1,rptlop}{1} = ;
%             
        
        end
        
        
    end
    
    % Isolate the familiar and novel trials
    famtrl= [];
    novtrl= [];
    for lop = 1:numrpt
        if ~isempty(find(trl(lop,4) == 0,1))
            ftrial = trl(lop,:);
            famtrl = [famtrl; ftrial];
        elseif ~isempty(find(trl(lop,4) > 0,1))
            trial = trl(lop,:);
            novtrl = [novtrl; trial];
        end
    end
    
    % Calculate the correctness for each day and level of nonmatch
    for nm = nonmatch
        % familiar trials
        familiar = find(famtrl(:,3)==nm); % finds the trials with nm number of nonmatch
        famnm = size(familiar); % sum of the number of nonmatch trials
        %  fampct(fillop,nm+1) = (sum(famtrl(familiar,5)==200))/famnm(1)*100; % percentage correct for nm nonmatch trials
        fampct(fillop,nm+1) = (sum(famtrl(familiar,5)==200))/(sum(famtrl(familiar,5)==200)+sum(famtrl(familiar,5)==205))*100; % percentage correct for nm nonmatch trials
        
        % novel trials
        novel = find(novtrl(:,3)==nm); % finds the trials with nm number of nonmatch
        novnm = size(novel); % sum of the number of nonmatch trials
        % novpct(fillop,nm+1) = (sum(novtrl(novel,5)==200))/novnm(1)*100; % percentage correct for nm nonmatch trials
        novpct(fillop,nm+1) = (sum(novtrl(novel,5)==200))/(sum(novtrl(novel,5)==200)+sum(novtrl(novel,5)==205))*100; % percentage correct for nm nonmatch trials
        
    end
    
    % Overall performance for each day
    fam_totpct(fillop) = 100*sum(famtrl(:,5)==200)/(sum(famtrl(:,5)==205) + sum(famtrl(:,5)==200));
    nov_totpct(fillop) = 100*sum(novtrl(:,5)==200)/(sum(novtrl(:,5)==205) + sum(novtrl(:,5)==200));
    
    % Find the conditions that she got wrong
    earlytrls = find(trl(:,5)==205);
    earlycnds = trl(earlytrls,1);
    cndhist = hist(earlycnds, max(earlycnds)-min(earlycnds));
    [num, loc] = sort(cndhist,'descend');
    rptmistakes(fillop,:) = num(1:7)/length(earlycnds);
    
%     %% ISOLATE VIEWING BEHAVIOR
%     %  Look at the mirco viewing behavior for the first image and the image
%     %  released.  Further seperate these into two groups -- one of correct
%     %  and other of incorrect trials
%     %  Because she frequently looks away from the screen, getting late
%     %  errors, we will only count trials where she is either early or
%     %  correct.  Remove all other trials
%     
%     % Isolate incorrect and correct trials
%     [~, correcttrls] = find(event_arr == 200);
%     [earlytrlind, earlytrls] = find(event_arr == 205);
%     alltrls = 1:size(event_arr,2);
%     incorrecttrls = setdiff(alltrls,correcttrls);
%     early_correcttrls = sort([earlytrls' correcttrls']);
%     
%     % Isolate eye traces for the first and the release image
%     nm = trl(:,3);
%     eye_start = time_arr(4,:);
%     [img_on_event,img_on_event_trl] = find(event_arr == 23,1);
%     [img_off_event,img_off_event_trl] = find(event_arr == 24,1);
%     
%     % Isolate when the released image comes on
%     rpt_img_on = zeros(size(event_arr,2));
%     rpt_img_ind = find(event_arr == 23,2);
%     rpt_img_on(correcttrls) = rpt_img_ind;
%     rpt_img_on(earlytrls) = earlytrlind-1;
%     
%     % Bar release will eather be encoded as 4 if the trial is correct or
%     % 205 if the trial is terminated early by a bar release.  This will be
%     % when the released image effectively goes off screen
%     bar_release = zeros(1,size(event_arr,2));
%     [bar_ind,~] = find(event_arr(:,correcttrls) == 4);
%     bar_release(correcttrls) = bar_ind;
%     [bar_ind,~] = find(event_arr(:,earlytrls) == 205);
%     bar_release(earlytrls) = bar_ind - 1;
%     
%     % Put all values into image time array where columns are trials, and
%     % rows are first image on, first image off, released image on, released
%     % image off
%     img_time_arr = zeros(5,size(event_arr),2);
%     img_time_arr(1,:) = time_arr(img
%     img_time_arr(2,:) = time_arr(img_on_event,img_on_event_trl);
%     img_time_arr(3,:) = time_arr(img_off_event,img_off_event_trl);
%     img_time_arr(4,:) = time_arr(rpt_img_on,alltrls);
%     img_time_arr(5,:) = time_arr(bar_release,alltrls);
%     
%     
%     
%     
end

%% Look at performance over time for the last file run.  
%  File is broken into blocks of 20 trials to look at average performance
%  during that time

blocksize = 20;
numblocks = round(size(trl,1)/blocksize);

avgperf = zeros(1,numblocks);
absavgperf = zeros(1,numblocks);
tot_avgperf = 100*sum(trl(:,5)==200)/(sum(trl(:,5)==200) + sum(trl(:,5)==205));
tot_absavgperf = 100*sum(trl(:,5)==200)/size(trl,1);

numnonmatch = zeros(max(trl(:,3))+1,numblocks);
totnm = zeros(8,1);

for block = 0:numblocks-2
    numcorr = sum(trl(block*blocksize+1:(block+1)*blocksize,5) == 200);
    numearl = sum(trl(block*blocksize+1:(block+1)*blocksize,5) == 205);
    avgperf(block+1) = 100*numcorr/(numcorr+numearl);
    absavgperf(block+1) = 100*numcorr/blocksize;
    for nmnum = 0:max(trl(:,3));
        numnonmatch(nmnum+1,block+1) = 100*sum(trl(block*blocksize+1:(block+1)*blocksize,3) == nmnum)/blocksize;
        if block == 0
            totnm(nmnum+2) = sum(trl(:,3)==nmnum);
        end
    end
end

totnm = 100*totnm/size(trl,1);

%% Plots
% Familiar
h = figure;
subplot(3,4,1:3)
bar(fampct'); hold on; 
p = patch([0,n+1,n+1,0],[45,45,55,55],'r','LineStyle','none');
alpha(p,0.1);
q = patch([0,n+1,n+1,0],[49,49,51,51],'r','LineStyle','none');
alpha(q,0.25);
box off
set(gca,'XTickLabel',{'Fam0';'Fam1';'Fam2';'Fam3';'Fam4';'Fam5';'Fam6'}); 
ylabel('Performance (%)'); 
title('Performance by # Nonmatch (Familiar)')
axis([0 8 0 100]);

legend(lgnd, 'FontSize', 6);

subplot(3,4,4)
bar(fam_totpct); hold on;
p = patch([0,n+1,n+1,0],[70,70,80,80],'r','LineStyle','none');
alpha(p,0.1);
q = patch([0,n+1,n+1,0],[74,74,76,76],'r','LineStyle','none');
alpha(q,0.25);
title('Total Performance (Familiar)');
xlabel('Day'); 
set(gca,'XTickLabel',size(filelist,2)*-1:-1);
axis([0 n+1 0 100]);

% Novel
subplot(3,4,5:7)
bar(novpct'); hold on; 
p = patch([0,n+1,n+1,0],[45,45,55,55],'r','LineStyle','none');
q = patch([0,n+1,n+1,0],[49,49,51,51],'r','LineStyle','none');
alpha(q,0.25);
alpha(p,0.1);
box off
set(gca,'XTickLabel',{'Nov0';'Nov1';'Nov2';'Nov3';'Nov4';'Nov5';'Nov6'}); 
ylabel('Performance (%)'); 
title('Performance by # Nonmatch (Novel)')
axis([0 8 0 100]);

subplot(3,4,8)
bar(nov_totpct); hold on;
p = patch([0,n+1,n+1,0],[70,70,80,80],'r','LineStyle','none');
alpha(p,0.1);
q = patch([0,n+1,n+1,0],[74,74,76,76],'r','LineStyle','none');
alpha(q,0.25);
title('Total Performance (Novel)');
xlabel('Day'); 
set(gca,'XTickLabel',size(filelist,2)*-1:-1);
axis([0 n+1 0 100]);

subplot(3,4,9:10)
x = 1:numblocks;
w1 = 1;
w2 = 0.1;
plot([0 numblocks],[tot_avgperf tot_avgperf],'c'); hold on;
plot([0 numblocks],[tot_absavgperf tot_absavgperf],'m'); hold on;
plot(x, avgperf, 'b','Linewidth',4); hold on;
plot(x, absavgperf, 'r', 'Linewidth',2); hold on;
p = patch([0,numblocks+1,numblocks+1,0],[70,70,80,80],'r','LineStyle','none'); hold on;
alpha(p,0.25);
p = patch([0,numblocks+1,numblocks+1,0],[tot_absavgperf,tot_absavgperf,70,70],'r','LineStyle','none'); hold on;
alpha(p,0.1);
title('Previous Day Performance over Time');
xlabel('Time (over recording session)');
ylabel('Performance (%)')
lgnd2 = {'Average Weighted Performance'; 'Average Absolute Performance';...
    'Weighted Performance (Early/Correct)';'Absolute Performance(Early/Correct/Late/Break/etc'};
legend(lgnd2,'FontSize',6,'Location','southeast');
set(gca,'XTickLabel','')
axis([0 numblocks+1 0 100]);

subplot(3,4,11:12)
pltclrs = ['y','m','r','g','c','b','k'];
for j = 1:size(numnonmatch,1)
    plot(x, numnonmatch(j,:), pltclrs(j),'Linewidth',2); hold on;
end
lgnd3 = {'0 nm','1 nm','2 nm','3 nm','4 nm','5 nm','6 nm'};
legend(lgnd3{1:size(numnonmatch,1)},'FontSize', 6);
for k = 1:size(numnonmatch,1)+1
    p = patch([0,numblocks+1,numblocks+1,0],[sum(totnm(1:k)),sum(totnm(1:k)),sum(totnm(1:k+1)),sum(totnm(1:k+1))],pltclrs(k),'LineStyle','none'); hold on;
    alpha(p,0.15);
end
set(gca,'XTickLabel','');
ylabel('Proportion by Nonmatch Number (%)'); 
xlabel('Time (over recording session)');
title('Number of Nonmatch over Trial Time')
axis([0 numblocks+1 0 100]);
% %%
% figure(2)
% b = bar(numnonmatch.','stacked')
% b(1).Parent.Parent.Colormap = [1 1 0;
%                                1 0 1;
%                                1 0 0;
%                                1 1 1;
%                                0 1 1;
%                                0 0 1;
%                                0 0 0];
