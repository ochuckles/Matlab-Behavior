function [varargout] = errorHandler(saveloc,saveDiary,saveME,funhandle,varargin)
%ERRORHANDLER Execute script s.t. Matlab will not stop on errors. 
% errors are writen to diary.txt or ME.mat, and taged with the datetime.
% Inputs:
% saveloc = directory in which to save diary files (default is cwd).
% saveDiary = bool, determining if diary is saved (defauld = 1);
% saveME = boot, determining if error structure should be saved (for
% traceback, default =  1)
% funhandle = function to be evaluated
% varargin = function inputs;
% Outputs:
% varargout = outputs from function funhandle.

dtstr = datestr(datetime);
dtstr(dtstr==':'|dtstr==' '|dtstr == '-') = '_';

if isempty(saveloc)
    saveloc = cd;
end

if saveDiary || isempty(saveDiary)
    diary(fullfile(saveloc,['diary_' dtstr '.txt']));
    diary on;
end

if isempty(saveME)
    saveME  = true;
end

try
    [varargout{1:nargout}] = funhandle(varargin{:});
    disp(['Function ' func2str(funhandle) ' executed successfully.']);
catch ME
	ME
    [varargout{1:nargout}] = deal(nan);
    save(fullfile(saveloc,['ME_' dtstr '.mat']),'ME');
    disp(['Function ' func2str(funhandle) ' failed.']);
end
diary off;
end

