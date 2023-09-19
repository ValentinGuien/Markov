function fuzzydate = fuzzydays(row,rules)
    if row.oestrus==1
        fuzzydate = [(row.date+rules.oestrus(1)):(row.date-1),(row.date+1:row.date+rules.oestrus(2))]; 
    elseif row.calving==1
        fuzzydate = [(row.date+rules.calving(1)):(row.date-1),(row.date+1:row.date+rules.calving(2))];
    elseif row.lameness==1
        fuzzydate = [(row.date+rules.lameness(1)):(row.date-1),(row.date+1:row.date+rules.lameness(2))];
    elseif row.mastitis==1
        fuzzydate = [(row.date+rules.mastitis(1)):(row.date-1),(row.date+1:row.date+rules.mastitis(2))];
    elseif row.LPS==1
        fuzzydate = [(row.date+rules.LPS(1)):(row.date-1),(row.date+1:row.date+rules.LPS(2))];
    elseif row.other_disease==1
        fuzzydate = [(row.date+rules.other_disease(1)):(row.date-1),(row.date+1:row.date+rules.other_disease(2))];
    elseif row.accidents==1
        fuzzydate = [];
    elseif row.disturbance==1
        fuzzydate = [(row.date+rules.disturbance(1)):(row.date-1),(row.date+1:row.date+rules.disturbance(2))];
    elseif row.mixing==1
        fuzzydate = [(row.date+rules.mixing(1)):(row.date-1),(row.date+1:row.date+rules.mixing(2))];
    end
end