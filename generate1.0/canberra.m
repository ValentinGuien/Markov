function cd = canberra(p,q)
   cd = sum(abs(p - q)./ (abs(p) + abs(q)));
 end