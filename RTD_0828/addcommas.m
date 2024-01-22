function numOut = addcommas(numIn)

%% comma for thousands, three decimal places
jf=java.text.DecimalFormat; 

%% omit "char" if you want a string out
numOut= char(jf.format(numIn)); 
