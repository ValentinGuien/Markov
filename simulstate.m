function s = simulstate(p1,p2)
% Retourne 1 si n < p1, 2 si p1<n<p2, 3 si p2<n
n = rand();
if n < p1
   s = 1;
elseif p2 < n
   s = 3;
else
   s = 2;
end

end