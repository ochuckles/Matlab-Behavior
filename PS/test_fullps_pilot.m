% PS Pilot Check
% Goal is to check the PS task to ensure it is displaying everything
% properly and that everything is encoded properly. Listed below is
% everything that needs to be checked. 

%Encodes appearing
    %a zero after every encode
    %condition number
    %number of nonmatches trial intends to present, are those presented
    %correct, early, late
    %eye on/off
    %bar up/down (especially bar up for errors)
    %trialtypes (fam, novel, level of PS difficulty)
%Groups of 12 trials consistent with expectations (familiar and novel trials total 10, + 2 PS trials)     
%Ramp-up familiar block consistent with expectations
%Generally ensuring the block structure is working properly (randomizing,
%right stimuli and cnds, covers all stimuli)
%Pattern Separation
    %Lure presented when it's supposed to be
    %PS trials all 6 nonmatch
    %No repeated stimuli for PS trials
    %All PS trials presented
%Novel and Familiar -
    %randomized
    %ABBAs present
%Timing
    %intertrial interval (should jitter)
    %time between stims
    %error interval



addpath('\\towerexablox.wanprc.org\Buffalo\eblab\Matlab\get_ALLdata')
try 
    close(h)
catch
end

% -----------------------------------------------------------
% ================ SET FILE LIST HERE!!!!!!!! ===============
addpath('C:\Users\cioleary\Documents\MATLAB\Common Functions\')

data_dir = 'X:\eblab\Cortex Programs\Pfizer\Test New PS Task\';

datafiles = 'CIO17051.1';

filename = strcat(data_dir,datafiles);

[time_arr,event_arr,eog_arr,~,~,~]  = get_ALLdata(filename);
% -----------------------------------------------------------


for fillop=1:size(datafiles,2)


    % Find the trials that are early and correct
    [~, correcttrls] = find(event_arr == 200);
    [earlytrlind, earlytrls] = find(event_arr == 205);
    alltrls = 1:size(event_arr,2);
    incorrecttrls = setdiff(alltrls,correcttrls);
    early_correcttrls = sort([earlytrls' correcttrls']);
    
    % Array of all trials that include important information.
    numrpt = size(event_arr,2);
    trl= zeros(numrpt,6);
    for rptlop = 1:numrpt
        % Organizes data into catagories 
        if ~isempty(find(event_arr(:,rptlop) == 15,1))
            % Isolate the data for the novel and repeat images for
            % performance comparison
            cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=4999);
            blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=550);
            nmnumind = find(event_arr(:,rptlop) >=300 & event_arr(:,rptlop) <=310);
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
            trl = [trl; [cnd blk nonmat typ resp rptlop]];
        end
    end
end