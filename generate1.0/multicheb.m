function D = multicheb(x,y,k)
    D = sum(maxk(abs(x-y),k))/k;
end