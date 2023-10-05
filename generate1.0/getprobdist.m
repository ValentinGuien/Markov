function S = getprobdist(mean_ar,all_ar,measure,ishealthy)
    myfunc = @(X)(measure(X,mean_ar));
    if ishealthy
        ncows = size(all_ar,2);   
        S = zeros(ncows * 200,1);

        k=0;

        
        for icow = 1:ncows
            ndays = size(all_ar{icow},2);
            for iday = 1:ndays
                k = k+1;
                S(k) = myfunc(all_ar{icow}(:,iday));
            end
        end
        S = S(1:k);
    else
        p = size(all_ar.AR_uh,2);
        S = zeros(p,1);
        for j = 1:p
            S(j) = myfunc(all_ar.AR_uh(:,j));
        end
    end
ends