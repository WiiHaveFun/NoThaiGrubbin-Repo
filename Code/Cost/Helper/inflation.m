function td_val = inflation(base_year,base_price)
%Inflation calculates the 2025 price based on the year and price of the 
% inputted values. Indexing starts from 1970
    data = readmatrix("InflationRates.xlsx");
    b = 2025-base_year + 1;
    r = data(b);
    td_val = base_price*r;
end