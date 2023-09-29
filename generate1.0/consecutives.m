function [Y,n] = consecutives(X)
%CONSECUTIVES Obtenir la liste des index de debut de chaque serie de X et
%leur cardinal. Une serie represente une succession d'entiers qui se
%suivent

% X : tableau d'entiers tries par ordre croissant, sans doublon

% Y : liste des index du premier nombre de chaque serie
% n : liste des cardinaux de chaque serie
x = diff(X);
Y = find([inf;x]>1);
if nargout ==2
    n = diff([Y;length(X)+1]);
end