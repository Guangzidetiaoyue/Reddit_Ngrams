function figarchivify(figname,archiveswitch)
%%
%% figarchivify(figname,archiveswitch)
%% 
%% saves each rendered pdf version of a figure
%% for later viewing

system('mkdir -p archive');

if (archiveswitch==0)
    fprintf('\nfigure creation archiving is off ...\n');
else
    fprintf('\nfigure creation archiving is on ...\n');
    
    [filepath,name,ext] = fileparts(figname);
    tmpcommand = sprintf('mkdir -p archive/%s',filepath);
    system(tmpcommand);
    
    tmpcommand = sprintf('cp %s.pdf archive/%s-%s.pdf;',figname,figname,datestr(now,'yyyy-mm-dd-HH-MM-SS'));
    fprintf(1,'archiving figure ...\n');
    system(tmpcommand);

end
