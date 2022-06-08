function [ reference ] = TLextract( loc,  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


end
%Each matrix is a one-dimentional
%vector containing the following:
%1: version: 1-4
%2: pre/post: 0/1
%3: monkey:
%1=Red; 2=Vivian; 3=Timmy; 4=Manfred; 5=Tobii
%4: far/close: 0/1
%5: bw/color: 0/1
%6: list/short: 0/1
%7: single/double rep: 0/1

% go to database file and get it into matlab
[~, ~, raw] = xlsread('X:\Ian\VPC_Analysis\DataFiles_Adam2.xlsx','DataFiles_Adam','A2:I110');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[2,3,4,5,6,7,8,9]);
version = raw(:,1);
%preallocate the reference and data arrays
sets = size(version,1);
reference = zeros(sets,7);
data = cell(sets,1);

%loop over the raw form input and organize into reference array
for i=1:sets
    current = [0 0 0 0 0 0 0];
    %1: version: 1-4
    current(1) = version{i};
    %2: pre/post: 0/1
    if string(cellVectors{i,3}) == 'pre'
        current(2) = 0;
    else
        current(2) =1;
    end
    %3: monkey:
    %1=Red; 2=Vivian; 3=Timmy; 4=Manfred; 5=Tobii
    monkeys  = {'red', 'vivian', 'timmy', 'manfred', 'tobii', 'Red', 'Vivian', 'Timmy', 'Manfred', 'Tobii'};
    currentMonkey = string(cellVectors{i,4});
    currentMonkey = strcmp(currentMonkey, monkeys);
    currentMonkey = find(currentMonkey, 1);
    if currentMonkey > 5
        currentMonkey = currentMonkey - 5;
    end
    current(3) = currentMonkey;
    %4: far/close: 0/1
    if string(cellVectors{i,5}) == 'far'
        current(4) = 0;
    else
        current(4) = 1;
    end
    %5: bw/color: 0/1
    if string(cellVectors{i,6}) == 'bw'
        current(5) = 0;
    else
        current(5) = 1;
    end
    %6: list/short: 0/1
    if string(cellVectors{i,7}) == 'list'
        current(6) = 0;
    else
        current(6) = 1;
    end
    %7: single/double rep: 0/1
    if string(cellVectors{i,8}) == 'single'
        current(7) = 0;
    else
        current(7) = 1;
    end
    
    reference(i,:) = current; 
    
    
end