% This function will work 
[a,b]=errorHandler([],1,1,@testfunction,a,b); 
% This one would normally throw an error. errorHandler prints error to file
% and allows the user to move on.
%[a,b]=errorHandler([],1,1,@testfunction_bad,1,2)