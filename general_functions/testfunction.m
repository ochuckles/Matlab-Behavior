function [a,b] = testfunction(a,b);
% test fuction for error handler (2 in, 2 out). Will run successfully if
% both inputs are good.
    a = a+b;
    b = b+1;
end