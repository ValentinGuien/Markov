function AR = ar(V)
%AR Traduire des valeurs de positions en des rythmes d'activite
%   La fonction effectue les regroupements de positions par paquets de 60
%   et en fait une somme ponderee afin d'obtenir la valeur d'activite pour
%   l'heure.

%   Les coefficients sont obtenus a partir d'une AFC
    Vcoeff = arrayfun(@associate_coeff,V); 
    n = size(Vcoeff,2);
    if ismatrix(V)
        AR = reshape(sum(reshape(Vcoeff,60,24,n)),24,n);
    else
        m = size(Vcoeff,3);
        AR = reshape(sum(reshape(Vcoeff,60,24,n,m)),24,n,m);
    end
end

function y = associate_coeff(x)
   coeffs = 60*[0.16,-0.23,0.42];
   y = coeffs(x);
end