% Ian's Analysis of SS Reaction times
% Harvests data from Adam's master script that break raw data down to usable
% matricies. 

% Analysis goals:
% Ability to determine when data split occurs (first 3rd, last 3rd vs model
% predicted separation points) and number of splits within a shift
% Average for reaction times per trial within a shift
% Average reaction times per trial for inter vs intra dimensional shifts
% Average reaction time per shift by type (color, texture, shape)

load('C:\Users\cioleary\Documents\Aging_SS\SS_2d.mat')

%name monkeys
monkeys  = {'Samantha', 'Tabitha', 'Blanche', 'Dorothy'};


%%
%Establish overall reaction times
allRT_SA =[]; allRT_TB =[]; allRT_BL =[]; allRT_DO =[];
for i = 1:size(SAShifts,2)
    allRT_SA = [allRT_SA; SAShifts{1, i}(:,8)];
end
for i = 1:size(TBShifts,2)
    allRT_TB = [allRT_TB; TBShifts{1, i}(:,8)];
end
for i = 1:size(BLShifts,2)
    allRT_BL = [allRT_BL; BLShifts{1, i}(:,8)];
end
for i = 1:size(DOShifts,2)
    allRT_DO = [allRT_DO; DOShifts{1, i}(:,8)];
end

all_avgRT = mean([allRT_SA; allRT_TB; allRT_BL; allRT_DO]);
all_medRT = median([allRT_SA; allRT_TB; allRT_BL; allRT_DO]);
avgRT = [mean(allRT_SA), mean(allRT_TB), mean(allRT_BL), mean(allRT_DO)];
medRT = [median(allRT_SA), median(allRT_TB), median(allRT_BL), median(allRT_DO)];

%%
%Summary Reaction time figuresa for each monkey
for i = 1:4
    hold on
    subplot(2,2,i);
    histogram(allTrials{1, i}(:,8),'BinWidth',25)
    ylim = get(gca,'ylim');
    line([avgRT(1,i) avgRT(1,i)],[ylim(1) ylim(2)], 'Color','r');
    line([medRT(1,i) medRT(1,i)],[ylim(1) ylim(2)], 'Color','g');
    hold off
    title(monkeys{1, i}); xlabel('RT'); ylabel('Num Trials');
end
%Just blance
    i = 3;
    hold on
    histogram(allTrials{1, i}(:,8),'BinWidth',25)
    ylim = get(gca,'ylim');
    line([avgRT(1,i) avgRT(1,i)],[ylim(1) ylim(2)], 'Color','r');
    line([medRT(1,i) medRT(1,i)],[ylim(1) ylim(2)], 'Color','g');
    hold off
    title(monkeys{1, i}); xlabel('RT'); ylabel('Num Trials');
%%
%potential periodicity graphs
for i = 1:4
    hold on
    subplot(4,1,i);
    y = allTrials{1,i}(:,8);
    x = 1:length(allTrials{1,i});
    %c = linspace(1,10,x);
    scatter(x',y,25,'filled')
    hold off
    title(monkeys{1, i}); xlabel('Trial'); ylabel('RT');
end

%%
%Break down performance within shift by some parameter, either a step
%function or thirds
stepThr_SA = SA_shiftSummaries(:,10);
stepThr_TB = TB_shiftSummaries(:,10);
stepThr_BL = BL_shiftSummaries(:,10);
stepThr_DO = DO_shiftSummaries(:,10);

addpath('C:\Users\cioleary\Documents\MATLAB\Ian_funcs');
[~, split_RT_SA] = splitFunc(SAShifts, stepThr_SA);
[~, split_RT_TB] = splitFunc(TBShifts, stepThr_TB);
[~, split_RT_BL] = splitFunc(BLShifts, stepThr_BL);
[~, split_RT_DO] = splitFunc(DOShifts, stepThr_DO);

%%
hold on
subplot(2,2,1); boxplot(split_RT_SA);
title(monkeys{1, 1}); xlabel('Thirds'); ylabel('RT');
subplot(2,2,2); boxplot(split_RT_TB);
title(monkeys{1, 2}); xlabel('Thirds'); ylabel('RT');
subplot(2,2,3); boxplot(split_RT_TB);
title(monkeys{1, 3}); xlabel('Thirds'); ylabel('RT');
subplot(2,2,4); boxplot(split_RT_TB);
title(monkeys{1, 4}); xlabel('Thirds'); ylabel('RT');
hold off

% %normalize the split_RT
% split_RT_SA = arrayfun(@(x) split_RT_SA(:,x) ./ sum(split_RT_SA(:,x)),[1:2],'UniformOutput',false);



group = {'First Group', 'Second Group', 'Third Group'};
for i = 1:2
    hold on
    figure(1)
    subplot(2,1,i); histogram(split_RT_SA(:,i),'BinWidth',50);
    title(group{1, i}); xlabel('RT'); ylabel('Frequency');
    xlim([0 2500]); %ylim([0 75]);
    hold off
end
for i = 1:2
    hold on
    figure(2)
    subplot(2,1,i); histogram(split_RT_TB(:,i),'BinWidth',50);
    title(group{1, i}); xlabel('RT'); ylabel('Frequency');
    xlim([0 2500]); %ylim([0 75]);
    hold off
end
for i = 1:2
    hold on
    figure(3)
    subplot(2,1,i); histogram(split_RT_BL(:,i),'BinWidth',50);
    title(group{1, i}); xlabel('RT'); ylabel('Frequency');
    xlim([0 2500]); %ylim([0 75]);
    hold off
end
for i = 1:2
    hold on
    figure(4)
    subplot(2,1,i); histogram(split_RT_DO(:,i),'BinWidth',50);
    title(group{1, i}); xlabel('RT'); ylabel('Frequency');
    xlim([0 2500]); %ylim([0 75]);
    hold off
end

