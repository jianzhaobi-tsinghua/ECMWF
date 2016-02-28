clear
clc

tic 

parfor year=2005:2015
    windGlobalProcess(year)
end

toc
