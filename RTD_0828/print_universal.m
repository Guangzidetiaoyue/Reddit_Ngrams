function print_universal(filename,imageformat)
%% print_universal(filename,imageformat
%% 
%% prints current figure according to prescription in imageformat
%% 
%% 
%% 
%% 
%% 
%% 
%% 
%% 
%%
%% 
%% 

if (~isfield(imageformat,'override'))
    imageformat.override = 'no';
end

cheese_error001;

%% if (strcmp(imageformat.type,'pdf'))
%%     dpistr = sprintf('-r%d',imageformat.dpi);
%% 
%%     filenamepdf = sprintf('%s.pdf',filename);
%% 
%%     print(filenamepdf,'-dpdf',dpistr);    

if (strcmp(imageformat.type,'pdf'))
    
    dpistr = sprintf('-r%d',imageformat.dpi);

    filenameps = sprintf('%s.eps',filename);
    filenamepdf = sprintf('%s.pdf',filename);
    fprintf(1,'printing (colour) to:\n%s.eps\n',filename);
    print(filenameps,'-depsc2',dpistr);

    fprintf(1,'converting to:\n%s.pdf\n',filename);
    pdfcommand = sprintf('epstopdf %s',filenameps);
    system(pdfcommand);
    
    
    if (strcmp(imageformat.deleteps,'yes'))
        disp('deleting postscript...');
        rmcommand = sprintf('\\rm %s',filenameps);
        system(rmcommand);
    end

    %% write to log
    homedir = getenv('HOME');
    cdir = pwd;
    timestamp = datevec(now);

    logfile = sprintf('%s/work/log/figures/%d-%02d',homedir,timestamp(1),timestamp(2));
    fid = fopen(logfile,'a');

    command = sprintf('ls -l %s| awk ''{print $5}''',filenamepdf);
    [status,bytes] = system(command);
    %% remove carriage return
    bytes = bytes(1:end-1);

    %fprintf(fid,'%d %02d %02d %02d %02d %g %s %s/%s\n',timestamp(1),timestamp(2),timestamp(3),timestamp(4),timestamp(5),timestamp(6),bytes,cdir,filenamepdf);

    %fclose(fid);

    fprintf(1,'figure data logged.\n');

elseif (strcmp(imageformat.type,'png')) 
    dpistr = sprintf('-r%d',imageformat.dpi);
    
    
    disp(sprintf('printing to\n%s.png\n',filename));
    filenamepng = sprintf('%s.png',filename);

    print(filenamepng,'-dpng',dpistr);

    bordersize = imageformat.bordersize;
    tmpcommand = ...
        sprintf('convert -trim +repage -bordercolor white -border %d %s %s',bordersize,filenamepng,filenamepng);
    system(tmpcommand);

    %% write to log
    homedir = getenv('HOME');
    cdir = pwd;
    timestamp = datevec(now);

    logfile = sprintf('%s/work/log/figures/%d-%02d',homedir,timestamp(1),timestamp(2));
    fid = fopen(logfile,'a');

    command = sprintf('ls -l %s| awk ''{print $5}''',filenamepng);
    [status,bytes] = system(command);
    %% remove carriage return
    bytes = bytes(1:end-1);

    fprintf(fid,'%d %02d %02d %02d %02d %g %s %s/%s\n',timestamp(1),timestamp(2),timestamp(3),timestamp(4),timestamp(5),timestamp(6),bytes,cdir,filenamepng);

    fclose(fid);

    fprintf(1,'figure data logged.\n');
end

if (strcmp(imageformat.open,'yes') & strcmp(imageformat.override,'no'))
    tmpcommand = sprintf('open %s.%s;',filename,imageformat.type);
    system(tmpcommand);
end

if (strcmp(imageformat.copylink,'yes'))
    tmpcommand = sprintf('printf ''%s.%s'' | pbcopy',filename,imageformat.type);
    system(tmpcommand);
end

