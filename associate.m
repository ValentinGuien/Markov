function Y = associate(X)
   Y = arrayfun(@associate_single,X); 
end



function y = associate_single(x)
    %%%
    % 1/2 -> Promenade -> 1
    % 3 -> Logette -> 2
    % 4/5 -> Manger -> 3
    %%%
    if isnan(x)
        y = nan;
    elseif x==1 | x==2
        y=1;
    elseif x==3
        y=2;
    elseif x==4 | x==5
        y=3;
    else
        y=0;
    end
end