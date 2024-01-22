function latex_string = latex_good_number(x)
%% latex_string = latex_good_number(x)
%% 
%% generates a well structure number for latex printing
%% 

latex_string = sprintf('%.2e',x);

latex_string = regexprep(latex_string,'e\+00','');
latex_string = regexprep(latex_string,'e\+([0-9]+)','\$\\times\\!10^{$1}\$');
latex_string = regexprep(latex_string,'e\-([0-9]+)','\$\\times\\!10^{-$1}\$');

latex_string = regexprep(latex_string,'\^\{0+','^{');
latex_string = regexprep(latex_string,'\^\{-0+','^{-');
