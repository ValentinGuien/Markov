function C = cellcons(X)
%%%Get cell of consecutives series of X%%%
[Y,n] = consecutives(X);
m = length(Y);
C = cell(m,1);
for i=1:m
    C{i} = (X(Y(i)):X(Y(i))+n(i)-1)';
end
end