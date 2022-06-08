addpath('X:\Ian\TL_Analysis');

%read in and analyze data for the VPC task.
tolerance = 0; %size of extra space in DVA around picture that gets counted as 'picture'

%goals:
%create two cell arrays
%cell array 1: reference
%each cell is a matrix containing reference information about a
%corresponding cell in the data array. Each matrix is a one-dimentional
%vector containing the following:
%1: version: 1-4
%2: pre/post: 0/1
%3: monkey:
%1=Red; 2=Vivian; 3=Timmy; 4=Manfred; 5=Tobii
%4: far/close: 0/1
%5: bw/color: 0/1
%6: list/short: 0/1
%7: single/double rep: 0/1

%cell array 2: data
%each cell is a matrix containing the data for an experimental session.
%each row of the matrix is a trial. Each column contains a different
%type of information as follows:
%column 1: trial
%column 2: % on L
%column 3: % on R
%column 4: novel/repeat:
    %0=novel
    %1=repeat on L
    %2=repeat on R
%column 5: 2nd repeat?: 0=no; 1=yes

% go to database file and get it into matlab
[~, ~, raw] = xlsread('X:\Ian\TL_Analysis\TL_analysis_clean.xlsx','A2:G341');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[1,3,4,5,6,7]);
version = raw(:,2);
%preallocate the reference and data arrays
sets = size(version,1);
reference = zeros(sets,7);
data = cell(sets,1);

%% Extrct excel data
%loop over the raw form input and organize into reference array
for i=1:sets
    current = [0 0 0 0 0 0 0];
    %1: version: 0-2 (0 == tl.sav, 1 == tl2.sav, 2 == tl2f.sav) 
    current(1) = version{i};
    %2: pre/post: 0/1
    if string(cellVectors{i,5}) == 'pre'
        current(2) = 0;
    else
        current(2) =1;
    end
    %3: monkey:
    %1=Red; 2=Vivian; 3=Timmy; 4=Manfred; 5=Tobii
    monkeys  = {'Red', 'Vivian', 'Timmy', 'Manfred', 'Tobii'};
    currentMonkey = string(cellVectors{i,5});
    currentMonkey = strcmp(currentMonkey, monkeys);
    currentMonkey = find(currentMonkey, 1);
%     if currentMonkey > 5
%         currentMonkey = currentMonkey - 5;
%     end
    current(3) = currentMonkey;
    %4: Data collection: 0/1
    if string(cellVectors{i,6}) == 'No'
        current(4) = 0;
    else
        current(4) = 1;
    end
    %5: bw/color: 0/1
%     if string(cellVectors{i,6}) == 'bw'
%         current(5) = 0;
%     else
%         current(5) = 1;
%     end
%     %6: list/short: 0/1
%     if string(cellVectors{i,7}) == 'list'
%         current(6) = 0;
%     else
%         current(6) = 1;
%     end
%     %7: single/double rep: 0/1
%     if string(cellVectors{i,8}) == 'single'
%         current(7) = 0;
%     else
%         current(7) = 1;
%     end
%     
     reference(i,:) = current; 
%     
%     
end




%% Extract and organize eye data
%loop through data sets to find the CCH data and organize it
for i=1:sets
    current = reference(i,:); %current reference information
    monkeys  = {'Red', 'Vivian', 'Timmy', 'Manfred', 'Tobii'};
    dataFolder = 'X:\Cortex Data\';
    dataFolder = strcat(dataFolder, monkeys{current(3)}, '\');
    CCH_fileName  = strcat(dataFolder, string(cellVectors{i,3}));
    %import the data
    [time_arr,event_arr,eog_arr,epp_arr,header,trialcount]=get_ALLdata(CCH_fileName);
    %if there is eye data then analyze it
    if size(eog_arr, 1)>5
    
        %first pull out the CCH trials
         CCH_index = event_arr(6,:);
        %     VPC_index = find(event_arr(6,:)<1000);
            %get rid of VPC_index values that are incorrect trials
            %this is critical for figuring out the delay lengths later
        %     for w=1:size(VPC_index,2)
        %          currentEvent = event_arr(:,VPC_index(w));
        %         if ~ismember(200, currentEvent(:,1))
        %             VPC_index(w) = NaN;
        %         end
        %     end
        %    VPC_index(isnan(VPC_index)) = [];
        %prepare to find the calibration function for converting to degrees
        %visual angle
        rawx = zeros(25,1);
        rawy = zeros(25,1);
        rawx_n = zeros(25,1);
        rawy_n = zeros(25,1);
        %hard coding of actual locations of CCH condition presentation from
        %item and condition files
        controlx = [0 0 -3 3 0 0 -6 6 0 -6 -3 3 6 -6 -3 3 6 -6 -3 3 6 -3 -3 3 6];
        controly = [0 3 0 0 -3 6 0 0 -6 -6 -6 -6 -6 -3 -3 -3 -3 6 6 6 6 3 3 3 3];
        %loop over CCH trials and collect the x and y positions just before bar
        %release sorted by condition. 
        count = size(CCH_index,2);
        for n=1:count
            %pull out the Event and Time info for the current trial
            currentEvent = event_arr(:,n);
            currentTime = time_arr(:,n);
            %cut to only correct trials
            if ismember(200, currentEvent(:,1))
                %sort into x and y components
                x = eog_arr(1:2:end, n);
                y = eog_arr(2:2:end, n);
                %get rid of NaNs
                x(isnan(x)) = [];
                y(isnan(y)) = [];
                %find the sample rate 
                eyeStart = find(currentEvent==100); %index of eye data start
                eyeStart = currentTime(eyeStart); %time of eye data start
                eyeEnd = find(currentEvent==101); %index of eye data end
                eyeEnd = currentTime(eyeEnd); %time of eye data end
                eyeLength = eyeEnd - eyeStart; %total time of eye data
                sampleRate = eyeLength / size(x,1); 
                %use sampleRate to figure out which sample in eye data is when
                %the bar was released
                barTime = find(currentEvent==4);
                barTime = currentTime(barTime);
                barTime = barTime - eyeStart;
                barTime = round(barTime/sampleRate);
                %calculate the index of the eye data sample 50ms before bar
                %release
                sampleStart = barTime - round(50/sampleRate);
                %get condition number
                cnd = currentEvent(6)-1000;
                %find the average eye position in 50ms before bar release and
                %add it to appropriate condition
                rawx(cnd) = rawx(cnd) + mean(x(sampleStart:barTime));
                rawy(cnd) = rawy(cnd) + mean(y(sampleStart:barTime));
                %itterate the count of the condition
                rawx_n(cnd) = rawx_n(cnd) + 1; 
                rawy_n(cnd) = rawy_n(cnd) + 1;
            end
        end




        %divide summed location values by count of trials in each condition in
        %order to obtain averages
        rawx = rawx./rawx_n;
        rawy = rawy./rawy_n;
        %get the calibration function
        calibrationFnc = get_calibration_fcn([controlx; controly], [reshape(rawx, 1,25); reshape(rawy,1,25)]);
    else
        continue
    end
        
end
 %% Extract and analyze TLs task
  for j=1:sets
     currentTL = reference(j,:); %current reference information
     TL_fileName  = strcat(dataFolder, string(cellVectors{i,1}));
    %import the data
    [time_arr,event_arr,eog_arr,epp_arr,header,trialcount]=get_ALLdata(TL_fileName);
    %if there is eye data then analyze it
    if size(eog_arr, 1)>5
 
    %Using the calibration function, I can now go through the VPC trials
    %and find the eye location in order to pull out the info I want 
    count = size(VPC_index,2);
    %does this session have far appart or close together pictures? 
     farClose = current(4);
     if farClose==0
         farClose=1; %far
     else
         farClose=0; %close
     end
        %calculate the box borders for picture display both right 'r' and
        %left 'l'
            x_r_max = 4.5+farClose*7.5 + (96/24);
            x_r_min = 4.5+farClose*7.5 - (96/24);
            y_r_max = 96/24;
            y_r_min = -96/24;
            x_l_max = -4.5 - farClose*7.5 +(96/24);
            x_l_min = -4.5 - farClose*7.5 - (96/24);
            y_l_max = y_r_max;
            y_l_min = y_r_min;
     currentData = []; %place to store the current session's data
     trial = 1; %VPC trial number
    for n=1:count
        %event encodes
        currentEvent = event_arr(:,VPC_index(n));
       %correct only, this should be redundant from earlier
        if ismember(200, currentEvent(:,1))
            %time information
            currentTime = time_arr(:,VPC_index(n));
            %split the eye data
            x = eog_arr(1:2:end, VPC_index(n));
            y = eog_arr(2:2:end, VPC_index(n));
            %get rid of NaNs
            x(isnan(x)) = [];
            y(isnan(y)) = [];
            %transform it with the function obtained from the CCH trials
             [x,y] = tformfwd(calibrationFnc,x,y);

         %find the sample rate
            eyeStart = find(currentEvent==100);
            eyeStart = currentTime(eyeStart);
            eyeEnd = find(currentEvent==101);
            eyeEnd = currentTime(eyeEnd);
            eyeLength = eyeEnd - eyeStart;
            sampleRate = eyeLength / size(x,1);
            %find when the pictures are on screen in time
            pictureStart = find(currentEvent==23);
            pictureStart = currentTime(pictureStart);
            pictureEnd = find(currentEvent==24);
            pictureEnd = currentTime(pictureEnd);
            %calculate time during which pictures are on screen in index
            %positions
            pictureStart_eyeIndex = round((pictureStart - eyeStart)/sampleRate);
            pictureEnd_eyeIndex = round((pictureEnd - eyeStart)/sampleRate);
            %NaN out the time before and after the image
            x(1:pictureStart_eyeIndex) = NaN;
            y(1:pictureStart_eyeIndex) = NaN;
            x(pictureEnd_eyeIndex:end) = NaN;
            y(pictureEnd_eyeIndex:end) = NaN;
            x(isnan(x)) = [];
            y(isnan(y)) = [];
            %temp variables
            x1 = x;
            y1 = y;
            %NaN out all positions outside the pictures
            x(x1<x_r_min & x1>x_l_max) = NaN;
            y(x1<x_r_min & x1>x_l_max) = NaN;
            x(y1<y_r_min & y1>y_r_max) = NaN;
            y(y1<y_r_min & y1>y_r_max) = NaN;
              x(isnan(x)) = [];
            y(isnan(y)) = [];
        %column 1: trial
        currentData(trial, 1) = trial;
        %column 2: % on L
        currentData(trial, 2) = size(find(x<x_l_max & x>x_l_min),1) / size(x,1);
        %column 3: % on R
        currentData(trial, 3) = size(find(x<x_r_max & x>x_r_min),1) / size(x,1);
        %column 4: novel/repeat:
        currentData(trial, 4) = currentEvent(6)-1;
        %column 5: 2nd repeat?: 0=no; 1=yes
        if currentEvent(6) ==3
            currentData(trial, 5) = 1;
        else
            currentData(trial, 5) = 0;
        end
        %column 6: long=1 or short=0 (won't work correctly for version 3
        %b/c lists.
        %EDIT HERE TO BECOME SENSITIVE TO LIST ISSUES FOR VERSION 3
        if currentData(trial, 4) == 0 && n<count %if it's novel then look forward in order to establish long/short delay
            if VPC_index(n+1) - VPC_index(n) > 10
                currentData(trial, 6) = 1;
            else
                currentData(trial, 6) = 0;
            end
        else %if it's a repeat look backward in order to establish long/short delay
            if VPC_index(n) - VPC_index(n-1) > 10
                currentData(trial, 6) = 1;
            else
                currentData(trial, 6) = 0;
            end
        end
      trial = trial + 1;
      
         end
    end
    data{i} = currentData;

    end
  end


%data are organized into data and reference cell arrays. Now it's tim e to
%condense it down into summary stats. 

%version 3 analysis
     %data organized into a table with the following columns
    %column 1: monkey
    %column 2: novel looking % PRE
    %column 3: repeat looking % PRE
    %column 4: novel - repeat % PRE
    %column 5: novel looking % POST
    %column 6: repeat looking % POST
    %column 7: novel-repeat % POST
           summaryData_3 = zeros(5, 7);
    summaryData_3_n = zeros(5, 7);
for i=1:sets
    %_n will be used to divide out for average calculation at the end
    if reference(i,1)==3
        currentSet = data{i}; 
        trials = size(currentSet, 1);
        monkey = reference(i,3);
        prePost = reference(i,2);
        for t=1:trials
            if currentSet(t,4)==0
                %novel presentation
                summaryData_3(monkey, prePost*3+1) = summaryData_3(monkey, prePost*3+1) + currentSet(t,2);
                summaryData_3_n(monkey, prePost*3+1) = summaryData_3_n(monkey, prePost*3+1)+1;
            end
            if currentSet(t,4)==1
                %left side repeat
                summaryData_3(monkey, prePost*3+2) = summaryData_3(monkey, prePost*3+2) + currentSet(t,2);
                summaryData_3_n(monkey, prePost*3+2) = summaryData_3_n(monkey, prePost*3+2)+1;
            end
            
            
        end
      
    
    
    
    end
end

summaryData_3 = summaryData_3 ./ summaryData_3_n;


%version 4 analysis
%currently over looking 
     %data organized into a table with the following columns
   
    %column 1: novel looking short % PRE
    %column 2: repeat looking short% PRE
    %column 3: novel - repeat short% PRE  
    %column 4: novel looking long % PRE
    %column 5: repeat looking long% PRE
    %column 6: novel - repeat long% PRE
    %column 7: novel looking short% POST
    %column 8: repeat looking short% POST
    %column 9: novel-repeat short% POST
    %column 10: novel looking long % PRE
    %column 11: repeat looking long% PRE
    %column 12: novel - repeat long% PRE
           summaryData_4 = zeros(5, 12);
    summaryData_4_n = zeros(5, 12);
for i=1:sets
    %_n will be used to divide out for average calculation at the end
    if reference(i,1)==4
        currentSet = data{i}; 
        trials = size(currentSet, 1);
        monkey = reference(i,3);
        prePost = reference(i,2);
        
        for t=1:trials
            shortLong = currentSet(t,6);
            if currentSet(t,4)==0 && t<trials
               if currentSet(t+1, 4)==2 %means repeat is coming on right side
                   addOne = 1;
               else
                   addOne = 0;
               end
                %novel presentation
                summaryData_4(monkey, prePost*6+1+shortLong*3) = summaryData_4(monkey, prePost*6+1+shortLong*3) + currentSet(t,2+addOne);
                summaryData_4_n(monkey, prePost*6+1+shortLong*3) = summaryData_4_n(monkey, prePost*6+1+shortLong*3)+1;
            end
            if currentSet(t,4)==1 || currentSet(t,4)==2
                if currentSet(t, 4)==2 %means repeat is on right side
                   addOne = 1;
               else
                   addOne = 0;
               end
                %left side repeat
                summaryData_4(monkey, prePost*6+2+shortLong*3) = summaryData_4(monkey, prePost*6+2+shortLong*3) + currentSet(t,2+addOne);
                summaryData_4_n(monkey, prePost*6+2+shortLong*3) = summaryData_4_n(monkey, prePost*6+2+shortLong*3)+1;
            end
            
            
        end
      
    
    
    
    end
end

summaryData_4 = summaryData_4 ./ summaryData_4_n;
summaryData_4(:,3) = summaryData_4(:,1)-summaryData_4(:,2);
summaryData_4(:,6) = summaryData_4(:,4)-summaryData_4(:,5);
summaryData_4(:,9) = summaryData_4(:,7)-summaryData_4(:,8);
summaryData_4(:,12) = summaryData_4(:,10)-summaryData_4(:,11);
summaryData_3(:,3) = summaryData_3(:,1)-summaryData_3(:,2);
summaryData_3(:,6) = summaryData_3(:,4)-summaryData_3(:,5);







