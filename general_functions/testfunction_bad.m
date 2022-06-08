function [a,b] = testfunction_bad(a,b);
% test fuction for error handler (2 in, 2 out). Throws and error b.c. line
% 6 is bad.
    a = a+b;
    b = b+1;
    a++
end