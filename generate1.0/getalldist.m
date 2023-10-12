function S = getalldist(mean_ar,ar,hours,measure)  
    if isstring(measure) && measure == "minkowski"
        S = pdist2(mean_ar(hours)',ar(hours,:)',measure,3);
    elseif ishandle(measure) && isequal(measure,@DiscreteFrechetDisct)
        S = pdist2(mean_ar(hours),ar(hours,:),measure);
    else
        S = pdist2(mean_ar(hours)',ar(hours,:)',measure);
    end
    %S = S/length(hours);
end