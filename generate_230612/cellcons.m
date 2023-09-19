function C = cellcons(X)
%%CELLCONS Convertir X en tableau de cellules ou chaque cellule contient
% une serie de X. Une serie represente une succession d'entiers qui se
% suivent.

% X : tableau d'entiers tries par ordre croissant, sans doublon

% C : tableau de cellules contenant chaque sous-serie.
[Y,n] = consecutives(X);
m = length(Y);
C = cell(m,1);
for i=1:m
    C{i} = (X(Y(i)):X(Y(i))+n(i)-1)';
end
end