function [Y,n] = consecutives(X)
%%%Index of numbers starting series of consecutives numbers%%%
x = diff(X);
Y = find([inf;x]>1);
if nargout ==2
    n = diff([Y;length(X)+1]);
end