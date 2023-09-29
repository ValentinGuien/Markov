function s = simulstate(p1,p3)
% SIMULSTATE Simulation d'un etat a partir de probabilites donnees

% p1 : probabilite d'etre dans l'etat 1 (AL)
% p3 : probabilite d'etre dans l'etat 3 (AU).
% La probabilite d'etre dans l'etat 2 (LO) est directement donnee par
% 1-p1-p3

% Retourne s=1 si n < p1, 2 si p1<n<1-p3, 3 si 1-p3<n
n = rand();
if n < p1
   s = 1;
elseif 1-p3 < n
   s = 3;
else
   s = 2;
end

end