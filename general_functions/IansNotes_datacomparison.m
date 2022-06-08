%% bit of script to look at differences between data. For note purposes only

%this part imports the .ncs files. Get the code from aging project folder
%on network. Use actual data of interest in file paths
Data_aws = ('Z:\ProcessedNeuralData\AWS Data\SA180718_aws\CSC123.ncs');
Data_nas = ('Z:\ProcessedNeuralData\AWS Data\SA180718_nas\CSC123.ncs');
[Timestamps, channelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Headr] = Nlx2MatCSC(Data_aws,[1 1 1 1 1], 1,1,1);
[Timestamps2, channelNumbers2, SampleFrequencies2, NumberOfValidSamples2, Samples2, Headr2] = Nlx2MatCSC(Data_nas,[1 1 1 1 1], 1,1,1);

%this section is different ways of looking at the data and comparing it

%visualizing
imagesc(Samples-Samples2)
spy(Samples-Samples2)

%actual signal comparison, should give a 0
sum(sum(Samples-Samples2))
%probably best. gives binary comparison
visdiff(Data_aws, Data_nas) 
%gives logical outcome of comparison of all data points, giant matrix
B = all(Samples==Samples2);
logical(all(B) == 1)
%logcial check if the unique identifier in the header is the same
A = all(Headr{4} == Headr2{4});