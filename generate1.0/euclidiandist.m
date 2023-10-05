function S = euclidiandist(X,Y)
    S = sqrt(sum((X-Y).^2));
end