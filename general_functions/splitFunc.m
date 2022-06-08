function [ third_RT_Mnk, split_RT_Mnk ] = splitFunc( mnkShifts, stepThr_Mnk )
% splitFunc (Ian O'Leary 20180503) used for SetShift task.
%   Goal of function is to generate matricies of averages per shift, split
%   by various parameters. Takes in the cells of mnkShifts and a threshold
%   parameter(stepThr_Mnk)

 third_RT_Mnk = cell(length(mnkShifts),3);
 split_RT_Mnk = cell(length(mnkShifts),2);
for i = 1:length(mnkShifts)
    currentShift_len = size(mnkShifts{1,i},1);
    splitThresh = stepThr_Mnk(i,1);
    split1 = round(currentShift_len/3);
    split2 = round((currentShift_len/3)*2);
    grpT1 = mnkShifts{1,i}(1:split1,8);
    grpT2 = mnkShifts{1,i}(split1:split2,8);
    grpT3 = mnkShifts{1,i}(split2:end,8);
    splt1 = mnkShifts{1,i}(1:splitThresh-1,8);
    splt2 = mnkShifts{1,i}(splitThresh:end,8);
    current_Tgrp = {grpT1 grpT2 grpT3};
    current_SplitGrp = {splt1 splt2};
    third_RT_Mnk(i,:) = current_Tgrp;
    split_RT_Mnk(i,:) = current_SplitGrp;
end

