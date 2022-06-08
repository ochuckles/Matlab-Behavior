addpath('C:\Users\cioleary\Documents\MATLAB\Common Functions\')

data_dir = 'Z:\Cortex Data\Blanche\';

datafiles = 'BL190530.2';

filename = strcat(data_dir,datafiles);

[time_arr,event_arr,eog_arr,~,~,~]  = get_ALLdata(filename);