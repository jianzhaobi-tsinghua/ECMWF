clear 
clc

startYear=2011;
endYear=2014;

parfor year=startYear:endYear
    if year==2008 || year==2012
        monthnum=[31,29,31,30,31,30,31,31,30,31,30,31];
    else
        monthnum=[31,28,31,30,31,30,31,31,30,31,30,31];
    end 
    postprocessMonth(year,monthnum);
end