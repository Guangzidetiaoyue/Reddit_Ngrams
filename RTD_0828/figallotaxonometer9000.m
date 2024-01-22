function things = figallotaxonometer9000(mixedelements,tag,settings)
%% 
%% things = figallotaxonometer9000(mixedelements,tag,settings)
%% 
%% general script for (1) generating rank shuffling plots
%% and (2) element shift according to a divergence of choice
%% 
%% for naming convention, 
%% see: https://tvtropes.org/pmwiki/pmwiki.php/Main/AdvancedTech2000
%% 
%% - shifts may be included to the right of plots
%%   and/or as separate figures
%% 
%% produces a main comparison plot for:
%% 1. rank-rank
%% 2. count-count
%% 3. probability-probability
%%
%% optionial instrument application to measure divergence:
%% - contours on main plot
%% - dominant shifts according to chosen divergence
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% outputs:
%% 
%% the main output, of course, is the figure
%% the structure 'things' collects a few details produced
%% in making the figure, though is not well developed
%% 
%% don't be lured into thinking the output is important
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% inputs in detail:
%% 
%% mixedelements is produced by combine_distributions script:
%% 
%% mixedelements =
%% combine_distributions(system1.elements,system2.elements);
%% 
%% mixedelements must have fields: ranks and counts
%% with probs being optional
%%
%% tag = string to append to file name
%% pdf will be stored in:
%% figallotaxonometer9000/figallotaxonometer9000_tag.pdf
%% 
%% general settings:
%% 
%% settings.system1_name and settings.system2_name:
%% strings for titles and axis labels
%%
%% optional: 
%% settings.system1_name_short
%% settings.system2_name_short
%% - set these if title is too long for axis labels
%% 
%% optional:
%% settings.units
%% - plural
%% - default is 'counts'
%% - e.g., 'dollars', 'market cap', 'volume'
%% 
%% settings.typename
%% settings.typenameplural
%% - defaults to 'type' and 'types'
%% - e.g., settings.typename = 'word'
%% - only set plural if irregular
%% 
%%%%%%%%%%
%% 
%% settings.plotkind
%% 1. 'rank'
%% 
%% 2. 'count'
%% 
%% 3. 'probability' (normalized counts)
%% 
%% instrument for asseessing divergence:
%% 
%% 0. none
%% settings.instrument = 'none' 
%% - main plot will be rank-rank (default), count-count, or probability-probability
%% 
%% 1. rank divergence 
%% settings.instrument = 'rank divergence'
%% - main plot will be rank-rank
%% 
%% 2. probability divergence
%% settings.instrument = 'probability divergence'
%% - main plot will be probability-probability
%% 
%% 3. symmetric generalized entropy alpha divergence (generalization of Jensen-Shannon divergence)
%% settings.instrument = 'alpha divergence type 2'
%% - main plot will be probability-probability
%% - notes:
%%   Eq. 37 (see unnumbered version below Eq. 40) in:
%%   "Families of Alpha- Beta- and Gamma- Divergences: Flexible and
%%   Robust Measures of Similarities"
%%   Cichocki and Amari
%%   Entropy, Vol. 12, pp. 1543--1568, 2010.

%%
%% Note: for all measures, parameter alpha is set to nearest
%% multiple of 1/12; finer resolution is not necessary and a
%% discrete scale is beneficial for practical use
%% 
%% settings for rank shuffling plot:
%%
%% settings.axislabel_top1 (optional, latex string): First line in axis label,
%% system 1
%% settings.axislabel_top2 (optional, latex string): First line in axis label,
%% system 2
%% 
%% settings.maxrank_log10 (optional, integer > 0): upper limit for rank
%% 
%% settings.maxcount_log10 (optional, integer > 0): upper limit for count
%% 
%% settings.cell_length: side length of histogram boxes on log10 scale
%%         if not set (default is 1/15)
%% 
%% settings.deltamin_text_color: minimum factor for light grey for
%%         text labels (default is 0.35)
%% 
%% settings.binwidth = vertical width of bins for annoations in main plot
%% (default is 0.15)
%% 
%% deprecated, maybe:
%% settings.topNhistogram = 25;
%% (early version: settings.topNshuffling)
%% 
%% settings for shifts:
%% 
%% settings.combined_plot = 'yes' or 'no';
%% default: 'yes'
%% 
%% settings.separate_shuffling_plot = 'yes' or 'no';
%% default: 'no'
%% 
%% settings.separate_shift_plot = 'yes' or 'no';
%% default: 'no'
%% 
%% settings.topNshift = 40;
%% default: 40
%% 
%% settings.topNdeltasum = number or 'all';
%% default: 'all'
%% 
%% settings.maxstringlength;
%% truncate words longer than settings.maxstringlength
%% default: 12;
%% 
%% settings.turbulencegraph.labels = '' (default) or 'off'
%% used with no instrument to create a bare turbulence graph
%% 
%% settings.imageformat
%% see print_universal for options
%% default:
%% imageformat.type = 'pdf';
%% imageformat.dpi = 600;
%% imageformat.deleteps = 'yes';
%% imageformat.open = 'yes'; 
%% imageformat.copylink = 'no';
%%
%% settings.annotations
%% default: 'off'
%% with
%% settings.annotations = 'on';
%% will add labels across the allonotaxonograph
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% example usages:


%% subset-handles
%% subset-hashtags
%% subset-hashtags-latin-characters
%% subset-latin-characters
%% subset-latin-characters-simple

more off;

loadcolors;
heatmapcolors = magma(10^4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% settings:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (~isfield(settings,'system1_name_short'))
    settings.system1_name_short = settings.system1_name;
end

if (~isfield(settings,'system2_name_short'))
    settings.system2_name_short = settings.system2_name;
end

%% units
if (~isfield(settings,'units'))
    settings.units = 'counts';
end


%% name for types
if (~isfield(settings,'typename'))
    settings.typename = 'type';
end
if (~isfield(settings,'typenameplural'))
    settings.typenameplural = ...
        sprintf('%ss',settings.typename);
end

%% labels for zipf turbulence graph
if (isfield(settings,'turbulencegraph'))
    if (~isfield(settings.turbulencegraph,'labels'))
        settings.turbulencegraph.labels = 'on';
    end
else
    settings.turbulencegraph.labels = 'on';
end



if (~isfield(settings,'plotkind'))
    settings.plotkind = 'rank'; %% defaultx
    fprintf(1,'Generating rank-rank plot (default)\n');
end

if (strcmp(settings.plotkind,'count'))
    %% ensure no instrument is used for count-count plot
    settings.instrument = 'none';
end

N = length(mixedelements(1).ranks);

%%%%%%%%%%%%%%%%%%%%%
%% divergence histogram

if (~isfield(settings,'binwidth'))
    binwidth = 0.15;
else
    binwidth = settings.binwidth;
end

if (~isfield(settings,'cell_length'))
    cell_length = 1/15;
else
    cell_length = settings.cell_length;
end

%%%%%%%%%%%%%%%%%%%%%
%% divergence histogram: label text colors

if (~isfield(settings,'deltamin_text_color'))
    deltamin_text_color = 0.35;
else
    deltamin_text_color = settings.deltamin_text_color;
end

%% nomenclature upgrade; backwards compatibility
if (isfield(settings,'topNshuffling') & ...
    ~isfield(settings,'topNhistogram'))
    settings.topNhistogram = settings.topNshuffling;
end


%%%%%%%%%%%%%%%%%%%%%
%% instrument choice
if (~isfield(settings,'instrument'))
    settings.instrument = 'none';
    fprintf(1,'No instrument (default)\n');
end

if (strcmp(settings.topNdeltasum,'all')) 
    topNdeltasum = N;
else 
    topNdeltasum = min([N,settings.topNdeltasum]);
end

if(~isfield(settings,'max_plot_string_length'))
    settings.maxstringlength = 20;
end

if(~isfield(settings,'max_shift_string_length'))
    settings.maxstringlength = 25;
end

if(~isfield(settings,'xoffset'))
    settings.xoffset = 0;
end

%% make pretend probs if absent
if (~isfield(mixedelements(1),'probs'))
    for j=1:2
        mixedelements(j).probs = ...
            mixedelements(j).counts/sum(mixedelements(j).counts);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% use instrument, if set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% probability instruments first
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(settings.instrument,'alpha divergence type 2'))

    if ((settings.alpha >= 1) || ...
        (settings.alpha < -2))
        error('Required: -2 <= alpha < 1.');
    end

    %% measure alpha divergences (symmetric, type 2)
    [divergence,deltas] = alpha_divergence_symmetric_type2(...
        mixedelements(1).probs,...
        mixedelements(2).probs,...
        settings.alpha);
    title_str = 'Symmetric Generalized Entropy Divergence';
    title_str_abbrv = 'Sym. Gen. Entropy Div.';
    title_str_mod{1} = 'Symmetric Generalized';
    title_str_mod{2} = 'Entropy Divergence';

    if (settings.alpha == 0)
        title_special_str = 'Jenson-Shannon Divergence';
        title_special_str_abbrv = 'Jenson-Shannon Divergence';
    end
    
    divergence_superscript_str = 'H';
    
elseif (strcmp(settings.instrument,'probability divergence'))
    if (settings.alpha < 0)
        error('Required: alpha >= 0.');
    end
    %% measure probability divergences with a simple alpha norm
    %% includes standards such as Euclidean, Manhattan, Hellinger
    [deltas,normalization,indices_deltas_PTD] = ...
        probability_turbulence_divergence(mixedelements,settings.alpha);
    title_str = 'Probability-Turbulence Divergence';
    title_str_abbrv = 'Probability-Turbulence Divergence';
    
    divergence_superscript_str = 'P';
    
elseif (strcmp(settings.instrument,'rank divergence'))
    %% measure rank divergences with modified alpha norm
    %% note inversions of ranks

    if (isfield(settings,'alpha'))
        %% set alpha to closest multiple of 1/12
        settings.alpha = round(12*settings.alpha)/12;
        %% write out adjusted value at the end
    end
    
    [deltas,normalization] = rank_turbulence_divergence(mixedelements,settings.alpha);
    %%     deltas = alpha_norm_type2(...
    %%         mixedelements(1).ranks.^-1,...
    %%         mixedelements(2).ranks.^-1,...
    %%         settings.alpha);

    title_str = 'Rank-Turbulence Divergence';
    title_str_abbrv = 'Rank-Turbulence Divergence';

    %% earlier:
    %% title_str = 'Rank-Turbulence Divergence';
    %% title_str_abbrv = 'Rank-Turbulence Divergence';

    divergence_superscript_str = 'R';
    
    %% generate random version
    %% [deltas,normalization] =
    %% rank_turbulence_divergence(mixedelements,settings.alpha);
    %% or 
    %% [deltas,normalization] = rank_turbulence_divergence_rand(mixedelements,settings.alpha);
    
elseif (strcmp(settings.instrument,'none'))
    %% compute simple deltas for RTD with alpha = 0
    settings.alpha = 0;
    deltas = alpha_norm_type2(...
        mixedelements(1).ranks.^-1,...
        mixedelements(2).ranks.^-1,...
        settings.alpha);
    title_str = '';
    divergence_superscript_str = 'R';
    
else
    error('instrument not recognized'); %% should not happen as
                                        %% default is set to 'none'
                                        %% if instrument field is not present
end

if (isfield(settings,'alpha'))
    [n_alpha,d_alpha] = rat(settings.alpha);

    if (settings.alpha == Inf)
        alpha_str = '\infty';
        alpha_frac_str = '\infty';
    elseif (d_alpha == 1)
        alpha_str = sprintf('%d',...
                            n_alpha);
        alpha_frac_str = sprintf('%d',...
                            n_alpha);
    else
        alpha_str = sprintf('%d/%d',...
                            n_alpha,...
                            d_alpha);
        alpha_frac_str = sprintf('\\frac{%d}{%d}',...
                            n_alpha,...
                            d_alpha);
    end
end

%% deltas to be used:
%% deltas = divergences_ranks;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% prepare deltas, regardless of source (exception is for PTD, alpha=0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% overall divergence 
%% (naming: divergence.m is a built-in matlab function)
divergence_score = sum(deltas);


%% re-sort deltas
if (strcmp(settings.instrument,'probability divergence') & ...
    (settings.alpha == 0))
    %% special case
    indices_deltas = indices_deltas_PTD;
else
    [~,indices_deltas] = sort(deltas,'descend');
end
deltas = deltas(indices_deltas);

%% re-sort mixedelements:
mixedelements(1).types = mixedelements(1).types(indices_deltas);
mixedelements(1).counts = mixedelements(1).counts(indices_deltas);
mixedelements(1).ranks = mixedelements(1).ranks(indices_deltas);
if(isfield(mixedelements,'probs'))
    mixedelements(1).probs = ...
        mixedelements(1).probs(indices_deltas);
end

%%  mixedelements(2).types = mixedelements(2).types(indices_deltas);
mixedelements(2).counts = mixedelements(2).counts(indices_deltas);
mixedelements(2).ranks = mixedelements(2).ranks(indices_deltas);
if(isfield(mixedelements,'probs'))
    mixedelements(2).probs = ...
        mixedelements(2).probs(indices_deltas);
end

%% extra delta pieces:
deltas_loss = deltas;
deltas_gain = deltas;

if (strcmp(settings.plotkind,'probability'))
    deltas_loss(find(mixedelements(1).probs < mixedelements(2).probs)) = -1;
    deltas_gain(find(mixedelements(1).probs > mixedelements(2).probs)) =-1;
else
    deltas_loss(find(mixedelements(1).ranks > mixedelements(2).ranks)) = -1;
    deltas_gain(find(mixedelements(1).ranks < mixedelements(2).ranks)) =-1;
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('visible','on');
set(gcf,'color','none');

tmpfigh = gcf;
clf;
figshape(2000,1335);
%% automatically create postscript whenever
%% figure is drawn
tmpoutdir = 'figallotaxonometer9000';
tmpcommand = sprintf('mkdir -p %s',tmpoutdir);
system(tmpcommand);

tmpfilename = sprintf('%s/%s-%s',tmpoutdir,tmpoutdir,tag);

tmpfilenoname = sprintf('%s_noname',tmpfilename);

%% global switches
%set(groot,'DefaultAxesFontname','Arial');
%set(groot,'DefaultTextFontName','Arial');
set(gcf,'Color','none');
set(gcf,'InvertHardCopy', 'off');
set(gcf,'DefaultAxesFontname','Arial');
set(gcf,'DefaultTextFontName','Arial');
set(gcf,'Renderer','Painters');

set(gcf,'DefaultAxesColor','none');
set(gcf,'DefaultLineMarkerSize',10);
% set(gcf,'DefaultLineMarkerEdgeColor','k');
set(gcf,'DefaultLineMarkerFaceColor','w');
set(gcf,'DefaultAxesLineWidth',0.5);

set(gcf,'PaperPositionMode','auto');

%% tmpsym = {'ok-','sk-','dk-','vk-','^k-','>k-','<k-','pk-','hk-'};
%% tmpsym = {'k-','r-','b-','m-','c-','g-','y-'};
%% tmpsym = {'k-','k-.','k:','k--','r-','r-.','r:','r--'};
%% tmplw = [ 1.5*ones(1,4), .5*ones(1,4)];


%% main plot (rank-rank or probability-probabiliity)
axes_positions(1).box = [.10 .10 .50 .75];

%% element shift 
axes_positions(2).box = [.60 + settings.xoffset, .10, .30, .70];

%% heatmap colorbar
axes_positions(3).box = [.08, .09, .14, .21];

%% guide for equal divergence curves
%% axes_positions(4).box = [.49, .61, .12, .18];
%% axes_positions(4).box = [.49, .63, .12, .18];
axes_positions(4).box = [.50, .64, .11, .165];

%% top left corner title, equation
axes_positions(5).box = [.10 .10 .50 .75];

%% underlying blank canvas to (hopefully) force
%% locatiions of axes to be the same across pdfs
if (~strcmp(settings.instrument,'none')) %% instrument is present
    axes_positions(6).box = [.07, .05, 0.85 + settings.xoffset, .81];
else %% no instrument
    axes_positions(6).box = [.07, .05, 0.53, .81];
end

%% alpha linear gauge, indicator
axes_positions(7).box = [.08 .735 .17 .02];

%% box for indicating sizes of systems
%% 
axes_positions(8).box = [.505, .05, .11, .09];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT: overall canvas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

axesnum = 6;
tmpaxes_bg = axes('position',axes_positions(axesnum).box);

set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'color','none');
set(gca,'FontName','Arial');
tmpaxes_bg.XAxis.Color = 'w';
tmpaxes_bg.YAxis.Color = 'w';

if (strcmp(settings.plotkind,'rank'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: rank version
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% potential details for histogram

    %% overall number of types
    details.N = length(mixedelements(1).types);
    details.Nshared = sum((mixedelements(1).counts > 0) & ...
                          (mixedelements(2).counts > 0));

    %% number of types in each system
    details.N1 = sum(mixedelements(1).counts > 0);
    details.N2 = sum(mixedelements(2).counts > 0);
    
    %% number of types exclusive to each system
    details.N1exclusive = sum(mixedelements(2).counts == 0);
    details.N2exclusive = sum(mixedelements(1).counts == 0);

    %% total counts in each system (generalize to sizes)
    details.totalcounts1 = sum(mixedelements(1).counts);
    details.totalcounts2 = sum(mixedelements(2).counts);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% zipf comparison diamond plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% compute rotated coordinates for each type:
    xrotated = 1/sqrt(2) * (log10(mixedelements(2).ranks) - log10(mixedelements(1).ranks));
    yrotated = 1/sqrt(2) * (log10(mixedelements(2).ranks) + log10(mixedelements(1).ranks));

    minlog10 = 0; %% always for ranks
    maxlog10 = ceil(max([...
        log10(max(mixedelements(1).ranks)),...
        log10(max(mixedelements(2).ranks))]));
    if (isfield(settings,'maxrank_log10'))
        if (maxlog10 < settings.maxrank_log10)
            maxlog10 = settings.maxrank_log10;
        else
            fprintf(1,['settings.maxrank_log10 below data level---' ...
                       'ignored\n'])
        end
    end
    %% for too small data sets
    if (maxlog10 < 1)
        maxlog10 = 1;
    end

    %%%%%%%%%%%%%%%%%%%%%
    %% set up background
    %%%%%%%%%%%%%%%%%%%%%

    axesnum = 1;
    tmpaxes_bg = axes('position',axes_positions(axesnum).box);

    bg_alpha = 0.75;

    x_triangle = [0, maxlog10,  maxlog10, 0];
    y_triangle = [0, maxlog10,  0, 0];
    tmph = fill(x_triangle,y_triangle,colors.lightgrey);
    set(tmph,'edgecolor',colors.lightgrey);
    set(tmph,'facealpha',bg_alpha);
    set(tmph,'edgealpha',bg_alpha);

    hold on;

    x_triangle = [0, maxlog10,  0, 0];
    y_triangle = [0, maxlog10,  maxlog10, 0];
    tmph = fill(x_triangle,y_triangle,colors.paleblue);
    set(tmph,'edgecolor',colors.paleblue);
    set(tmph,'facealpha',bg_alpha);
    set(tmph,'edgealpha',bg_alpha);

    hold on;

    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'color','none');
    set(gca,'FontName','Arial');
    xlim([0 maxlog10]);
    ylim([0 maxlog10]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% rotate to left-right view

    view(135,90);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% main diamond plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    axesnum = 1;
    tmpaxes(axesnum) = axes('position',axes_positions(axesnum).box);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% indicators for zeros
    zeros1 = (mixedelements(1).counts == 0);
    zeros2 = (mixedelements(2).counts == 0);

    %% gel preparation

    %% [tmp,topdownindices] = sort(max([log10(mixedelements(1).ranks),log10(mixedelements(2).ranks)],[],2),'ascend');

    indices_left = find(mixedelements(1).ranks < mixedelements(2).ranks);
    indices_right = find(mixedelements(1).ranks > mixedelements(2).ranks);
    indices_middle = find(mixedelements(1).ranks == ...
                          mixedelements(2).ranks);

    %% only plot points once:
    [unique_ranks,unique_indices,expander_indices] = ...
        unique([log10(mixedelements(1).ranks),log10(mixedelements(2).ranks)],...
               'rows');

    [pointcounts,pointindices] = hist(expander_indices,1:max(expander_indices));

    indices_left_unique = unique_indices(find(mixedelements(1).ranks(unique_indices) < mixedelements(2).ranks(unique_indices)));
    indices_right_unique = unique_indices(find(mixedelements(1).ranks(unique_indices) > mixedelements(2).ranks(unique_indices)));
    indices_middle_unique = unique_indices(find(mixedelements(1).ranks(unique_indices) == ...
                                                mixedelements(2).ranks(unique_indices)));


    [tmp,tmpindices] = sort(mixedelements(1).ranks(indices_middle),'ascend');
    indices_middle = indices_middle(tmpindices);


    %% background of diamonds

    Ncells = floor(maxlog10/cell_length) + 1;
    x1_centervals = ones(Ncells,1)*[0:cell_length:maxlog10];
    x2_centervals = x1_centervals';

    x1_indices = 1 + floor(log10(mixedelements(1).ranks)/cell_length);
    x2_indices = 1 + floor(log10(mixedelements(2).ranks)/cell_length);

    counts = zeros(Ncells,Ncells);
    for i=1:length(mixedelements(1).ranks)
        counts(x1_indices(i),x2_indices(i)) = ...
            counts(x1_indices(i),x2_indices(i)) + 1;
    end

    
    %% optional setting for maxcount (use to make sets of figures agree in colormap)
    maxcounts = max(counts(:));
    if(isfield(settings,'maxcount_log10'))
        maxcountslog10 = ceil(settings.maxcount_log10);
        %% catch
        if (maxcountslog10 < 1)
            maxcountslog10 = 1;
        end
    else %% based on data
        maxcounts = max(counts(:));
        %% round up
        maxcountslog10 = ceil(log10(maxcounts));
    end
    
    for i=1:Ncells
        for j=1:Ncells
            tmpx = [x1_centervals(i,j) - 0*cell_length/2 + 0;
                    x1_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x1_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x1_centervals(i,j) - 0*cell_length/2 + 0];
            tmpy = [x2_centervals(i,j) - 0*cell_length/2 + 0;
                    x2_centervals(i,j) - 0*cell_length/2 + 0;
                    x2_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x2_centervals(i,j) - 0*cell_length/2 + cell_length];
            
            %% add histogram box if one ore more pairs of ranks are
            %% present
            %% else: add strength of divergence for middle of that box
            if (counts(i,j) > 0)

                factor = 0.0 + 1*(1 - log10(counts(i,j))/maxcountslog10);
                %%            factor = 1 - (0.02 + 0.98*(1 - log10(counts(i,j))/maxcountslog10));

                %%            set(tmph,'edgecolor',colors.blue);

                %%            tmpcolors = parula(10^4);

                %%            tmpcolors = inferno(10^4);
                %% tmpcolors = plasma(10^4);
                
                colorindex = ceil(factor*(10^4-1));
                if (colorindex <= 0)
                    fprintf(1,['Rank plot warning: Unideal situation of a color ' ...
                               'index out of range: %d\n'], ...
                    colorindex);
                    colorindex = 1;
                end
                if (colorindex > 10^4)
                    fprintf(1,['Rank plot warning: Unideal situation of a color ' ...
                               'index out of range: %d > 10k\n'], ...
                            colorindex);
                    colorindex = 10^4;
                end

                tmph = fill(tmpx,tmpy,heatmapcolors(colorindex,:));
                set(tmph,'edgecolor',.7*heatmapcolors(colorindex,:));

                %%            tmph = fill(tmpx,tmpy,factor*[1 1 1]);
                %%            set(tmph,'edgecolor',.7*factor*[1 1 1]);
                
                set(tmph,'linewidth',.5);

                %% set(tmph,'facealpha',factor);
                %%            set(tmph,'edgealpha',factor);
                
                hold on;

                %%         else
                %%             factor = 0.9;
                %%             tmph = fill(tmpx,tmpy,factor*[1 1 .8]);
                %%             set(tmph,'edgecolor',.9*factor*[1 1 .8]);
                %%             
                %%             hold on;
            end
        end
    end

    %% set(gca,'clipping','off')


    %% logrankvals = [0:cell_length:maxlog10-cell_length];
    %% for i=1:length(logrankvals)
    %%     tmpx = [logrankvals(i) + 0;
    %%             logrankvals(i) + cell_length;
    %%             logrankvals(i) + cell_length;
    %%             logrankvals(i) + 0];
    %%     for j=1:length(logrankvals)
    %%         tmpy = [logrankvals(j) + 0;
    %%                 logrankvals(j) + 0;
    %%                 logrankvals(j) + cell_length;
    %%                 logrankvals(j) + cell_length];
    %%         
    %%         if (rand(1) < 0.3)
    %%             if (abs(i-j) < .01*(i+j)^2)
    %%                 factor = 1 - (i+j)/(10*length(logrankvals));
    %%                 tmph = fill(tmpx,tmpy,factor*[1 1 1]);
    %%                 set(tmph,'edgecolor',.9*factor*[1 1 1]);
    %%                 
    %%                 hold on;
    %%             end
    %%         end
    %%     end
    %% end



    %% indices_left = intersect(indices_left,topdownindices);
    %% indices_right = intersect(indices_right,topdownindices);

    %% %% left side, gel:
    %% 
    %% %% ordering is confusing but this works:
    %% tmph = loglog(mixedelements(2).ranks(indices_left_unique),...
    %%               mixedelements(1).ranks(indices_left_unique),...
    %%               'o');
    %% 
    %% %% whos *unique*
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% hold on;
    %% 

    grid on;
    grid minor;

    %% 
    %% %% right side, gel:
    %% 
    %% tmph = loglog(mixedelements(2).ranks(indices_right_unique),...
    %%               mixedelements(1).ranks(indices_right_unique),...
    %%               'o');
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% %% middle side, gel:
    %% 
    %% tmph = loglog(mixedelements(2).ranks(indices_middle_unique),...
    %%              mixedelements(1).ranks(indices_middle_unique),...
    %%              'o');
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% hold on;



    %% left side, points:

    pointsize = 1;

    %%     tmph = plot(log10(mixedelements(2).ranks(indices_left_unique)),...
    %%                 log10(mixedelements(1).ranks(indices_left_unique)),...
    %%                 'o');
    %%     set(tmph,'markerfacecolor',colors.blue);
    %%     set(tmph,'markeredgecolor',colors.blue);
    %%     set(tmph,'markersize',pointsize);
    %% 
    %%     hold on;

    %% right side, points:

    %% tmph = plot(log10(mixedelements(2).ranks(indices_right_unique)),...
    %%               log10(mixedelements(1).ranks(indices_right_unique)),...
    %%               'o');
    %% set(tmph,'markerfacecolor',colors.blue);
    %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markersize',pointsize);
    %% 
    %% hold on;

    %% middle, points:

    %% tmph = plot(log10(mixedelements(2).ranks(indices_middle_unique)),...
    %%               log10(mixedelements(1).ranks(indices_middle_unique)),...
    %%               'o');
    %% %% set(tmph,'markerfacecolor',colors.blue);
    %% %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markerfacecolor','k');
    %% set(tmph,'markeredgecolor','k');
    %% set(tmph,'markersize',pointsize);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add center line

    transparency_alpha = 0.75;
    transparency_alpha_alt = 0.05;

    tmpr1 = logspace(0,maxlog10,100);
    tmph = plot(log10(tmpr1),log10(tmpr1),'-');

    hold on;

    %% grid on;

    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;
    
    if (~strcmp(settings.instrument,'none'))
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add lines of constant divergence:

        %% use a contour plot

        Ninset = 10^3;
        tmpr1 = col(logspace(0,maxlog10,Ninset));
        tmpr2 = col(logspace(0,maxlog10,Ninset));

        %% RTD normalization is applied in line following
        %% (arrays don't work with RTD calc)
        deltamatrix = alpha_norm_type2(tmpr1.^-1*ones(1,length(tmpr1)),...
                                       ones(length(tmpr1),1)*tmpr2'.^-1,...
                                       settings.alpha);
        
        deltamatrix = deltamatrix/normalization; %% from earlier

        delta_edge_full = deltamatrix(:,end);
        
        %% prevent contours from crossing the center line
        for i=1:size(deltamatrix,1)
            deltamatrix(i,i) = -1;
        end
        for i=1:size(deltamatrix,1)-1
            deltamatrix(i,i+1) = -1;
            deltamatrix(i+1,i) = -1;
        end
        
        Ncontours = 10;
        %% find heights along bottom of diamond and create
        %% even spacing for contours finishing there
        
        contour_indices = round(linspace(1,length(tmpr1),Ncontours+2));
        heights = deltamatrix(end,contour_indices(2:end-1));
        
        tmpcontours = contourc(log10(tmpr1),...
                               log10(tmpr2),...
                               deltamatrix,...
                               heights);
        %%                               Ncontours);

        %% extract contours
        i=1;
        while(size(tmpcontours,2) > 0)
            Npairs = tmpcontours(2,1);
            contours(i).x1 = tmpcontours(1,2:Npairs+1);
            contours(i).x2 = tmpcontours(2,2:Npairs+1);
            tmpcontours = tmpcontours(:,Npairs+2:end);
            i=i+1;
        end

        %% plot contours
        for i=1:length(contours)
            tmpr1 = contours(i).x1;
            tmpr2 = contours(i).x2;
            tmpxrot = 1/sqrt(2)*abs((tmpr2) - (tmpr1));
            indices = find(abs(tmpxrot) >= 0.1);

            if (length(indices)>0)
                tmph = plot((tmpr1(indices)),(tmpr2(indices)),'-');
                
                set(tmph,'color','k');
                tmph.Color(4) = transparency_alpha;
                set(tmph,'linewidth',0.25);
                hold on;
            end
        end

        %% alphacolors = 'k';
        %% deltavals = 10.^(-[1:9]);
        %% 
        %% 
        %% for i=1:length(deltavals)
        %%     if (i > 1)
        %%         tmpr1 = col(logspace(0,maxlog10,100));
        %%     else
        %%         %%        tmpr1 = logspace(0,maxlog10,100);
        %%         tmpr1 = col(logspace(0,maxlog10,100));
        %%     end
        %%     
        %%     delta = deltavals(i);
        %%     tmpr2 = col(((delta^alpha_norm_val + 1./tmpr1.^alpha_norm_val)).^(-1/alpha_norm_val));
        %% 
        %%     tmpxrot = 1/sqrt(2)*abs(log10(tmpr2) - log10(tmpr1));
        %% 
        %%     indices = find(abs(tmpxrot) >= 0.1);
        %%     
        %%     if (length(indices)>0)
        %%         tmph = plot(log10(tmpr1(indices)),log10(tmpr2(indices)),'-');
        %% 
        %%         set(tmph,'color',alphacolors);
        %%         tmph.Color(4) = transparency_alpha;
        %%         set(tmph,'linewidth',0.25);
        %% 
        %%         tmph = plot(log10(tmpr2(indices)),log10(tmpr1(indices)),'-');
        %% 
        %%         set(tmph,'color',alphacolors);
        %%         tmph.Color(4) = transparency_alpha;
        %%         set(tmph,'linewidth',0.25);
        %%     end
        %%     
        %% %%     indices = find(abs(tmpxrot) < 0.1);
        %% %%     
        %% %%     if (length(indices)>0)
        %% %%         tmph = plot(log10(tmpr1(indices)),log10(tmpr2(indices)),'-');
        %% %% 
        %% %%         set(tmph,'color',alphacolors);
        %% %%         tmph.Color(4) = transparency_alpha_alt;
        %% %%         set(tmph,'linewidth',0.25);
        %% %% 
        %% %%         tmph = plot(log10(tmpr2(indices)),log10(tmpr1(indices)),'-');
        %% %% 
        %% %%         set(tmph,'color',alphacolors);
        %% %%         tmph.Color(4) = transparency_alpha_alt;
        %% %%         set(tmph,'linewidth',0.25);
        %% %%     end
        %% 
        %% end
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% rotate to left-right view

    view(135,90);
    set(gca,'FontName','Arial');
    set(gca,'fontsize',14);
    set(gca,'color','none');
    %% set(gca,'Color',colors.lightergrey);


    %% for use with layered plots
    %% set(gca,'box','off')

    %% adjust limits
    %% tmpv = axis;
    %% axis([]);
    xlim([0 maxlog10]);
    ylim([0 maxlog10]);

    set(gca,'xtick',(0:1:maxlog10));
    set(gca,'ytick',(0:1:maxlog10));
    set(gca,'FontName','Arial');
    if (strcmp(settings.turbulencegraph.labels,'off')) 
        set(gca,'xticklabel',{});
        set(gca,'yticklabel',{});
        set(gca,'FontName','Arial');
    else
        %% adjust ticks
        %tmpaxes(axesnum).TickLabelInterpreter='latex';

        tmpxticklabels = get(gca,'xticklabel');
        clear tmpxticklabels_mod;
        for i=1:length(tmpxticklabels)
            tmpexp = str2num(cell2mat(tmpxticklabels(i)));
            if (tmpexp <= 3)
                tmpxticklabels_mod{i} = sprintf('$%d$',10^tmpexp);
            else
                tmpxticklabels_mod{i} = ...
                    sprintf('$10^{%s}$',tmpxticklabels{i});
            end
            tmpxticklabels_mod{i} = addcommas(10^(i-1));
        end
        set(gca,'xticklabel',tmpxticklabels_mod)
        set(gca,'FontName','Arial','FontSize',14);
        tmpyticklabels = get(gca,'yticklabel');
        clear tmpyticklabels_mod;
        for i=1:length(tmpyticklabels)
            if (tmpexp <= 3)
                tmpyticklabels_mod{i} = sprintf('$%d$',10^tmpexp);
            else
                tmpyticklabels_mod{i} = sprintf('$10^{%s}$', ...
                                                tmpyticklabels{i});
            end
            tmpyticklabels_mod{i} = addcommas(10^(i-1));
        end
        set(gca,'yticklabel',tmpyticklabels_mod)
        set(gca,'FontName','Arial');
    end


    %% change axis line width (default is 0.5)
    %% set(tmpaxes(axesnum),'linewidth',2)

    %% fix up tickmarks
    %% set(gca,'xtick',[1 100 10^4])
    %% set(gca,'xticklabel',{'','',''})
    %% set(gca,'ytick',[1 100 10^4])
    %% set(gca,'yticklabel',{'','',''})

    %% the following will usually not be printed 
    %% in good copy for papers
    %% (except for legend without labels)

    %% remove a plot from the legend
    %% set(get(get(tmph,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    %% %% legend

    %% tmplh = legend('stuff',...);
    %% tmplh = legend('','','');
    %% 
    %% tmplh.Interpreter = 'latex';
    %% set(tmplh,'position',get(tmplh,'position')-[x y 0 0])
    %% %% change font
    %% tmplh_obj = findobj(tmplh,'type','text');
    %% set(tmplh_obj,'FontSize',18);
    %% %% remove box:
    %% legend boxoff

    %% use latex interpreter for text, sans Arial

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add words along edges of rank-rank histogram
    %% 
    %% space out vertically to prevent overlap
    %% 
    %% if instrument is being used, adjust color
    %% to reflect strength of word's contribution
    %% 
    %% optional: include words that are requested
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf(1,['Using binwidth=%g for annotations in main plot ' ...
               '(default)\n\n'],binwidth);

    wordbins = [0:binwidth:max(yrotated)+binwidth];

    for ibin = 1:length(wordbins)-1
        indices = find((yrotated >= wordbins(ibin)) & (yrotated < wordbins(ibin+1)));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add words along edges, left side
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        [delta,inceptionindex] = max(deltas_loss(indices));
        %%        inceptionindex = randint(length(indices))
        %%        delta = deltas_loss(indices(inceptionindex))

        if ((length(inceptionindex) > 0) & (delta > 0))
            index = indices(inceptionindex);
              
            word = char(mixedelements(1).types(index));

            word_otherprob = mixedelements(2).probs(index);
            if (length(word) > settings.max_plot_string_length)
                word = [word(1:settings.max_plot_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
            end
            if (word_otherprob == 0)
                %%                word = [word, '\,$\bullet$'];
            end
            %%        fprintf(1,'%s, %g\n',word,delta);
            
            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');
            
            %% prevent some havoc
            word = regexprep(word,'$','\\$');
            word = regexprep(word,'#','\\#');
            word = regexprep(word,'_','\\_');

            
            yrotcenter = wordbins(ibin) + binwidth/2;
            xrot = xrotated(index);
            
            r1 = 10.^(1/sqrt(2)*(yrotcenter - xrot));
            r2 = 10.^(1/sqrt(2)*(yrotcenter + xrot));

            %%        tmpXcoords(ibin) = log10(1.10*mixedelements(2).ranks(index));
            %%        tmpYcoords(ibin) = log10(0.90*mixedelements(1).ranks(index));

            tmpXcoords(ibin) = log10(1.10*r2);
            tmpYcoords(ibin) = log10(0.90*r1);
           
            %% no instrument: alternate dark grey and black
            if (strcmp(settings.instrument,'none'))
                if (rem(ibin,2)==1)
                    %%            tmphrightwords(i).Color = 'k';
                    tmpcolor = 'k';
                else
                    %%            tmphrightwords(i).Color = colors.darkergrey;
                    tmpcolor = colors.darkergrey;
                end
            else
                %% instrument: color by deltas
                tmpfactor = delta/max(deltas_loss);
                tmpcolor = ((1 - tmpfactor)*(1 - deltamin_text_color)) ...
                    * [1 1 1];
            end


            if (~strcmp(settings.turbulencegraph.labels,'off')) 
                tmphleftwords(ibin) = text(tmpXcoords(ibin),tmpYcoords(ibin),...
                                           word,...
                                           'FontName','Arial',...
                                           'fontsize',16,...
                                           'units','data',...
                                           'horizontalalignment','right',...
                                           'color',tmpcolor); %'interpreter','latex'
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add words along edges, right side
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        [delta,inceptionindex] = max(deltas_gain(indices));
        
        %% more complicated: take random one from a box, not the
        %% right most one; 
        %% better: randomize equal rank types within systems

        if ((length(inceptionindex) > 0) & (delta >= 0))
            index = indices(inceptionindex);
            
            word = char(mixedelements(1).types(index));

            
            word_otherprob = mixedelements(1).probs(index);

            if (length(word) > settings.max_plot_string_length)
                word = [word(1:settings.max_plot_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
            end
            if (word_otherprob == 0)
                %%                word = ['$\bullet$\,',word];
            end
            
            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');

            %% prevent some havoc
            word = regexprep(word,'$','\\$');
            word = regexprep(word,'#','\\#');
            word = regexprep(word,'_','\\_');
            
            

            %%        fprintf(1,'%s, %g\n',word,delta);

            %%        tmpXcoords(ibin) = log10(0.90*mixedelements(2).ranks(index));
            %%        tmpYcoords(ibin) =
            %%        log10(1.10*mixedelements(1).ranks(index));
            
            yrotcenter = wordbins(ibin) + binwidth/2;
            xrot = xrotated(index);
            
            r1 = 10.^(1/sqrt(2)*(yrotcenter - xrot));
            r2 = 10.^(1/sqrt(2)*(yrotcenter + xrot));

            %%        tmpXcoords(ibin) = log10(1.10*mixedelements(2).ranks(index));
            %%        tmpYcoords(ibin) = log10(0.90*mixedelements(1).ranks(index));

            tmpXcoords(ibin) = log10(0.90*r2);
            tmpYcoords(ibin) = log10(1.10*r1);
            tmphalign = 'left';
            
            %% adjust for unchanged #1 ranked term, if present
            if ((mixedelements(1).ranks(index) == 1) ...
                && ...
                (mixedelements(2).ranks(index) == 1))
                tmpXcoords(ibin) = log10(1.2);
                tmpYcoords(ibin) = log10(1.5);
                tmphalign = 'left';
            end
            
            %% no instrument: alternate dark grey and black
            if (strcmp(settings.instrument,'none'))
                if (rem(ibin,2)==1)
                    %%            tmphrightwords(i).Color = 'k';
                    tmpcolor = 'k';
                else
                    %%            tmphrightwords(i).Color = colors.darkergrey;
                    tmpcolor = colors.darkergrey;
                end
            else
                %% instrument: color by deltas
                tmpfactor = delta/max(deltas_gain);
                tmpcolor = ((1 - tmpfactor)*(1 - deltamin_text_color)) ...
                    * [1 1 1];
            end


            if (~strcmp(settings.turbulencegraph.labels,'off')) 
                %%                deltas_gain
                %%                word
                %%                tmpcolor
                %%                max(deltas_gain)
                tmphrightwords(ibin) = text(tmpXcoords(ibin),tmpYcoords(ibin),...
                                            word,...
                                            'FontName','Arial',...
                                            'fontsize',16,...
                                            'units','data',...
                                            'horizontalalignment',tmphalign,...
                                            'color',tmpcolor); %,...'interpreter','latex'
            end
        end
    end


    %% some labels
    topwordindices = [];
    topleftwordindices = indices_left;
    %% include top word
    if (length(topleftwordindices) > 0)
        topleftN = length(topleftwordindices);
        topwordindices = topleftwordindices(1:min(topleftN,settings.topNhistogram));
    end
        
    %% most extreme:
    indices = find(mixedelements(2).ranks == max(mixedelements(2).ranks));
    [tmp,index] = min(mixedelements(1).ranks(indices));
    extremeindex = indices(index);

    mixedelements(1).types(extremeindex);
    mixedelements(1).ranks(extremeindex);
    mixedelements(2).ranks(extremeindex);

    if (length(topleftwordindices) > 0)
        topleftN = length(topleftwordindices);
        topwordindices = unique([...
            topleftwordindices(1:min(topleftN,settings.topNhistogram))]);
        %%                        extremeindex]);
    end

    %% sort by vertical position
    [tmp, indices] = sort(yrotated(topwordindices),'ascend');
    topwordindices = topwordindices(indices);

    clear tmpleftwords
    clear tmprightwords

    vertratio = 1.25;
    horizratio = 2;


    for i=1:length(topwordindices)
        j = topwordindices(i);
        word = mixedelements(1).types(j);
        if (length(word) > settings.max_shift_string_length)
            word = [word(1:settings.max_shift_string_length-6),...
                    '...',...
                    word(end-2:end),...
                   ];
        end
        tmpword = sprintf('%s',word{1});
        
        tmpXcoords(i) = log10(1.10*mixedelements(2).ranks(j));
        tmpYcoords(i) = log10(0.90*mixedelements(1).ranks(j));

        %% check for overlap with preceding text
        tmpcolor = 'k';
        if (i > 1)
            jprev = topwordindices(i-1);
            if (yrotated(j)/vertratio < ...
                yrotated(jprev))
                tmpcolor = 'k';
            end
        end
        
        %%    tmphleftwords(i) = text(tmpXcoords(i),tmpYcoords(i),...
        %%                            tmpword,...
        %%                            'fontsize',14,...
        %%                            'units','data',...
        %%                            'horizontalalignment','right',...
        %%                            'color',tmpcolor,...
        %%                            'interpreter','latex');
        %%    %%                    'rotation',rand(1)*20-5,...
    end

    %%for prune_index = 1:5
    %%    for i=1:length(tmphleftwords)
    %%        tmppos = tmphleftwords(i).Position;
    %%        tmpxpos(i) = (tmppos(1) - tmppos(2))/sqrt(2);
    %%        tmpypos(i) = (tmppos(1) + tmppos(2))/sqrt(2);
    %%    end
    %%
    %%    %%    ratios = yrotated(topwordindices(2:end))./ ...
    %%    %%             yrotated(topwordindices(1:end-1));
    %%    
    %%    %% hardpush(log10(tmpxpos),log10(tmpypos),.1,10);
    %%
    %%    %% logarithmic differences
    %%    xratios = tmpxpos(2:end)./tmpxpos(1:end-1);
    %%    yratios = tmpypos(2:end)./tmpypos(1:end-1);
    %%    xratios(find(xratios<1)) = xratios(find(xratios<1)).^-1;
    %%    
    %%    shiftratio = 1.05;
    %%    j=1;
    %%    for i=2:length(tmphleftwords)
    %%        if (yratios(i-1) < vertratio)
    %%            if (xratios(i-1) < horizratio)
    %%                tmphleftwords(i).Visible = 'off'; %% too close
    %%                %% move texts out
    %%                %%                tmppos = tmphleftwords(i-1).Position;
    %%                %%                tmphleftwords(i).Position = ...
    %%                %%                    [tmppos(1)*shiftratio, tmppos(2)/shiftratio, 0];
    %%            end
    %%        end
    %%        if (strcmp(tmphleftwords(i).Visible,'on')==1)
    %%            tmphleftwords_new(j) = tmphleftwords(i);
    %%            j=j+1;
    %%        end
    %%    end
    %%    tmphleftwords = tmphleftwords_new;
    %%    clear tmphleftwords_new;
    %%end
    %%
    %%j=0;
    %%for i=1:length(tmphleftwords)
    %%    if (strcmp(tmphleftwords(i).Visible,'on')==1)
    %%        j=j+1;
    %%        if (rem(j,2)==1)
    %%            tmphleftwords(i).Color = 'k';
    %%        else
    %%            tmphleftwords(i).Color = colors.darkergrey;
    %%        end
    %%    end
    %%end

    %%% right side

    toprightwordindices = find(mixedelements(1).probs >= mixedelements(2).probs);

    %% find extra pieces
    %% top:
    topindex = find(strcmp(mixedelements(1).types,'rt'));
    %% most extreme:
    indices = find(mixedelements(1).probs == max(mixedelements(1).probs));
    [tmp,index] = min(mixedelements(2).probs(indices));
    extremeindex = indices(index);

    mixedelements(1).types(extremeindex);
    mixedelements(1).probs(extremeindex);
    mixedelements(2).probs(extremeindex);
    
    topwordindices = unique([topindex; ...
                        toprightwordindices(1:min(length(toprightwordindices),settings.topNhistogram))]);
    %%                        extremeindex]);

    %% sort by vertical position
    [tmp, indices] = sort(yrotated(topwordindices),'ascend');
    topwordindices = topwordindices(indices);

    %%for i=1:length(topwordindices)
    %%    j = topwordindices(i);
    %%    word = mixedelements(1).types(j);
    %%    tmpword = sprintf('%s',word{1});
    %%
    %%    tmpXcoord = 0.90*mixedelements(2).probs(j);
    %%    tmpYcoord = 1.10*mixedelements(1).probs(j);
    %%
    %%    %% check for overlap with preceding text
    %%    tmpcolor = 'k';
    %%    if (i > 1)
    %%        jprev = topwordindices(i-1);
    %%        if (yrotated(j)/1.3 < ...
    %%            yrotated(jprev))
    %%            tmpcolor = 'k';
    %%        end
    %%    end
    %%
    %%    tmphrightwords(i) = text(tmpXcoord,tmpYcoord,...
    %%                             tmpword,...
    %%                             'fontsize',14,...
    %%                             'units','data',...
    %%                             'horizontalalignment','left',...
    %%                             'color',tmpcolor,...
    %%                             'interpreter','latex');
    %%    %%                    'rotation',rand(1)*20-5,...
    %%end
    %%
    %%%%    tmphrightwords = tmphrightwords(1:end-1);
    %%for prune_index = 1:5
    %%    for i=1:length(tmphrightwords)
    %%        tmppos = tmphrightwords(i).Position;
    %%        tmpxpos(i) = (tmppos(1) - tmppos(2))/sqrt(2);
    %%        tmpypos(i) = (tmppos(1) + tmppos(2))/sqrt(2);
    %%    end
    %%
    %%    %%    ratios = yrotated(topwordindices(2:end))./ ...
    %%    %%             yrotated(topwordindices(1:end-1));
    %%    
    %%    %% hardpush(log10(tmpxpos),log10(tmpypos),.1,10);
    %%
    %%    %% logarithmic differences
    %%    xratios = tmpxpos(2:end)./tmpxpos(1:end-1);
    %%    yratios = tmpypos(2:end)./tmpypos(1:end-1);
    %%    xratios(find(xratios<1)) = xratios(find(xratios<1)).^-1;
    %%    
    %%    shiftratio = 1.05;
    %%    j=1;
    %%    for i=2:length(tmphrightwords)
    %%        if (yratios(i-1) < vertratio)
    %%            if (xratios(i-1) < horizratio)
    %%                tmphrightwords(i).Visible = 'off'; %% too close
    %%                %% move texts out
    %%                %%                tmppos = tmphrightwords(i-1).Position;
    %%                %%                tmphrightwords(i).Position = ...
    %%                %%                    [tmppos(1)*shiftratio, tmppos(2)/shiftratio, 0];
    %%            end
    %%        end
    %%        if (strcmp(tmphrightwords(i).Visible,'on')==1)
    %%            tmphrightwords_new(j) = tmphrightwords(i);
    %%            j=j+1;
    %%        end
    %%    end
    %%    tmphrightwords = tmphrightwords_new;
    %%    clear tmphrightwords_new;
    %%end
    %%
    %%j=0;
    %%for i=1:length(tmphrightwords)
    %%    if (strcmp(tmphrightwords(i).Visible,'on')==1)
    %%        j=j+1;
    %%        if (rem(j,2)==1)
    %%            tmphrightwords(i).Color = 'k';
    %%        else
    %%            tmphrightwords(i).Color = colors.darkergrey;
    %%        end
    %%    end
    %%end





    %%%%%%%%%%%%%%%%%%%%
    %% axis labels
    %%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%
    %% left, system 1
    %%%%%%%%%%%%%%%%%%%%

    clear tmpstrless;
    if (isfield(settings,'less_string'))
        for k = 2:length(settings.less_string)
            tmpstrless{k} = settings.less_string{k};
        end
        tmpstrless{1} = ...
            sprintf('\\ \\ \\ \\ %s $\\rightarrow$',...
                    settings.less_string{1});
    else
        tmpstrless{1} = 'less';
        tmpstrless{2} = '\ \ \ \ talked $\rightarrow$';
        tmpstrless{3} = 'about';
    end


    clear tmpstrmore;
    %%    tmpstrmore{1} = 'more talked about $\rightarrow$';
    if (isfield(settings,'more_string'))
        for k = 2:length(settings.more_string)
            tmpstrmore{k} = settings.more_string{k};
        end
        tmpstrmore{1} = ...
            sprintf('$\\leftarrow$ %s\\ \\ \\ \\ ',...
                    settings.more_string{1});
    else
        tmpstrmore{1} = 'more';
        tmpstrmore{2} = '$\leftarrow$ talked\ \ \ \ ';
        tmpstrmore{3} = 'about';
    end
    

    tmpXcoord = 0.32;
    tmpYcoord = 0.00;
    %%    tmpXcoord = 0.34;
    %%    tmpYcoord = -0.02;

    if (~strcmp(settings.turbulencegraph.labels,'off')) 
        text(tmpXcoord,tmpYcoord,tmpstrless,...
            'FontName','Arial',...
             'fontsize',18,...
             'units','normalized',...
             'color',colors.darkgrey,...
             'horizontalalignment','center',...
             'rotation',-45,... 
              'interpreter','latex') %
    end
    
    %%     'verticalalignment','middle',...

    tmpXcoord = 0.005;
    tmpYcoord = 0.32;
    if (~strcmp(settings.turbulencegraph.labels,'off')) 
        text(tmpXcoord,tmpYcoord,tmpstrmore,...
            'FontName','Arial',...
             'fontsize',18,...
             'units','normalized',...
             'color',colors.darkgrey,...
             'horizontalalignment','center',...
             'rotation',-45,...
             'interpreter','latex')
    end
    
    %%     'verticalalignment','middle',...

    if(isfield(settings,'axislabel_top1'))
        tmpxlabstr{1} = settings.axislabel_top1;
        tmpxlabstr{2} = 'for';
    else
        tmpxlabstr = {'Rank $r$','for'};
    end
    
    tmpxlabstr{end+1} = sprintf('%s',settings.system1_name_short);

%%     if (iscell(settings.system1_name))
%%         for iname=1:length(settings.system1_name)
%%             tmpxlabstr{end+1} = sprintf('%s', ...
%%                                         settings.system1_name{iname});
%%         end
%%     else 
%%         tmpxlabstr{end+1} = sprintf('%s',settings.system1_name);
%%     end
    
    
        
    tmpXcoord = 0.16;
    tmpYcoord = 0.16;
    
    if (~strcmp(settings.turbulencegraph.labels,'off')) 
        tmph = text(tmpXcoord,tmpYcoord,tmpxlabstr,...
                    'FontName','Arial',...
                    'fontsize',18,...
                    'units','normalized',...
                    'horizontalalignment','center',...
                    'rotation',-45,...
                    'interpreter','latex');
    end

    %% tmpxlab=xlabel(tmpxlabstr,...
    %%     'fontsize',16,...
    %%     'verticalalignment','top',...
    %%     'interpreter','latex');


    %%%%%%%%%%%%%%%%%%%%
    %% right, system 2
    %%%%%%%%%%%%%%%%%%%%

    clear tmpstrless;
    if (isfield(settings,'less_string'))
        for k = 2:length(settings.less_string)
            tmpstrless{k} = settings.less_string{k};
        end
        tmpstrless{1} = ... 
            sprintf('$\\leftarrow$ %s\\ \\ \\ \\ ',...
                    settings.less_string{1});
    else
        tmpstrless{1} = 'less';
        tmpstrless{2} = '$\leftarrow$ talked\ \ \ \ ';
        tmpstrless{3} = 'about';
    end


    clear tmpstrmore;
    %%    tmpstrmore{1} = 'more talked about $\rightarrow$';
    if (isfield(settings,'more_string'))
        for k = 2:length(settings.more_string)
            tmpstrmore{k} = settings.more_string{k};
        end
        tmpstrmore{1} = ...
            sprintf('\\ \\ \\ \\ %s $\\rightarrow$',...
                    settings.more_string{1});
    else
        tmpstrmore{1} = 'more';
        tmpstrmore{2} = '\ \ \ \ talked $\rightarrow$';
        tmpstrmore{3} = 'about';
    end
    
    

    %%    tmpXcoord = 0.66;
    %%    tmpYcoord = -0.01;
    tmpXcoord = 0.68;
    tmpYcoord = 0.01;
    if (~strcmp(settings.turbulencegraph.labels,'off')) 
        text(tmpXcoord,tmpYcoord,tmpstrless,...
            'FontName','Arial',...
             'fontsize',18,...
             'units','normalized',...
             'color',colors.darkgrey,...
             'horizontalalignment','center',...
             'rotation',45,...
             'interpreter','latex')
    end
    
    %%     'verticalalignment','middle',...

    tmpXcoord = 0.99;
    tmpYcoord = 0.31;
    
    if (~strcmp(settings.turbulencegraph.labels,'off')) 
        text(tmpXcoord,tmpYcoord,tmpstrmore,...
            'FontName','Arial',...
             'fontsize',18,...
             'units','normalized',...
             'color',colors.darkgrey,...
             'horizontalalignment','center',...
             'rotation',45,...
             'interpreter','latex')
    end
    if (isfield(settings,'axislabel_top2'))
        tmpylabstr{1} = settings.axislabel_top2;
        tmpylabstr{2} = 'for';
    else
        tmpylabstr = {'Rank $r$','for'};
    end

    tmpylabstr{end+1} = sprintf('%s',settings.system2_name_short);

%%     if (iscell(settings.system2_name))
%%         for iname=1:length(settings.system2_name)
%%             tmpylabstr{end+1} = sprintf('%s', ...
%%                                         settings.system2_name{iname});
%%         end
%%     else 
%%         tmpylabstr{end+1} = sprintf('%s',settings.system2_name);
%%     end

    %% tmpylab=ylabel(tmpylabstr,...
    %%     'fontsize',16,...
    %%     'verticalalignment','bottom',...
    %%     'interpreter','latex');

    tmpXcoord = 0.84;
    tmpYcoord = 0.16;
    
    if (~strcmp(settings.turbulencegraph.labels,'off')) 
        tmph = text(tmpXcoord,tmpYcoord,tmpylabstr,...
                    'FontName','Arial',...
                    'fontsize',18,...
                    'units','normalized',...
                    'horizontalalignment','center',...
                    'rotation',45,...
                    'interpreter','latex');
    end

    %%%%%%%%%%%%
    %% title

    %% tmpstr = 'Rank comparison plot';
    %% 
    %% tmpXcoord = 0.00;
    %% tmpYcoord = 1.00;
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%             'fontsize',18,...
    %%             'units','normalized',...
    %%             'horizontalalignment','left',...
    %%             'verticalalignment','top',...
    %%             'rotation',0,...
    %%             'interpreter','latex');


    %% set(tmpxlab,'position',get(tmpxlab,'position') - [0 .1 0]);
    %% set(tmpylab,'position',get(tmpylab,'position') - [.1 0 0]);

    %% set 'units' to 'data' for placement based on data points
    %% set 'units' to 'normalized' for relative placement within axes
    %% tmpXcoord = ;
    %% tmpYcoord = ;
    %% tmpstr = sprintf(' ');
    %% or
    %% tmpstr{1} = sprintf(' ');
    %% tmpstr{2} = sprintf(' ');
    %%
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%     'fontsize',20,...
    %%     'units','normalized',...
    %%     'interpreter','latex')

    %% label (A, B, ...)
    %% tmplabelh = addlabel4(' A ',0.02,0.9,20);
    %% tmplabelh = addlabel5(loop_i,0.02,0.9,20);
    %% or:
    %% tmplabelXcoord= 0.015;
    %% tmplabelYcoord= 0.88;
    %% tmplabelbgcolor = 0.85;
    %% tmph = text(tmplabelXcoord,tmplabelYcoord,...
    %%    ' A ',...
    %%    'fontsize',24,
    %%         'units','normalized');
    %%    set(tmph,'backgroundcolor',tmplabelbgcolor*[1 1 1]);
    %%    set(tmph,'edgecolor',[0 0 0]);
    %%    set(tmph,'linestyle','-');
    %%    set(tmph,'linewidth',1);
    %%    set(tmph,'margin',1);

    %% rarely used (text command is better)
    %% title(' ','fontsize',24,'interpreter','latex')
    %% 'horizontalalignment','left');
    %% tmpxl = xlabel('','fontsize',24,'verticalalignment','top');
    %% set(tmpxl,'position',get(tmpxl,'position') - [ 0 .1 0]);
    %% tmpyl = ylabel('','fontsize',24,'verticalalignment','bottom');
    %% set(tmpyl,'position',get(tmpyl,'position') - [ 0.1 0 0]);
    %% title('','fontsize',24)



    if (~strcmp(settings.instrument,'none'))

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLOT for Rank version: alpha linear gauge
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        axesnum = 7;
        tmpaxes_gauge = axes('position',axes_positions(axesnum).box);
                
        
        %% create slider
        
        tmpx = linspace(0,pi/2,100);
        tmpy = ones(size(tmpx));
                
        tmph = plot(tmpx,tmpy,'-');
        
        set(tmph,'color',colors.darkgrey);
        set(tmph,'linewidth',1);

        hold on;
        
        alphavals = [0, 1/4, 2/4, 3/4, 1, 3/2, 2, 3, 5, Inf];
        tickmarks = atan(alphavals)/(pi/2);
        
%%         alphavalstrs = {'0',...
%%                         '$\frac{1}{4}$',...
%%                         '$\frac{1}{2}$',...
%%                         '$\frac{3}{4}$',...
%%                         '1',...
%%                         '$\frac{3}{2}$',...
%%                         '2',...
%%                         '3',...
%%                         '5',...
%%                         '$\infty$'};

        alphavalstrs = {'0',...
                        '1/4',...
                        '1/2',...
                        '3/4',...
                        '1',...
                        '3/2',...
                        '2',...
                        '3',...
                        '5',...
                        '$\infty$'};
        
        
        tmpy = linspace(.5,1.5,10);
        for i=1:length(tickmarks)
            tmpx = tickmarks(i)*ones(size(tmpy));
            tmph = plot(tmpx,tmpy,'-');
            set(tmph,'color',colors.darkgrey);
            set(tmph,'linewidth',1);
        
            tmpstr = sprintf('%s',alphavalstrs{i});
            tmpXcoord = tickmarks(i);
            tmpYcoord = -0.3;
            if (~strcmp(settings.turbulencegraph.labels,'off')) 
                tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                            'FontName','Arial',...
                            'fontsize',12,...
                            'units','data',...
                            'horizontalalignment','center',...
                            'verticalalignment','middle',...
                            'rotation',0,...
                            'interpreter','latex');
            end
        end
        
        xlim([0 1]);
        ylim([0 2]);
        
        tmpaxes_gauge.XAxis.Visible = 'off';
        tmpaxes_gauge.YAxis.Visible = 'off';
        
        %% add alpha setting indicator
        
        tmpx = atan(settings.alpha)/(pi/2);
        tmpy = 2;
        tmph = plot(tmpx,tmpy,'v');
        set(tmph,'markersize',8);
        set(tmph,'markerfacecolor',colors.verydarkgrey);
        set(tmph,'markeredgecolor',colors.verydarkgrey);

        tmpstr = sprintf('$\\alpha$=$%s$',alpha_str);
        tmpXcoord = atan(settings.alpha)/(pi/2) - 0.03;
        tmpYcoord = 4.2;

        if (~strcmp(settings.turbulencegraph.labels,'off')) 
            tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                        'FontName','Arial',...
                        'fontsize',14,...
                        'units','data',...
                        'horizontalalignment','left',...
                        'verticalalignment','top',...
                        'rotation',0,...
                        'interpreter','latex');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLOT for Rank version: inset showing lines of constant divergence
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%
        %% set up background
        %%%%%%%%%%%%%%%%%%%%%

        axesnum = 4;
        tmpaxes_inset_lines = axes('position',axes_positions(axesnum).box);

        bg_alpha = 0.75;

        x_triangle = [0, maxlog10,  maxlog10, 0];
        y_triangle = [0, maxlog10,  0, 0];
        tmph = fill(x_triangle,y_triangle,colors.lightgrey);
        set(tmph,'edgecolor',colors.lightgrey);
        set(tmph,'facealpha',bg_alpha);
        set(tmph,'edgealpha',bg_alpha);

        hold on;

        x_triangle = [0, maxlog10,  0, 0];
        y_triangle = [0, maxlog10,  maxlog10, 0];
        tmph = fill(x_triangle,y_triangle,colors.paleblue);
        set(tmph,'edgecolor',colors.paleblue);
        set(tmph,'facealpha',bg_alpha);
        set(tmph,'edgealpha',bg_alpha);

        hold on;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% rotate to left-right view

        view(135,90);

        hold on;

        %% set(gca,'xtick',[]);
        %% set(gca,'ytick',[]);
        set(gca,'color','none');

        xlim([0 maxlog10]);
        ylim([0 maxlog10]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add center line

        transparency_alpha = 0.75;
        transparency_alpha_alt = 0.05;

        tmpr1 = logspace(0,maxlog10,100);
        tmph = plot(log10(tmpr1),log10(tmpr1),'-');

        hold on;

        %% grid on;

        set(tmph,'color','k');
        set(tmph,'linewidth',0.50);
        tmph.Color(4) = transparency_alpha;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add lines of constant divergence:

        %% use a contour plot (data from above)

        tmpr1 = col(logspace(0,maxlog10,1000));
        tmpr2 = col(logspace(0,maxlog10,1000));
        
        %% 
        %% 
        %%     tmpcontours = contourc(log10(tmpr1),...
        %%                            log10(tmpr2),...
        %%                            log10(deltamatrix),...
        %%                            Ncontours);
        %% 
        %%     %% extract contours
        %%     i=1;
        %%     while(size(tmpcontours,2) > 0)
        %%         Npairs = tmpcontours(2,1);
        %%         contours(i).x1 = tmpcontours(1,2:Npairs+1);
        %%         contours(i).x2 = tmpcontours(2,2:Npairs+1);
        %%         tmpcontours = tmpcontours(:,Npairs+2:end);
        %%         i=i+1;
        %%     end

        %% plot contours
        for i=1:length(contours)
            tmph = plot(contours(i).x1,contours(i).x2);
            set(tmph,'color','k');
            tmph.Color(4) = transparency_alpha;
            set(tmph,'linewidth',0.25);
            hold on;
            
            %%    tmph = plot(contours(i).x1(end),contours(i).x2(end),'ro');

        end

        %% fix up ticks

        tmpr_edge =  10.^(get(gca,'xtick'));

        %% remove last tick (should be 0):
        tmpr_edge =  tmpr_edge(1:end);
        set(gca,'xtick',log10(tmpr_edge));
        set(gca,'ytick',log10(tmpr_edge));
        set(gca,'FontName','Arial');
        %% find index in matrix
        for i=1:length(tmpr_edge)
            index = max(find(tmpr_edge(i)>=tmpr1));
            delta_edge(i) = delta_edge_full(index);
        end
        
        %%        delta_edge = alpha_norm_type2(tmpr_edge.^-1,tmpr1(end).^-1, ...
        %%                                      settings.alpha);
        %%        tmpr_edge
        %%        deltamatrix([1 100 1000],end)
        %%         error(' wef')

        %% [delta_edge,normalization_edge] = rank_turbulence_divergence(mixedelements,settings.alpha);        
        
        for i=1:length(delta_edge)
            delta_edge_str{i} = latex_good_number(delta_edge(i));
            %% tmpstr = sprintf('%f',round(delta_edge(i),3,'significant'));
            %%            tmpstr = sprintf('%f',round(delta_edge(i),3,'significant'));
            %%            %% hack:
            %%            while(strcmp('0',tmpstr(end)))
            %%                tmpstr = tmpstr(1:end-1);
            %%            end
            %%            if(strcmp('.',tmpstr(end)))
            %%                tmpstr = tmpstr(1:end-1);
            %%            end
        end

        set(gca,'xticklabel',delta_edge_str);
        set(gca,'yticklabel',delta_edge_str);
        set(gca,'xcolor',colors.darkgrey);
        set(gca,'ycolor',colors.darkgrey);
        set(gca,'FontName','Arial');
        %% set(gca,'xticklabel',delta_edge);
        %% set(gca,'yticklabel',delta_edge);

        %% clear tmpxticklabels;
        %% for i=1:length(deltavals)
        %%     tmpxticklabels{i} = sprintf('$10^{%d}$',floor(log10(deltavals(i))));
        %% end
        tmpaxes_inset_lines.TickLabelInterpreter='latex';

        %% set(gca,'xtick',log10(rvals));
        %% set(gca,'xticklabel',tmpxticklabels);
        %% set(gca,'ytick',log10(rvals));
        %% set(gca,'yticklabel',tmpxticklabels);


        %% ticks
        %% clear tmpxticklabels;
        %% for i=1:length(deltavals)
        %%     tmpxticklabels{i} = sprintf('$10^{%d}$',floor(log10(deltavals(i))));
        %% end
        %% tmpaxes_inset_lines.TickLabelInterpreter='latex';

        %%        tmpr1(end)

        %% set(gca,'xtick',log10(rvals));
        %% set(gca,'xticklabel',tmpxticklabels);
        %% set(gca,'ytick',log10(rvals));
        %% set(gca,'yticklabel',tmpxticklabels);


        %% add zero for center line
%%         tmpstr = '0';
%%         tmpXcoord = 0.50;
%%         tmpYcoord = -0.10;
%%         tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
%%                     'fontsize',12,...
%%                     'units','normalized',...
%%                     'horizontalalignment','center',...
%%                     'verticalalignment','middle',...
%%                     'rotation',0,...
%%                     'interpreter','latex');

        %% title
        clear tmpstr;
        tmpstr{1} = 'Lines of';
        tmpstr{2} = 'Constant';
        tmpstr{3} = sprintf('$\\delta D_{%s,\\tau}^{\\rm %s}$', ...
                            alpha_str, ...
                            divergence_superscript_str);

        
        tmpXcoord = 0.50;
        tmpYcoord = 1.05;
        tmpYcoord = 0.50;
        tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                    'FontName','Arial',...
                    'fontsize',16,...
                    'units','normalized',...
                    'horizontalalignment','center',...
                    'verticalalignment','middle',...
                    'rotation',0,...
                    'color',colors.darkergrey,...
                    'interpreter','latex');

        set(gca,'fontsize',12);
        set(gca,'FontName','Arial');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% rotate to left-right view

    view(135,90);

elseif (strcmp(settings.plotkind,'probability'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: probability version
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% potential details for histogram

    %% overall number of types
    details.N = length(mixedelements(1).types);
    details.Nshared = sum((mixedelements(1).counts > 0) & ...
                          (mixedelements(2).counts > 0));

    %% number of types in each system
    details.N1 = sum(mixedelements(1).counts > 0);
    details.N2 = sum(mixedelements(2).counts > 0);
    
    %% number of types exclusive to each system
    details.N1exclusive = sum(mixedelements(2).counts == 0);
    details.N2exclusive = sum(mixedelements(1).counts == 0);

    %% total counts in each system (generalize to sizes)
    %% more generally: total weight
    details.totalcounts1 = sum(mixedelements(1).counts);
    details.totalcounts2 = sum(mixedelements(2).counts);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% zipf comparison diamond plot for probabilies
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %% deal with 0 probabilities
    maxprob1 = max(mixedelements(1).probs);
    maxprob2 = max(mixedelements(2).probs);

    %% true min
    minprob1 = min(mixedelements(1).probs);
    minprob2 = min(mixedelements(2).probs);
    
    %% copy probs for modification when 0s are present (expected)
    mixedelements(1).probs_mod = mixedelements(1).probs;
    mixedelements(2).probs_mod = mixedelements(2).probs;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% indicators for zeros and non-zeros
    zeros1 = (mixedelements(1).probs_mod == 0);
    zeros2 = (mixedelements(2).probs_mod == 0);
    zeros1_indices = find(zeros1);
    zeros2_indices = find(zeros2);

    nonzeros1 = (mixedelements(1).probs_mod > 0);
    nonzeros2 = (mixedelements(2).probs_mod > 0);
    nonzeros1_indices = find(nonzeros1);
    nonzeros2_indices = find(nonzeros2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% minimum non-zero probs
    minprob1_nonzero = min(mixedelements(1).probs_mod(nonzeros1_indices));
    minprob2_nonzero = min(mixedelements(2).probs_mod(nonzeros2_indices));

    minlog10_nonzero = log10(min([minprob1_nonzero,minprob2_nonzero]));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% naughty: modify probs so 0s will plot well

    %% put 0s at min2zero_factor x lowest non-zero probabiltiy
    if (~isfield(settings,'min2zero_offset'))
        min2zero_offset = 0.75; %% log scale
    else
        min2zero_offset = settings.min2zero_offset;
    end
    zero2axis_offset = min2zero_offset;
    %% zero2axis_offset = 0.75;
    
    zero1log10 = (log10(minprob1_nonzero)) - min2zero_offset;
    zero2log10 = (log10(minprob2_nonzero)) - min2zero_offset;
    zerolog10 = min([zero1log10 zero2log10]);

    mixedelements(1).probs_mod(zeros1_indices) = 10^zerolog10;
    mixedelements(2).probs_mod(zeros2_indices) = 10^zerolog10;
    
    %% range for probabilities (log10)
    %% minlog10:maxlog10

    minlog10 = -zero2axis_offset + (log10(min([min(mixedelements(1).probs_mod),min(mixedelements(2).probs_mod)])));
    maxlog10 = ceil(log10(max([max(mixedelements(1).probs_mod),max(mixedelements(2).probs_mod)])));

    %% compute rotated coordinates for each type:

    xrotated = 1/sqrt(2) * (log10(mixedelements(2).probs_mod) - log10(mixedelements(1).probs_mod));
    yrotated = 1/sqrt(2) * (log10(mixedelements(2).probs_mod) + log10(mixedelements(1).probs_mod));

    %%%%%%%%%%%%%%%%%%%%%
    %% set up background
    %%%%%%%%%%%%%%%%%%%%%

    axesnum = 1;
    tmpaxes_bg = axes('position',axes_positions(axesnum).box);

    bg_alpha = 0.95;
    bg_alpha_alt = 0.50;

    %% triangles

    %% left
%%    x_triangle = [minlog10 + zero2axis_offset, ...
%%                  maxlog10, ...
%%                  minlog10 + zero2axis_offset, ...
%%                  minlog10 + zero2axis_offset];
%%    y_triangle = [minlog10 + zero2axis_offset, ...
%%                  maxlog10, ...
%%                  maxlog10, ...
%%                  minlog10 + zero2axis_offset];

    x_triangle = [minlog10_nonzero, ...
                  maxlog10, ...
                  minlog10_nonzero, ...
                  minlog10_nonzero];
    y_triangle = [minlog10_nonzero, ...
                  maxlog10, ...
                  maxlog10, ...
                  minlog10_nonzero];

    tmph = fill(x_triangle,y_triangle,colors.lightgrey);

    set(tmph,'edgecolor',colors.lightgrey);
    set(tmph,'facealpha',bg_alpha);
    set(tmph,'edgealpha',bg_alpha);

    hold on;
    
    %% right
%%    x_triangle = [minlog10 + zero2axis_offset, ...
%%                  maxlog10, ...
%%                  maxlog10, ...
%%                  minlog10 + zero2axis_offset];
%%    y_triangle = [minlog10 + zero2axis_offset, ...
%%                  maxlog10, ...
%%                  minlog10 + zero2axis_offset, ...
%%                  minlog10 + zero2axis_offset];

    x_triangle = [minlog10_nonzero, ...
                  maxlog10, ...
                  maxlog10, ...
                  minlog10_nonzero];
    y_triangle = [minlog10_nonzero, ...
                  maxlog10, ...
                  minlog10_nonzero, ...
                  minlog10_nonzero];

    tmph = fill(x_triangle,y_triangle,colors.paleblue);

    set(tmph,'edgecolor',colors.paleblue);
    set(tmph,'facealpha',bg_alpha);
    set(tmph,'edgealpha',bg_alpha);

    hold on;

    %% pentangles surrounding zero probability line

    %% left
    %%                   minlog10 + zero2axis_offset, ...
    x_pentangle = [minlog10, ...
                   minlog10, ...
                   minlog10_nonzero, ...
                   minlog10_nonzero, ...
                   zerolog10];
    %%                   minlog10 + zero2axis_offset, ...
    y_pentangle = [zerolog10, ...
                   maxlog10, ...
                   maxlog10, ...
                   minlog10_nonzero, ...
                   zerolog10];

    tmph = fill(x_pentangle,y_pentangle,colors.lightgrey);
    set(tmph,'edgecolor',colors.lightgrey);
    set(tmph,'facealpha',bg_alpha_alt);
    set(tmph,'edgealpha',bg_alpha_alt);

    hold on;
    
    %% right
    x_pentangle = [zerolog10, ...
                   maxlog10, ...
                   maxlog10, ...
                   minlog10_nonzero, ...
                   zerolog10];
    y_pentangle = [minlog10, ...
                   minlog10, ...
                   minlog10_nonzero, ...
                   minlog10_nonzero, ...
                   zerolog10];
    
    tmph = fill(x_pentangle,y_pentangle,colors.paleblue);
    set(tmph,'edgecolor',colors.paleblue);
    set(tmph,'facealpha',bg_alpha_alt);
    set(tmph,'edgealpha',bg_alpha_alt);

    hold on;

    %% remove ticks

    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'color','none');
    set(gca,'FontName','Arial');
    xlim([minlog10 maxlog10]);
    ylim([minlog10 maxlog10]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% rotate to left-right view

    view(-45,90);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% main diamond plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    axesnum = 1;
    tmpaxes(axesnum) = axes('position',axes_positions(axesnum).box);


    %% gel preparation

    indices_left = find(mixedelements(1).probs_mod > mixedelements(2).probs_mod);
    indices_right = find(mixedelements(1).probs_mod < mixedelements(2).probs_mod);
    indices_middle = find(mixedelements(1).probs_mod == ...
                          mixedelements(2).probs_mod);

    %% only plot points once:
    [unique_probs,unique_indices,expander_indices] = ...
        unique([log10(mixedelements(1).probs_mod),log10(mixedelements(2).probs_mod)],...
               'rows');

    [pointcounts,pointindices] = hist(expander_indices,1:max(expander_indices));

    indices_left_unique = unique_indices(find(mixedelements(1).probs_mod(unique_indices) > mixedelements(2).probs_mod(unique_indices)));
    indices_right_unique = unique_indices(find(mixedelements(1).probs_mod(unique_indices) < mixedelements(2).probs_mod(unique_indices)));
    indices_middle_unique = unique_indices(find(mixedelements(1).probs_mod(unique_indices) == ...
                                                mixedelements(2).probs_mod(unique_indices)));


    [tmp,tmpindices] = sort(mixedelements(1).probs_mod(indices_middle),'ascend');
    indices_middle = indices_middle(tmpindices);

    %% background of diamonds

    Ncells = floor((maxlog10-minlog10)/cell_length) + 1;

    x1_centervals = -cell_length + ones(Ncells,1)*[maxlog10:-cell_length:minlog10];
    x2_centervals = x1_centervals';

    x1_indices = ceil((maxlog10 - log10(mixedelements(1).probs_mod))/cell_length);
    x2_indices = ceil((maxlog10 - log10(mixedelements(2).probs_mod))/cell_length);

    x1_indices(find(x1_indices<1)) = 1;
    x1_indices(find(x1_indices>Ncells)) = Ncells;
    x2_indices(find(x2_indices<1)) = 1;
    x2_indices(find(x2_indices>Ncells)) = Ncells;
    
    counts = zeros(Ncells,Ncells);
    for i=1:length(mixedelements(1).probs_mod)
        counts(x1_indices(i),x2_indices(i)) = ...
            counts(x1_indices(i),x2_indices(i)) + 1;
    end
    
    maxcounts = max(counts(:));
    if(isfield(settings,'maxcount_log10'))
        maxcountslog10 = ceil(settings.maxcount_log10);
        %% catch
        if (maxcountslog10 < 1)
            maxcountslog10 = 1;
        end
    else %% based on data
        maxcounts = max(counts(:));
        %% round up
        maxcountslog10 = ceil(log10(maxcounts));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add lines to block off zero probability lines

    transparency_alpha = 0.75;
    transparency_alpha_alt = 0.05;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%    tmpx = linspace(minlog10 + 1 - min2zero_offset,maxlog10,100);
    %%    tmpy = (minlog10 + 1 - min2zero_offset)*ones(size(tmpx));

    tmpx = linspace(minlog10,maxlog10,100);
    tmpy = (zerolog10)*ones(size(tmpx));
    
    tmph = plot(tmpx,tmpy,':');
    hold on;
    
    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%    tmpy = linspace(minlog10 + 1 - min2zero_offset,maxlog10,100);
    %%    tmpx = (minlog10 + 1 - min2zero_offset)*ones(size(tmpx));

    tmpy = linspace(minlog10,maxlog10,100);
    tmpx = (zerolog10)*ones(size(tmpx));

    tmph = plot(tmpx,tmpy,':');
    hold on;

    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%    tmpx = linspace(minlog10 + 1,maxlog10,100);
    %%    tmpy = (minlog10 + 1)*ones(size(tmpx));
    tmpx = linspace(log10(minprob1_nonzero),maxlog10,100);
    %%    tmpy = (log10(minprob1_nonzero) - cell_length/sqrt(2))*ones(size(tmpx));
    tmpy = log10(minprob1_nonzero)*ones(size(tmpx));
    
    tmph = plot(tmpx,tmpy,'-');
    hold on;
    
    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%    tmpy = linspace(minlog10 + 1,maxlog10,100);
    %%    tmpx = (minlog10 + 1)*ones(size(tmpx));
    tmpy = linspace(log10(minprob1_nonzero),maxlog10,100);
    tmpx = log10(minprob1_nonzero)*ones(size(tmpy));

    tmph = plot(tmpx,tmpy,'-');
    hold on;

    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% set up centers
    
    for i=1:Ncells
        for j=1:Ncells
            tmpx = [x1_centervals(i,j) - 0*cell_length/2 + 0;
                    x1_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x1_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x1_centervals(i,j) - 0*cell_length/2 + 0];
            tmpy = [x2_centervals(i,j) - 0*cell_length/2 + 0;
                    x2_centervals(i,j) - 0*cell_length/2 + 0;
                    x2_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x2_centervals(i,j) - 0*cell_length/2 + cell_length];
            
            %% add histogram box if one ore more pairs of ranks are
            %% present
            %% else: add strength of divergence for middle of that box
            if (counts(i,j) > 0)

                factor = 0.0 + 1*(1 - log10(counts(i,j))/maxcountslog10);
                %%            factor = 1 - (0.02 + 0.98*(1 - log10(counts(i,j))/maxcountslog10));

                %%            set(tmph,'edgecolor',colors.blue);

                %%            tmpcolors = parula(10^4);

                %%            tmpcolors = inferno(10^4);
                %% tmpcolors = plasma(10^4);
                
                colorindex = ceil(factor*(10^4-1));
                if (colorindex == 0)
                    colorindex = 1;
                end
                if (colorindex > 10^4)
                    colorindex = 10^4;
                end

                tmph = fill(tmpx,tmpy,heatmapcolors(colorindex,:));
                set(tmph,'edgecolor',.7*heatmapcolors(colorindex,:));

                %%            tmph = fill(tmpx,tmpy,factor*[1 1 1]);
                %%            set(tmph,'edgecolor',.7*factor*[1 1 1]);
                
                set(tmph,'linewidth',.5);

                %% set(tmph,'facealpha',factor);
                %%            set(tmph,'edgealpha',factor);
                
                hold on;

                %%         else
                %%             factor = 0.9;
                %%             tmph = fill(tmpx,tmpy,factor*[1 1 .8]);
                %%             set(tmph,'edgecolor',.9*factor*[1 1 .8]);
                %%             
                %%             hold on;
            end
        end
    end

    %% set(gca,'clipping','off')


    %% logrankvals = [0:cell_length:maxlog10-cell_length];
    %% for i=1:length(logrankvals)
    %%     tmpx = [logrankvals(i) + 0;
    %%             logrankvals(i) + cell_length;
    %%             logrankvals(i) + cell_length;
    %%             logrankvals(i) + 0];
    %%     for j=1:length(logrankvals)
    %%         tmpy = [logrankvals(j) + 0;
    %%                 logrankvals(j) + 0;
    %%                 logrankvals(j) + cell_length;
    %%                 logrankvals(j) + cell_length];
    %%         
    %%         if (rand(1) < 0.3)
    %%             if (abs(i-j) < .01*(i+j)^2)
    %%                 factor = 1 - (i+j)/(10*length(logrankvals));
    %%                 tmph = fill(tmpx,tmpy,factor*[1 1 1]);
    %%                 set(tmph,'edgecolor',.9*factor*[1 1 1]);
    %%                 
    %%                 hold on;
    %%             end
    %%         end
    %%     end
    %% end



    %% indices_left = intersect(indices_left,topdownindices);
    %% indices_right = intersect(indices_right,topdownindices);

    %% %% left side, gel:
    %% 
    %% %% ordering is confusing but this works:
    %% tmph = loglog(mixedelements(2).probs_mod(indices_left_unique),...
    %%                  mixedelements(1).probs_mod(indices_left_unique),...
    %%                  'o');
    %% 
    %%    hold on;
    %% indices_left_unique
    
    %% 
    %% %% whos *unique*
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% hold on;
    %% 

    grid on;
    grid minor;

    %% 
    %% %% right side, gel:
    %% 
    %% tmph = loglog(mixedelements(2).probs_mod(indices_right_unique),...
    %%               mixedelements(1).probs_mod(indices_right_unique),...
    %%               'o');
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% %% middle side, gel:
    %% 
    %% tmph = loglog(mixedelements(2).probs_mod(indices_middle_unique),...
    %%              mixedelements(1).probs_mod(indices_middle_unique),...
    %%              'o');
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% hold on;



    %% left side, points:

    pointsize = 1;

    %% tmph = plot(log10(mixedelements(2).probs_mod(indices_left_unique)),...
    %%               log10(mixedelements(1).probs_mod(indices_left_unique)),...
    %%               'o');
    %% set(tmph,'markerfacecolor',colors.blue);
    %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markersize',pointsize);

    hold on;

    %% right side, points:

    %% tmph = plot(log10(mixedelements(2).probs_mod(indices_right_unique)),...
    %%               log10(mixedelements(1).probs_mod(indices_right_unique)),...
    %%               'o');
    %% set(tmph,'markerfacecolor',colors.blue);
    %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markersize',pointsize);
    %% 
    %% hold on;

    %% middle, points:

    %% tmph = plot(log10(mixedelements(2).probs_mod(indices_middle_unique)),...
    %%               log10(mixedelements(1).probs_mod(indices_middle_unique)),...
    %%               'o');
    %% %% set(tmph,'markerfacecolor',colors.blue);
    %% %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markerfacecolor','k');
    %% set(tmph,'markeredgecolor','k');
    %% set(tmph,'markersize',pointsize);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add center line

    tmpprob1 = logspace(minlog10,maxlog10,100);
    tmph = plot(log10(tmpprob1),log10(tmpprob1),'-');

    hold on;

    %% grid on;

    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add lines of constant divergence:

    %% use a contour plot

    %% for probability version:
    %% - compute contours on distorted grid which includes 0
    %%   probabilities
    %% - plot on grid linear in log probability space
    
    %% underlying grid
    %% vector of length 1200 (200 + 1000)
    
    Nzero_points = 100; %% half of region
    Nbulk_points = 1000;
    tmpp = col(logspace(minlog10,minlog10_nonzero,2*Nzero_points+1));

    tmpprob1 = [ ...
        tmpp(1:end-1); ...
        col(logspace(minlog10_nonzero,maxlog10,Nbulk_points)) ...
               ];
    tmpprob2 = tmpprob1;

    %% masked grid
    tmpp = [ ...
        zeros(Nzero_points+1,1); ...
        col(linspace(0,10.^minlog10_nonzero,Nzero_points)) ...
        ];
    tmpprob1_mod = [ ...
        tmpp(1:end-1); ...
        col(logspace(minlog10_nonzero,maxlog10,Nbulk_points)) ...
               ];
    tmpprob2_mod = tmpprob1_mod;
    
    %% no masked grid
    %%    tmpprob1_mod = tmpprob1;
    %%    tmpprob2_mod = tmpprob2;

    %%     tmpx = col(linspace(0,tmpprob1(1),1000));
    %%     tmpp = tmpx(1:end-1).^5;
    %%     
    %%     tmpprob1_mod = [tmpp(2:end); tmpprob1];
    %%     tmpprob2_mod = [tmpp(2:end); tmpprob2];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add contour lines
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (~strcmp(settings.instrument,'none'))

    if (strcmp(settings.instrument,'alpha divergence type 2'))
        [divergence,deltamatrix] = alpha_divergence_symmetric_type2(...
            tmpprob1_mod*ones(1,length(tmpprob1_mod)),...
            ones(length(tmpprob1_mod),1)*tmpprob2_mod',...
            settings.alpha);
    elseif (strcmp(settings.instrument,'probability divergence'))

        if (settings.alpha > 0)
            deltamatrix = probability_turbulence_divergence_nonorm(...
                tmpprob1_mod*ones(1,length(tmpprob1_mod)),...
                ones(length(tmpprob1_mod),1)*tmpprob2_mod',...
                settings.alpha);
            deltamatrix = deltamatrix/normalization;
        else %% fudge alpha = 0 for equivalent visualization
            deltamatrix = probability_turbulence_divergence_nonorm(...
                tmpprob1_mod*ones(1,length(tmpprob1_mod)),...
                ones(length(tmpprob1_mod),1)*tmpprob2_mod',...
                10^-5);
            deltamatrix = deltamatrix/normalization;
        end
        
%%         deltamatrix = alpha_norm_type2(...
%%             tmpprob1_mod*ones(1,length(tmpprob1_mod)),...
%%             ones(length(tmpprob1_mod),1)*tmpprob2_mod',...
%%             settings.alpha);
    
    end

        %% prevent contours from crossing the center line
        for i=1:size(deltamatrix,1)
            deltamatrix(i,i) = -1;
        end
        for i=1:size(deltamatrix,1)-1
            deltamatrix(i,i+1) = -1;
            deltamatrix(i+1,i) = -1;
        end

        Ncontours = 10;
        %% find heights along bottom of diamond and create
        %% even spacing for contours finishing there
        
        contour_indices = 2*Nzero_points + round(linspace(1,length(tmpprob1(201:end)),Ncontours+2));
        heights = deltamatrix(2*Nzero_points + 1,contour_indices(2:end-1));
        
        tmpcontours = contourc(log10(tmpprob1),...
                               log10(tmpprob2),...
                               deltamatrix,...
                               heights);

        %%                               Ncontours);
        %% extract contours
        i=1;
        clear levels;
        
        while(size(tmpcontours,2) > 0)
            levels(i,1) = tmpcontours(1,1);
            Npairs = tmpcontours(2,1);
            contours(i).x1 = tmpcontours(1,2:Npairs+1);
            contours(i).x2 = tmpcontours(2,2:Npairs+1);
            tmpcontours = tmpcontours(:,Npairs+2:end);
            i=i+1;
        end
        
        %%    levels(1:2:end)

        %% plot contours
        %% replace contours in zone between zero and non-zero with
        %% straight line
        for i=1:length(contours)

            tmplog10prob1 = contours(i).x1;
            tmplog10prob2 = contours(i).x2;
            
            tmpxrot = 1/sqrt(2)*((tmplog10prob2) - (tmplog10prob1));
            
            if (tmpxrot(1) > 0)
                %% left side
                %% break into three pieces, if possible

                %% main contours
                indices = find((abs(tmpxrot) >= 0.1) & ...
                               (tmplog10prob1 >= minlog10_nonzero));

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% zero area contours
                indices = find(tmplog10prob1 <= zerolog10);

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% connection dashed line
                dashindices = find(...
                    ((tmplog10prob1 > zerolog10) & (tmplog10prob1 < ...
                                                    minlog10_nonzero)));
                if (length(dashindices)>0)
                    tmpx1 = linspace(tmplog10prob1(dashindices(1)),tmplog10prob1(dashindices(end)),100);
                    tmpx2 = linspace(tmplog10prob2(dashindices(1)),tmplog10prob2(dashindices(end)),100);
                    tmph = plot(tmpx1,tmpx2,':');
                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.5);
                    hold on;
                end
            else
                %% right side
                %% break into three pieces, if possible

                %% main contours
                indices = find((abs(tmpxrot) >= 0.1) & ...
                               (tmplog10prob2 >= minlog10_nonzero));

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% zero area contours
                indices = find(tmplog10prob2 <= zerolog10);

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% connection dashed line
                dashindices = find(...
                    ((tmplog10prob2 > zerolog10) & (tmplog10prob2 < ...
                                                    minlog10_nonzero)));
                if (length(dashindices)>0)
                    tmpx1 = linspace(tmplog10prob1(dashindices(1)),tmplog10prob1(dashindices(end)),100);
                    tmpx2 = linspace(tmplog10prob2(dashindices(1)),tmplog10prob2(dashindices(end)),100);
                    tmph = plot(tmpx1,tmpx2,':');
                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.5);
                    hold on;
                end
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% plot contours in zero zone

    

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% plot dotted lines connecting contours

    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% white out bottom square
    
    x_square = [minlog10, ...
                minlog10, ...
                zerolog10, ...
                zerolog10];
    y_square = [minlog10, ...
                zerolog10, ...
                zerolog10, ...
                minlog10];
    tmph = fill(x_square,y_square,'w');
    %% set(tmph,'edgecolor',colors.darkgrey);
    set(tmph,'edgecolor','w');
    %%    set(tmph,'linewidth',1);
    
    %% blacken two edges
    tmp1 = linspace(minlog10,zerolog10,100);
    tmp2 = zerolog10*ones(size(tmp1));

    tmpx = [tmp1 tmp2];
    tmpy = [tmp2 tmp1];
    
    tmph = plot(tmpx,tmpy,'k-');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% rotate to left-right view

    view(-45,90);
    set(gca,'FontName','Arial');
    set(gca,'fontsize',14);
    set(gca,'color','none');
    %% set(gca,'Color',colors.lightergrey);


    %% for use with layered plots
    %% set(gca,'box','off')

    %% adjust limits
    %% tmpv = axis;
    %% axis([]);
    xlim([minlog10 maxlog10]);
    ylim([minlog10 maxlog10]);

    %% adjust ticks

    tmpaxes(axesnum).TickLabelInterpreter='latex';

    %%     tmpxticks = get(gca,'xtick');
    %%     set(gca,'xtick',[tmpxticks(2) - min2zero_offset,tmpxticks(2:end)]);
    %%     tmpyticks = get(gca,'ytick');
    %%     set(gca,'ytick',[tmpyticks(2) - min2zero_offset,tmpyticks(2:end)]);
    
    tmpxticks = get(gca,'xtick');
    indices = find(tmpxticks >= minlog10_nonzero);
    set(gca,'xtick',[zerolog10,tmpxticks(indices)]);
    set(gca,'FontName','Arial');
    tmpyticks = get(gca,'ytick');
    indices = find(tmpyticks >= minlog10_nonzero);
    set(gca,'ytick',[zerolog10,tmpyticks(indices)]);
    set(gca,'FontName','Arial');

    
    clear tmpxticklabels_mod;
    tmpxticklabels = get(gca,'xticklabel');
    for i=2:length(tmpxticklabels)
        tmpexp = str2num(cell2mat(tmpxticklabels(i)));
        %% brutal fix
        tmpxticklabels_mod{i} = sprintf('$10^{%s}$',addcommas(tmpexp));
    end
    tmpxticklabels_mod{1} = '0';
    set(gca,'xticklabel',tmpxticklabels_mod)
    set(gca,'FontName','Arial');
    clear tmpyticklabels_mod;
    tmpyticklabels = get(gca,'yticklabel');
    for i=2:length(tmpyticklabels)
        tmpexp = str2num(cell2mat(tmpyticklabels(i)));
        %% brutal fix
        tmpyticklabels_mod{i} = sprintf('$10^{%s}$',addcommas(tmpexp));
    end
    tmpyticklabels_mod{1} = '0';
    set(gca,'yticklabel',tmpyticklabels_mod);
    set(gca,'FontName','Arial');

    %% change axis line width (default is 0.5)
    %% set(tmpaxes(axesnum),'linewidth',2)

    %% fix up tickmarks
    %% set(gca,'xtick',[1 100 10^4])
    %% set(gca,'xticklabel',{'','',''})
    %% set(gca,'ytick',[1 100 10^4])
    %% set(gca,'yticklabel',{'','',''})

    %% the following will usually not be printed 
    %% in good copy for papers
    %% (except for legend without labels)

    %% remove a plot from the legend
    %% set(get(get(tmph,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    %% %% legend

    %% tmplh = legend('stuff',...);
    %% tmplh = legend('','','');
    %% 
    %% tmplh.Interpreter = 'latex';
    %% set(tmplh,'position',get(tmplh,'position')-[x y 0 0])
    %% %% change font
    %% tmplh_obj = findobj(tmplh,'type','text');
    %% set(tmplh_obj,'FontSize',18);
    %% %% remove box:
    %% legend boxoff

    %% use latex interpreter for text, sans Arial

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add words along edges of probability turbulence histogram
    %% 
    %% space out vertically to prevent overlap
    %% 
    %% if instrument is being used, adjust color
    %% to reflect strength of word's contribution
    %% 
    %% optional: include words that are requested
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf(1,['Using binwidth=%g for annotations in main plot ' ...
               '(default)\n\n'],binwidth);
    
    %%     Nbins = 40 - 1;
    %%    binwidth = (max(yrotated) - min(yrotated))/Nbins;
    wordbins = [min(yrotated):binwidth:max(yrotated)+binwidth];

    for ibin = 1:length(wordbins)-1
        indices = find((yrotated >= wordbins(ibin)) & (yrotated < wordbins(ibin+1)));
        
        %%%%%%%%%%%%%
        %% left side
        [delta,inceptionindex] = max(deltas_loss(indices));

        if ((length(inceptionindex) > 0) & (delta > 0))
            index = indices(inceptionindex);
            
            word = char(mixedelements(1).types(index));
            
            word_otherprob = mixedelements(2).probs(index);
            if (length(word) > settings.max_plot_string_length)
                word = [word(1:settings.max_plot_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
            end
            if (word_otherprob == 0)
                %%                word = [word, '\,$\bullet$'];
                %%                word = ['$\triangleleft$\,',word];
            end
            
            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');

            %% prevent some havoc
            word = regexprep(word,'$','\\$');
            word = regexprep(word,'#','\\#');
            word = regexprep(word,'_','\\_');


            %% fprintf(1,'%s, %g\n',word,delta);
            
            yrotcenter = wordbins(ibin) + binwidth/2;
            xrot = xrotated(index);
            
            p1 = 10.^(1/sqrt(2)*(yrotcenter - xrot));
            p2 = 10.^(1/sqrt(2)*(yrotcenter + xrot));

            %%        tmpXcoords(ibin) = log10(1.10*mixedelements(2).probs_mod(index));
            %%        tmpYcoords(ibin) = log10(0.90*mixedelements(1).probs_mod(index));

            tmpXcoords(ibin) = log10(0.90*p2);
            tmpYcoords(ibin) = log10(1.10*p1);
            
            %% no instrument: alternate dark grey and black
            if (strcmp(settings.instrument,'none'))
                if (rem(ibin,2)==1)
                    %%            tmphrightwords(i).Color = 'k';
                    tmpcolor = 'k';
                else
                    %%            tmphrightwords(i).Color = colors.darkergrey;
                    tmpcolor = colors.darkergrey;
                end
            else
                %% instrument: color by deltas
                tmpfactor = delta/max(deltas_loss);
                tmpcolor = ((1 - tmpfactor)*(1 - deltamin_text_color)) ...
                    * [1 1 1];
            end

            tmphleftwords(ibin) = text(tmpXcoords(ibin),tmpYcoords(ibin),...
                                       word,...
                                       'FontName','Arial',...
                                       'fontsize',16,...
                                       'units','data',...
                                       'horizontalalignment','right',...
                                       'color',tmpcolor,...
                                       'interpreter','latex');
            %%                    'rotation',rand(1)*20-5,...
        end
        
        %%    fprintf(1,'\n');

        %%%%%%%%%%%%%
        %% right side

        [delta,inceptionindex] = max(deltas_gain(indices));

        if ((length(inceptionindex) > 0) & (delta >= 0))
            index = indices(inceptionindex);
            
            word = char(mixedelements(1).types(index));

            word_otherprob = mixedelements(1).probs(index);
            if (length(word) > settings.max_plot_string_length)
                word = [word(1:settings.max_plot_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
            end
            if (word_otherprob == 0)
                %%%                word = ['$\bullet$\,',word];
                %%                               word = ['$\triangleright$\,',word];
            end

            %%        fprintf(1,'%s, %g\n',word,delta);

            %%        tmpXcoords(ibin) = log10(0.90*mixedelements(2).probs_mod(index));
            %%        tmpYcoords(ibin) =
            %%        log10(1.10*mixedelements(1).probs_mod(index));
            
            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');

            yrotcenter = wordbins(ibin) + binwidth/2;
            xrot = xrotated(index);
            
            r1 = 10.^(1/sqrt(2)*(yrotcenter - xrot));
            r2 = 10.^(1/sqrt(2)*(yrotcenter + xrot));

            %%        tmpXcoords(ibin) = log10(1.10*mixedelements(2).probs_mod(index));
            %%        tmpYcoords(ibin) = log10(0.90*mixedelements(1).probs_mod(index));

            tmpXcoords(ibin) = log10(1.10*r2);
            tmpYcoords(ibin) = log10(0.90*r1);

            if (strcmp(settings.instrument,'none'))
                if (rem(ibin,2)==1)
                    %%            tmphrightwords(i).Color = 'k';
                    tmpcolor = 'k';
                else
                    %%            tmphrightwords(i).Color = colors.darkergrey;
                    tmpcolor = colors.darkergrey;
                end
            else
                %% instrument: color by deltas
                tmpfactor = delta/max(deltas_gain);
                tmpcolor = ((1 - tmpfactor)*(1 - deltamin_text_color)) ...
                    * [1 1 1];
            end
            
            tmpcolor(find(isnan(tmpcolor))) = 1;

            tmphrightwords(ibin) = text(tmpXcoords(ibin),tmpYcoords(ibin),...
                                        word,...
                                        'FontName','Arial',...
                                        'fontsize',16,...
                                        'units','data',...
                                        'horizontalalignment','left',...
                                        'color',tmpcolor,...
                                        'interpreter','latex');
            %%                    'rotation',rand(1)*20-5,...
        end

    end


    %% some labels
    topleftwordindices = indices_left;
    %% include top word
    topwordindices = topleftwordindices(1:min(length(topleftwordindices),settings.topNhistogram));

    %% most extreme:
    indices = find(mixedelements(2).probs_mod == max(mixedelements(2).probs_mod));
    [tmp,index] = min(mixedelements(1).probs_mod(indices));
    extremeindex = indices(index);

    mixedelements(1).types(extremeindex);
    mixedelements(1).probs_mod(extremeindex);
    mixedelements(2).probs_mod(extremeindex);


    topwordindices = unique([...
        topleftwordindices(1:min(length(topleftwordindices),settings.topNhistogram))]);
    %%                        extremeindex]);

    %% sort by vertical position
    [tmp, indices] = sort(yrotated(topwordindices),'ascend');
    topwordindices = topwordindices(indices);

    clear tmpleftwords
    clear tmprightwords

    vertratio = 1.25;
    horizratio = 2;


    for i=1:length(topwordindices)
        j = topwordindices(i);
        word = mixedelements(1).types(j);
        if (length(word) > settings.max_shift_string_length)
            word = [word(1:settings.max_shift_string_length-6),...
                    '...',...
                    word(end-2:end),...
                   ];
        end
        tmpword = sprintf('%s',word{1});
        
        tmpXcoords(i) = log10(0.90*mixedelements(2).probs_mod(j));
        tmpYcoords(i) = log10(1.10*mixedelements(1).probs_mod(j));

        %% check for overlap with preceding text
        tmpcolor = 'k';
        if (i > 1)
            jprev = topwordindices(i-1);
            if (yrotated(j)/vertratio < ...
                yrotated(jprev))
                tmpcolor = 'k';
            end
        end
        
        %%    tmphleftwords(i) = text(tmpXcoords(i),tmpYcoords(i),...
        %%                            tmpword,...
        %%                            'fontsize',14,...
        %%                            'units','data',...
        %%                            'horizontalalignment','right',...
        %%                            'color',tmpcolor,...
        %%                            'interpreter','latex');
        %%    %%                    'rotation',rand(1)*20-5,...
    end

    %%for prune_index = 1:5
    %%    for i=1:length(tmphleftwords)
    %%        tmppos = tmphleftwords(i).Position;
    %%        tmpxpos(i) = (tmppos(1) - tmppos(2))/sqrt(2);
    %%        tmpypos(i) = (tmppos(1) + tmppos(2))/sqrt(2);
    %%    end
    %%
    %%    %%    ratios = yrotated(topwordindices(2:end))./ ...
    %%    %%             yrotated(topwordindices(1:end-1));
    %%    
    %%    %% hardpush(log10(tmpxpos),log10(tmpypos),.1,10);
    %%
    %%    %% logarithmic differences
    %%    xratios = tmpxpos(2:end)./tmpxpos(1:end-1);
    %%    yratios = tmpypos(2:end)./tmpypos(1:end-1);
    %%    xratios(find(xratios<1)) = xratios(find(xratios<1)).^-1;
    %%    
    %%    shiftratio = 1.05;
    %%    j=1;
    %%    for i=2:length(tmphleftwords)
    %%        if (yratios(i-1) < vertratio)
    %%            if (xratios(i-1) < horizratio)
    %%                tmphleftwords(i).Visible = 'off'; %% too close
    %%                %% move texts out
    %%                %%                tmppos = tmphleftwords(i-1).Position;
    %%                %%                tmphleftwords(i).Position = ...
    %%                %%                    [tmppos(1)*shiftratio, tmppos(2)/shiftratio, 0];
    %%            end
    %%        end
    %%        if (strcmp(tmphleftwords(i).Visible,'on')==1)
    %%            tmphleftwords_new(j) = tmphleftwords(i);
    %%            j=j+1;
    %%        end
    %%    end
    %%    tmphleftwords = tmphleftwords_new;
    %%    clear tmphleftwords_new;
    %%end
    %%
    %%j=0;
    %%for i=1:length(tmphleftwords)
    %%    if (strcmp(tmphleftwords(i).Visible,'on')==1)
    %%        j=j+1;
    %%        if (rem(j,2)==1)
    %%            tmphleftwords(i).Color = 'k';
    %%        else
    %%            tmphleftwords(i).Color = colors.darkergrey;
    %%        end
    %%    end
    %%end

    %%% right side

    toprightwordindices = find(mixedelements(1).probs_mod <= mixedelements(2).probs_mod);

    %% find extra pieces
    %% top:
    topindex = find(strcmp(mixedelements(1).types,'rt'));
    %% most extreme:
    indices = find(mixedelements(1).probs_mod == max(mixedelements(1).probs_mod));
    [tmp,index] = min(mixedelements(2).probs_mod(indices));
    extremeindex = indices(index);

    mixedelements(1).types(extremeindex);
    mixedelements(1).probs_mod(extremeindex);
    mixedelements(2).probs_mod(extremeindex);

    topwordindices = unique([topindex; ...
                        toprightwordindices(1:min(length(toprightwordindices),settings.topNhistogram))]);
    %%                        extremeindex]);

    %% sort by vertical position
    [tmp, indices] = sort(yrotated(topwordindices),'ascend');
    topwordindices = topwordindices(indices);

    %%for i=1:length(topwordindices)
    %%    j = topwordindices(i);
    %%    word = mixedelements(1).types(j);
    %%    tmpword = sprintf('%s',word{1});
    %%
    %%    tmpXcoord = 0.90*mixedelements(2).probs_mod(j);
    %%    tmpYcoord = 1.10*mixedelements(1).probs_mod(j);
    %%
    %%    %% check for overlap with preceding text
    %%    tmpcolor = 'k';
    %%    if (i > 1)
    %%        jprev = topwordindices(i-1);
    %%        if (yrotated(j)/1.3 < ...
    %%            yrotated(jprev))
    %%            tmpcolor = 'k';
    %%        end
    %%    end
    %%
    %%    tmphrightwords(i) = text(tmpXcoord,tmpYcoord,...
    %%                             tmpword,...
    %%                             'fontsize',14,...
    %%                             'units','data',...
    %%                             'horizontalalignment','left',...
    %%                             'color',tmpcolor,...
    %%                             'interpreter','latex');
    %%    %%                    'rotation',rand(1)*20-5,...
    %%end
    %%
    %%%%    tmphrightwords = tmphrightwords(1:end-1);
    %%for prune_index = 1:5
    %%    for i=1:length(tmphrightwords)
    %%        tmppos = tmphrightwords(i).Position;
    %%        tmpxpos(i) = (tmppos(1) - tmppos(2))/sqrt(2);
    %%        tmpypos(i) = (tmppos(1) + tmppos(2))/sqrt(2);
    %%    end
    %%
    %%    %%    ratios = yrotated(topwordindices(2:end))./ ...
    %%    %%             yrotated(topwordindices(1:end-1));
    %%    
    %%    %% hardpush(log10(tmpxpos),log10(tmpypos),.1,10);
    %%
    %%    %% logarithmic differences
    %%    xratios = tmpxpos(2:end)./tmpxpos(1:end-1);
    %%    yratios = tmpypos(2:end)./tmpypos(1:end-1);
    %%    xratios(find(xratios<1)) = xratios(find(xratios<1)).^-1;
    %%    
    %%    shiftratio = 1.05;
    %%    j=1;
    %%    for i=2:length(tmphrightwords)
    %%        if (yratios(i-1) < vertratio)
    %%            if (xratios(i-1) < horizratio)
    %%                tmphrightwords(i).Visible = 'off'; %% too close
    %%                %% move texts out
    %%                %%                tmppos = tmphrightwords(i-1).Position;
    %%                %%                tmphrightwords(i).Position = ...
    %%                %%                    [tmppos(1)*shiftratio, tmppos(2)/shiftratio, 0];
    %%            end
    %%        end
    %%        if (strcmp(tmphrightwords(i).Visible,'on')==1)
    %%            tmphrightwords_new(j) = tmphrightwords(i);
    %%            j=j+1;
    %%        end
    %%    end
    %%    tmphrightwords = tmphrightwords_new;
    %%    clear tmphrightwords_new;
    %%end
    %%
    %%j=0;
    %%for i=1:length(tmphrightwords)
    %%    if (strcmp(tmphrightwords(i).Visible,'on')==1)
    %%        j=j+1;
    %%        if (rem(j,2)==1)
    %%            tmphrightwords(i).Color = 'k';
    %%        else
    %%            tmphrightwords(i).Color = colors.darkergrey;
    %%        end
    %%    end
    %%end





    %%%%%%%%%%%%%%%%%%%%
    %% axis labels
    %%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%
    %% left, system 1
    %%%%%%%%%%%%%%%%%%%%

        clear tmpstrless;
    if (isfield(settings,'less_string'))
        for k = 2:length(settings.less_string)
            tmpstrless{k} = settings.less_string{k};
        end
        tmpstrless{1} = ...
            sprintf('\\ \\ \\ \\ %s $\\rightarrow$',...
                    settings.less_string{1});
    else
        tmpstrless{1} = 'less';
        tmpstrless{2} = '\ \ \ \ talked $\rightarrow$';
        tmpstrless{3} = 'about';
    end


    clear tmpstrmore;
    %%    tmpstrmore{1} = 'more talked about $\rightarrow$';
    if (isfield(settings,'more_string'))
        for k = 2:length(settings.more_string)
            tmpstrmore{k} = settings.more_string{k};
        end
        tmpstrmore{1} = ...
            sprintf('$\\leftarrow$ %s\\ \\ \\ \\ ',...
                    settings.more_string{1});
    else
        tmpstrmore{1} = 'more';
        tmpstrmore{2} = '$\leftarrow$ talked\ \ \ \ ';
        tmpstrmore{3} = 'about';
    end

    tmpXcoord = 0.32;
    tmpYcoord = 0.000;
    text(tmpXcoord,tmpYcoord,tmpstrless,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',-45,...
         'interpreter','latex')

    %%     'verticalalignment','middle',...

    tmpXcoord = 0.005;
    tmpYcoord = 0.32;
    text(tmpXcoord,tmpYcoord,tmpstrmore,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',-45,...
         'interpreter','latex')

    %%     'verticalalignment','middle',...


    %%    tmpxlabstr = {'Word Probability $p$','for'};

    tmpxlabstr = {'Probability $p$','for'};

    tmpxlabstr{end+1} = sprintf('%s',settings.system1_name_short);

    tmpXcoord = 0.16;
    tmpYcoord = 0.16;
    tmph = text(tmpXcoord,tmpYcoord,tmpxlabstr,...
                'FontName','Arial',...
                'fontsize',18,...
                'units','normalized',...
                'horizontalalignment','center',...
                'rotation',-45,...
                'interpreter','latex');

    %% tmpxlab=xlabel(tmpxlabstr,...
    %%     'fontsize',16,...
    %%     'verticalalignment','top',...
    %%     'interpreter','latex');


    %%%%%%%%%%%%%%%%%%%%
    %% right, system 2
    %%%%%%%%%%%%%%%%%%%%

    clear tmpstrless;
    if (isfield(settings,'less_string'))
        for k = 2:length(settings.less_string)
            tmpstrless{k} = settings.less_string{k};
        end
        tmpstrless{1} = ... 
            sprintf('$\\leftarrow$ %s\\ \\ \\ \\ ',...
                    settings.less_string{1});
    else
        tmpstrless{1} = 'less';
        tmpstrless{2} = '$\leftarrow$ talked\ \ \ \ ';
        tmpstrless{3} = 'about';
    end


    clear tmpstrmore;
    %%    tmpstrmore{1} = 'more talked about $\rightarrow$';
    if (isfield(settings,'more_string'))
        for k = 2:length(settings.more_string)
            tmpstrmore{k} = settings.more_string{k};
        end
        tmpstrmore{1} = ...
            sprintf('\\ \\ \\ \\ %s $\\rightarrow$',...
                    settings.more_string{1});
    else
        tmpstrmore{1} = 'more';
        tmpstrmore{2} = '\ \ \ \ talked $\rightarrow$';
        tmpstrmore{3} = 'about';
    end

    tmpXcoord = 0.68;
    tmpYcoord = 0.01;
    text(tmpXcoord,tmpYcoord,tmpstrless,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',45,...
         'interpreter','latex')

    %%     'verticalalignment','middle',...

    tmpXcoord = 0.99;
    tmpYcoord = 0.31;
    text(tmpXcoord,tmpYcoord,tmpstrmore,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',45,...
         'interpreter','latex')

    %%    tmpylabstr = {'Word Probability $p$','for'};

    tmpylabstr = {'Probability $p$','for'};
    
    tmpylabstr{end+1} = sprintf('%s',settings.system2_name_short);

    %% tmpylab=ylabel(tmpylabstr,...
    %%     'fontsize',16,...
    %%     'verticalalignment','bottom',...
    %%     'interpreter','latex');

    tmpXcoord = 0.84;
    tmpYcoord = 0.16;
    tmph = text(tmpXcoord,tmpYcoord,tmpylabstr,...
                'FontName','Arial',...
                'fontsize',18,...
                'units','normalized',...
                'horizontalalignment','center',...
                'rotation',45,...
                'interpreter','latex');


    %%%%%%%%%%%%
    %% title

    %% tmpstr = 'Rank comparison plot';
    %% 
    %% tmpXcoord = 0.00;
    %% tmpYcoord = 1.00;
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%             'fontsize',18,...
    %%             'units','normalized',...
    %%             'horizontalalignment','left',...
    %%             'verticalalignment','top',...
    %%             'rotation',0,...
    %%             'interpreter','latex');


    %% set(tmpxlab,'position',get(tmpxlab,'position') - [0 .1 0]);
    %% set(tmpylab,'position',get(tmpylab,'position') - [.1 0 0]);

    %% set 'units' to 'data' for placement based on data points
    %% set 'units' to 'normalized' for relative placement within axes
    %% tmpXcoord = ;
    %% tmpYcoord = ;
    %% tmpstr = sprintf(' ');
    %% or
    %% tmpstr{1} = sprintf(' ');
    %% tmpstr{2} = sprintf(' ');
    %%
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%     'fontsize',20,...
    %%     'units','normalized',...
    %%     'interpreter','latex')

    %% label (A, B, ...)
    %% tmplabelh = addlabel4(' A ',0.02,0.9,20);
    %% tmplabelh = addlabel5(loop_i,0.02,0.9,20);
    %% or:
    %% tmplabelXcoord= 0.015;
    %% tmplabelYcoord= 0.88;
    %% tmplabelbgcolor = 0.85;
    %% tmph = text(tmplabelXcoord,tmplabelYcoord,...
    %%    ' A ',...
    %%    'fontsize',24,
    %%         'units','normalized');
    %%    set(tmph,'backgroundcolor',tmplabelbgcolor*[1 1 1]);
    %%    set(tmph,'edgecolor',[0 0 0]);
    %%    set(tmph,'linestyle','-');
    %%    set(tmph,'linewidth',1);
    %%    set(tmph,'margin',1);

    %% rarely used (text command is better)
    %% title(' ','fontsize',24,'interpreter','latex')
    %% 'horizontalalignment','left');
    %% tmpxl = xlabel('','fontsize',24,'verticalalignment','top');
    %% set(tmpxl,'position',get(tmpxl,'position') - [ 0 .1 0]);
    %% tmpyl = ylabel('','fontsize',24,'verticalalignment','bottom');
    %% set(tmpyl,'position',get(tmpyl,'position') - [ 0.1 0 0]);
    %% title('','fontsize',24)

    if (strcmp(settings.instrument,'probability divergence'))

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLOT for probabilility version: alpha linear gauge
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        axesnum = 7;
        tmpaxes_gauge = axes('position',axes_positions(axesnum).box);
                
        %% create slider
        
        tmpx = linspace(0,pi/2,100);
        tmpy = ones(size(tmpx));
                
        tmph = plot(tmpx,tmpy,'-');
        
        set(tmph,'color',colors.darkgrey);
        set(tmph,'linewidth',1);

        hold on;
        
        alphavals = [0, 1/4, 2/4, 3/4, 1, 3/2, 2, 3, 5, Inf];
        tickmarks = atan(alphavals)/(pi/2);
        
%%         alphavalstrs = {'0',...
%%                         '$\frac{1}{4}$',...
%%                         '$\frac{1}{2}$',...
%%                         '$\frac{3}{4}$',...
%%                         '1',...
%%                         '$\frac{3}{2}$',...
%%                         '2',...
%%                         '3',...
%%                         '5',...
%%                         '$\infty$'};

        alphavalstrs = {'0',...
                        '1/4',...
                        '1/2',...
                        '3/4',...
                        '1',...
                        '3/2',...
                        '2',...
                        '3',...
                        '5',...
                        '$\infty$'};
        
        
        tmpy = linspace(.5,1.5,10);
        for i=1:length(tickmarks)
            tmpx = tickmarks(i)*ones(size(tmpy));
            tmph = plot(tmpx,tmpy,'-');
            set(tmph,'color',colors.darkgrey);
            set(tmph,'linewidth',1);
        
            tmpstr = sprintf('%s',alphavalstrs{i});
            tmpXcoord = tickmarks(i);
            tmpYcoord = -0.3;
            tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                        'FontName','Arial',...
                        'fontsize',12,...
                        'units','normalized',...
                        'horizontalalignment','center',...
                        'verticalalignment','middle',...
                        'rotation',0,...
                        'interpreter','latex');

        end
        
        xlim([0 1]);
        ylim([0 2]);
        
        tmpaxes_gauge.XAxis.Visible = 'off';
        tmpaxes_gauge.YAxis.Visible = 'off';
        
        %% add alpha setting indicator
        
        tmpx = atan(settings.alpha)/(pi/2);
        tmpy = 2;
        tmph = plot(tmpx,tmpy,'v');
        set(tmph,'markersize',8);
        set(tmph,'markerfacecolor',colors.verydarkgrey);
        set(tmph,'markeredgecolor',colors.verydarkgrey);

        tmpstr = sprintf('$\\alpha$=$%s$',alpha_str);
        tmpXcoord = atan(settings.alpha)/(pi/2) - 0.03;
        tmpYcoord = 2.2;
        tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                    'FontName','Arial',...
                    'fontsize',14,...
                    'units','normalized',...
                    'horizontalalignment','left',...
                    'verticalalignment','top',...
                    'rotation',0,...
                    'interpreter','latex');
    elseif (strcmp(settings.instrument,'alpha divergence type 2'))    

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLOT for probabilility version, alpha type 2: alpha linear gauge
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        axesnum = 7;
        tmpaxes_gauge = axes('position',axes_positions(axesnum).box);
                
        %% create slider
        
        tmpx = linspace(atan(-2)/(pi/2),0.5,100);
        tmpy = ones(size(tmpx));
                
        tmph = plot(tmpx,tmpy,'-');
        
        set(tmph,'color',colors.darkgrey);
        set(tmph,'linewidth',1);

        hold on;
        
        alphavals = [-2,
                     -1, 
                     -1/2,
                     -1/4, 
                     0,
                     1/4,
                     1/2,
                     3/4,
        %%                     0.8,
        %%                     0.85,
        %%                     0.95,
                     1];

        tickmarks = atan(alphavals)/(pi/2);

        alphavalstrs = {'-2',
                        '-1',
                        '-1/2',
                        '-1/4',
                        '0',
                        '1/4',
                        '1/2',
                        '3/4',
        %%                        '4/5',
        %%                        '17/20',
        %%                        '19/20',
                        '1'};
        
        
        tmpy = linspace(.5,1.5,10);
        for i=1:length(tickmarks)
            tmpx = tickmarks(i)*ones(size(tmpy));
            tmph = plot(tmpx,tmpy,'-');
            set(tmph,'color',colors.darkgrey);
            set(tmph,'linewidth',1);
        
            tmpstr = sprintf('%s',alphavalstrs{i});
            tmpXcoord = tickmarks(i);
            tmpYcoord = -0.3;
            tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                        'FontName','Arial',...
                        'fontsize',12,...
                        'units','data',...
                        'horizontalalignment','center',...
                        'verticalalignment','middle',...
                        'rotation',0,...
                        'interpreter','latex');

        end
        
        xlim([atan(-2)/(pi/2), 0.5]);
        ylim([0 2]);
        
        tmpaxes_gauge.XAxis.Visible = 'off';
        tmpaxes_gauge.YAxis.Visible = 'off';
        
        %% add alpha setting indicator
        
        tmpx = atan(settings.alpha)/(pi/2);
        tmpy = 2;
        tmph = plot(tmpx,tmpy,'v');
        set(tmph,'markersize',8);
        set(tmph,'markerfacecolor',colors.verydarkgrey);
        set(tmph,'markeredgecolor',colors.verydarkgrey);

        tmpstr = sprintf('$\\alpha$=$%s$',alpha_str);
        if (settings.alpha==0) 
            tmpstr = [tmpstr, ' (',  title_special_str, ')'];
        end
        tmpXcoord = atan(settings.alpha)/(pi/2) - 0.03;
        tmpYcoord = 4.2;
        tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                     'FontName','Arial',...
                    'fontsize',14,...
                    'units','data',...
                    'horizontalalignment','left',...
                    'verticalalignment','top',...
                    'rotation',0,...
                    'interpreter','latex');
        if (settings.alpha==0) 
            set(tmph,'horizontalalignment','center');
        end

    end


    if (~strcmp(settings.instrument,'none'))
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLOT for Probability version: inset showing lines of constant divergence
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%
        %% set up background
        %%%%%%%%%%%%%%%%%%%%%

        axesnum = 4;
        tmpaxes_inset_lines = axes('position',axes_positions(axesnum).box);

        bg_alpha = 0.75;
        
        x_triangle = [minlog10_nonzero, maxlog10,  maxlog10, minlog10_nonzero];
        y_triangle = [minlog10_nonzero, maxlog10,  minlog10_nonzero, minlog10_nonzero];
        tmph = fill(x_triangle,y_triangle,colors.paleblue);
        set(tmph,'edgecolor',colors.paleblue);
        set(tmph,'facealpha',bg_alpha);
        set(tmph,'edgealpha',bg_alpha);

        hold on;

        x_triangle = [minlog10_nonzero, maxlog10,  minlog10_nonzero, minlog10_nonzero];
        y_triangle = [minlog10_nonzero, maxlog10,  maxlog10, minlog10_nonzero];
        tmph = fill(x_triangle,y_triangle,colors.lightgrey);
        set(tmph,'edgecolor',colors.lightgrey);
        set(tmph,'facealpha',bg_alpha);
        set(tmph,'edgealpha',bg_alpha);

        %% pentangles surrounding zero probability line

        %% left
        %%                   minlog10 + zero2axis_offset, ...
        x_pentangle = [minlog10, ...
                       minlog10, ...
                       minlog10_nonzero, ...
                       minlog10_nonzero, ...
                       zerolog10];
        %%                   minlog10 + zero2axis_offset, ...
        y_pentangle = [zerolog10, ...
                       maxlog10, ...
                       maxlog10, ...
                       minlog10_nonzero, ...
                       zerolog10];

        tmph = fill(x_pentangle,y_pentangle,colors.lightgrey);
        set(tmph,'edgecolor',colors.lightgrey);
        set(tmph,'facealpha',bg_alpha_alt);
        set(tmph,'edgealpha',bg_alpha_alt);

        hold on;
        
        %% right
        x_pentangle = [zerolog10, ...
                       maxlog10, ...
                       maxlog10, ...
                       minlog10_nonzero, ...
                       zerolog10];
        y_pentangle = [minlog10, ...
                       minlog10, ...
                       minlog10_nonzero, ...
                       minlog10_nonzero, ...
                       zerolog10];
        
        tmph = fill(x_pentangle,y_pentangle,colors.paleblue);
        set(tmph,'edgecolor',colors.paleblue);
        set(tmph,'facealpha',bg_alpha_alt);
        set(tmph,'edgealpha',bg_alpha_alt);
        
        hold on;

        %%    set(gca,'xtick',[]);
        %%    set(gca,'ytick',[]);
        set(gca,'color','none');
        set(gca,'FontName','Arial');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% white out bottom square
        
        x_square = [minlog10, ...
                    minlog10, ...
                    zerolog10, ...
                    zerolog10];
        y_square = [minlog10, ...
                    zerolog10, ...
                    zerolog10, ...
                    minlog10];
        tmph = fill(x_square,y_square,'w');
        set(tmph,'edgecolor','w');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% rotate to left-right view

        view(-45,90);

        hold on;

        %% set(gca,'xtick',[]);
        %% set(gca,'ytick',[]);
        set(gca,'color','none');
        set(gca,'FontName','Arial');
        xlim([minlog10 maxlog10]);
        ylim([minlog10 maxlog10]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add center line

        transparency_alpha = 0.75;
        transparency_alpha_alt = 0.05;

        tmpprob1 = logspace(minlog10_nonzero,maxlog10,100);
        tmph = plot(log10(tmpprob1),log10(tmpprob1),'-');

        hold on;

        %% grid on;

        set(tmph,'color','k');
        set(tmph,'linewidth',0.50);
        tmph.Color(4) = transparency_alpha;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add lines of constant divergence:

        %% use a contour plot (data from above)


        %%     tmpprob1 = col(logspace(minlog10,maxlog10,1000));
        %%     tmpprob2 = col(logspace(minlog10,maxlog10,1000));
        %% 
        %%     tmpcontours = contourc(log10(tmpprob1),...
        %%                            log10(tmpprob2),...
        %%                            log10(deltamatrix),...
        %%                            Ncontours);
        %% 
        %%     %% extract contours
        %%     i=1;
        %%     while(size(tmpcontours,2) > 0)
        %%         Npairs = tmpcontours(2,1);
        %%         contours(i).x1 = tmpcontours(1,2:Npairs+1);
        %%         contours(i).x2 = tmpcontours(2,2:Npairs+1);
        %%         tmpcontours = tmpcontours(:,Npairs+2:end);
        %%         i=i+1;
        %%     end


        %% plot contours
        %% replace contours in zone between zero and non-zero with
        %% straight line

        for i=1:length(contours)

            tmplog10prob1 = contours(i).x1;
            tmplog10prob2 = contours(i).x2;
            
            tmpxrot = 1/sqrt(2)*((tmplog10prob2) - (tmplog10prob1));
            
            if (tmpxrot(1) > 0)
                %% left side
                %% break into three pieces, if possible

                %% main contours
                indices = find((abs(tmpxrot) >= 0.1) & ...
                               (tmplog10prob1 >= minlog10_nonzero));

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% zero area contours
                indices = find(tmplog10prob1 <= zerolog10);

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% connection dashed line
                dashindices = find(...
                    ((tmplog10prob1 > zerolog10) & (tmplog10prob1 < ...
                                                    minlog10_nonzero)));
                if (length(dashindices)>0)
                    tmpx1 = linspace(tmplog10prob1(dashindices(1)),tmplog10prob1(dashindices(end)),100);
                    tmpx2 = linspace(tmplog10prob2(dashindices(1)),tmplog10prob2(dashindices(end)),100);
                    tmph = plot(tmpx1,tmpx2,':');
                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.5);
                    hold on;
                end
            else
                %% right side
                %% break into three pieces, if possible

                %% main contours
                indices = find((abs(tmpxrot) >= 0.1) & ...
                               (tmplog10prob2 >= minlog10_nonzero));

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% zero area contours
                indices = find(tmplog10prob2 <= zerolog10);

                if (length(indices)>0)
                    tmph = plot((tmplog10prob1(indices)),(tmplog10prob2(indices)),'-');

                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.25);
                    hold on;
                end

                %% connection dashed line
                dashindices = find(...
                    ((tmplog10prob2 > zerolog10) & (tmplog10prob2 < ...
                                                    minlog10_nonzero)));
                if (length(dashindices)>0)
                    tmpx1 = linspace(tmplog10prob1(dashindices(1)),tmplog10prob1(dashindices(end)),100);
                    tmpx2 = linspace(tmplog10prob2(dashindices(1)),tmplog10prob2(dashindices(end)),100);
                    tmph = plot(tmpx1,tmpx2,':');
                    set(tmph,'color','k');
                    tmph.Color(4) = transparency_alpha;
                    set(tmph,'linewidth',0.5);
                    hold on;
                end
            end
        end
        
        %%     for i=1:length(contours)
        %%         tmph = plot(contours(i).x1,contours(i).x2);
        %%         set(tmph,'color','k');
        %%         tmph.Color(4) = transparency_alpha;
        %%         set(tmph,'linewidth',0.25);
        %%         hold on;
        %%         
        %%         %%    tmph = plot(contours(i).x1(end),contours(i).x2(end),'ro');
        %% 
        %%     end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% turned off PTD xtick labels for probability version
        %% (except for 0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %% ticks (not trivial)
        
        %% 1. get locations of ticks made by matlab
        %% 2. determine corresponding underlying probability
        %% 3. determine corresponding masked probability
        %% 4. assign correct ticks with scientific notation
        
        tmpp = col(logspace(minlog10,minlog10_nonzero,2*Nzero_points+1));

        tmpprob1 = [ ...
            tmpp(1:end-1); ...
            col(logspace(minlog10_nonzero,maxlog10,Nbulk_points)) ...
                   ];
        tmpprob2 = tmpprob1;


        tmpprob_edge =  10.^(get(gca,'xtick'));
        %% remove first tick (should be close to bottom of diamond):
        tmpprob_edge =  tmpprob_edge(2:end);
        set(gca,'xtick',log10(tmpprob_edge));
        set(gca,'ytick',log10(tmpprob_edge));
        set(gca,'FontName','Arial');
        clear tmpprob1_mod_ticks;
        for i=1:length(tmpprob_edge)
            fprintf(1,'May be a problem here ... insert contour key\n');
            index = min(find(tmpprob_edge(i) < tmpprob1));
            if (length(index) ~= 1)
                fprintf(1,['Problem with contour inset for probability-turbulence ' ...
                           'divergnece\n']);
                index
            end
            %% may be of length 0; error here
            if (length(index) > 0) 
                index = index(1);
                tmpprob1_mod_ticks(i) = tmpprob1_mod(index);
            end
        end
        tmpprob1_mod_ticks;

        if (strcmp(settings.instrument,'alpha divergence type 2'))
            [divergence,delta_edge] = alpha_divergence_symmetric_type2(...
                0*ones(length(tmpprob1_mod_ticks),1),...
                col(tmpprob1_mod_ticks),...
                settings.alpha);
        elseif (strcmp(settings.instrument,'probability divergence'))

            delta_edge = probability_turbulence_divergence_nonorm(...
                0*ones(length(tmpprob1_mod_ticks),1),...
                col(tmpprob1_mod_ticks),...
                settings.alpha);
            delta_edge = delta_edge / normalization;

%%             delta_edge = alpha_norm_type2(...
%%                 0*ones(length(tmpprob1_mod_ticks),1),...
%%                 col(tmpprob1_mod_ticks),...
%%                 settings.alpha);
        end

        %%     if (strcmp(settings.instrument,'alpha divergence type 2'))
        %%         [divergence,delta_edge] = alpha_divergence_symmetric_type2(...
        %%             0*ones(length(contour_indices(2:end-1)),1),...
        %%             tmpprob1_mod(contour_indices(2:end-1)),...
        %%             settings.alpha);
        %%     elseif (strcmp(settings.instrument,'probability divergence'))
        %%         delta_edge = alpha_norm_type2(...
        %%             0*ones(length(contour_indices(2:end-1)),1),...
        %%             tmpprob1_mod(contour_indices(2:end-1)),...
        %%             settings.alpha);
        %%     end



        %%        delta_edge

        
        for i=1:length(delta_edge)
            %%        tmpstr =
            %%        sprintf('%f',round(delta_edge(i),3,'significant'));
            tmpexp = floor(log10(delta_edge(i)));
            tmpamp = delta_edge(i)/10^tmpexp;
            delta_edge_str{i} = sprintf('$%.2f\\!\\times\\!10^{%d}$',...
                                        tmpamp,...
                                        tmpexp);
            %% not working:
            %% regexprep(tmpstr,'0+$','beep');
            %% 
            %% hack:
            %%         while(strcmp('0',tmpstr(end)))
            %%             tmpstr = tmpstr(1:end-1);
            %%         end
            %%         if(strcmp('.',tmpstr(end)))
            %%             tmpstr = tmpstr(1:end-1);
            %%         end
            %%         delta_edge_str{i} = tmpstr;
        end
        
        tmpaxes_inset_lines.TickLabelInterpreter='latex';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% turned off xtick labels for probability version
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% set(gca,'xticklabel',delta_edge_str);
        %% set(gca,'yticklabel',delta_edge_str);
        set(gca,'xticklabel',[]);
        set(gca,'yticklabel',[]);
        set(gca,'FontName','Arial');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% turned off xtick labels for probability version
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




        %% set(gca,'xticklabel',delta_edge);
        %% set(gca,'yticklabel',delta_edge);

        %% clear tmpxticklabels;
        %% for i=1:length(deltavals)
        %%     tmpxticklabels{i} = sprintf('$10^{%d}$',floor(log10(deltavals(i))));
        %% end
        %% tmpaxes_inset_lines.TickLabelInterpreter='latex';

        %% set(gca,'xtick',log10(rvals));
        %% set(gca,'xticklabel',tmpxticklabels);
        %% set(gca,'ytick',log10(rvals));
        %% set(gca,'yticklabel',tmpxticklabels);


        %% ticks
        %% clear tmpxticklabels;
        %% for i=1:length(deltavals)
        %%     tmpxticklabels{i} = sprintf('$10^{%d}$',floor(log10(deltavals(i))));
        %% end
        %% tmpaxes_inset_lines.TickLabelInterpreter='latex';

        tmpprob1(end);

        %% set(gca,'xtick',log10(rvals));
        %% set(gca,'xticklabel',tmpxticklabels);
        %% set(gca,'ytick',log10(rvals));
        %% set(gca,'yticklabel',tmpxticklabels);


        %% add zero for center line
        tmpstr = '0';
        tmpXcoord = 0.50;
        tmpYcoord = -0.10;
        tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                    'FontName','Arial',...
                    'fontsize',12,...
                    'units','normalized',...
                    'horizontalalignment','center',...
                    'verticalalignment','middle',... 
                    'rotation',0,...
                    'interpreter','latex');

        %% title
        clear tmpstr;
        tmpstr{1} = 'Lines of';
        tmpstr{2} = 'Constant';
        tmpstr{3} = sprintf('$\\delta D_{%s,\\tau}^{\\rm %s}$', ...
                            alpha_str, ...
                            divergence_superscript_str);

        tmpXcoord = 0.50;
        tmpYcoord = 0.50;
        tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                     'FontName','Arial',...
                    'fontsize',16,...
                    'units','normalized',...
                    'horizontalalignment','center',...
                    'verticalalignment','middle',...
                    'rotation',0,...
                    'color',colors.darkergrey,...
                    'interpreter','latex');

        set(gca,'fontsize',12);
        set(gca,'FontName','Arial');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% rotate to left-right view

        %%    view(135,90);
    end

elseif (strcmp(settings.plotkind,'count'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: count version (no instrument)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% zipf comparison diamond plot for counts
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% deal with 0 probabilities
    
    maxcount1 = max(mixedelements(1).counts);
    maxcount2 = max(mixedelements(2).counts);

    %% true min
    mincount1 = min(mixedelements(1).counts);
    mincount2 = min(mixedelements(2).counts);
    
    %% copy counts for modification when 0s are present (expected)
    mixedelements(1).counts_mod = mixedelements(1).counts;
    mixedelements(2).counts_mod = mixedelements(2).counts;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% indicators for zeros and non-zeros
    zeros1 = (mixedelements(1).counts_mod == 0);
    zeros2 = (mixedelements(2).counts_mod == 0);
    zeros1_indices = find(zeros1);
    zeros2_indices = find(zeros2);

    nonzeros1 = (mixedelements(1).counts_mod > 0);
    nonzeros2 = (mixedelements(2).counts_mod > 0);
    nonzeros1_indices = find(nonzeros1);
    nonzeros2_indices = find(nonzeros2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% minimum non-zero counts
    mincount1_nonzero = min(mixedelements(1).counts_mod(nonzeros1_indices));
    mincount2_nonzero = min(mixedelements(2).counts_mod(nonzeros2_indices));

    minlog10_nonzero = log10(min([mincount1_nonzero,mincount2_nonzero]));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% naughty: modify counts so 0s will plot well

    %% put 0s at min2zero_factor x lowest non-zero countabiltiy
    min2zero_offset = 0.50;
    zero2axis_offset = 0.75;
    
    zero1log10 = (log10(mincount1_nonzero)) - min2zero_offset;
    zero2log10 = (log10(mincount2_nonzero)) - min2zero_offset;
    zerolog10 = min([zero1log10 zero2log10]);

    mixedelements(1).counts_mod(zeros1_indices) = 10^zerolog10;
    mixedelements(2).counts_mod(zeros2_indices) = 10^zerolog10;
    
    %% range for countabilities (log10)
    %% minlog10:maxlog10

    minlog10 = -zero2axis_offset + (log10(min([min(mixedelements(1).counts_mod),min(mixedelements(2).counts_mod)])));
    maxlog10 = ceil(log10(max([max(mixedelements(1).counts_mod),max(mixedelements(2).counts_mod)])));

    %% compute rotated coordinates for each type:

    xrotated = 1/sqrt(2) * (log10(mixedelements(2).counts_mod) - log10(mixedelements(1).counts_mod));
    yrotated = 1/sqrt(2) * (log10(mixedelements(2).counts_mod) + log10(mixedelements(1).counts_mod));

    %%%%%%%%%%%%%%%%%%%%%
    %% set up background
    %%%%%%%%%%%%%%%%%%%%%

    axesnum = 1;
    tmpaxes_bg = axes('position',axes_positions(axesnum).box);

    bg_alpha = 0.95;
    bg_alpha_alt = 0.50;

    %% triangles

    %% left
    x_triangle = [minlog10 + zero2axis_offset, maxlog10,  minlog10 + zero2axis_offset, minlog10 + zero2axis_offset];
    y_triangle = [minlog10 + zero2axis_offset, maxlog10,  maxlog10, minlog10 + zero2axis_offset];

    x_triangle = [minlog10_nonzero, maxlog10,  minlog10_nonzero, minlog10_nonzero];
    y_triangle = [minlog10_nonzero, maxlog10,  maxlog10, minlog10_nonzero];

    tmph = fill(x_triangle,y_triangle,colors.lightgrey);

    set(tmph,'edgecolor',colors.lightgrey);
    set(tmph,'facealpha',bg_alpha);
    set(tmph,'edgealpha',bg_alpha);

    hold on;
    
    %% right
    x_triangle = [minlog10 + zero2axis_offset, maxlog10,  maxlog10, minlog10 + zero2axis_offset];
    y_triangle = [minlog10 + zero2axis_offset, maxlog10,  minlog10 + zero2axis_offset, minlog10 + zero2axis_offset];
    tmph = fill(x_triangle,y_triangle,colors.lightgrey);
    set(tmph,'edgecolor',colors.lightgrey);
    set(tmph,'facealpha',bg_alpha);
    set(tmph,'edgealpha',bg_alpha);

    hold on;

    %% pentangles surrounding zero countability line

    %% left
    %%                   minlog10 + zero2axis_offset, ...
    x_pentangle = [minlog10, ...
                   minlog10, ...
                   minlog10_nonzero, ...
                   minlog10_nonzero, ...
                   zerolog10];
    %%                   minlog10 + zero2axis_offset, ...
    y_pentangle = [zerolog10, ...
                   maxlog10, ...
                   maxlog10, ...
                   minlog10_nonzero, ...
                   zerolog10];

    tmph = fill(x_pentangle,y_pentangle,colors.lightgrey);
    set(tmph,'edgecolor',colors.lightgrey);
    set(tmph,'facealpha',bg_alpha_alt);
    set(tmph,'edgealpha',bg_alpha_alt);

    hold on;
    
    %% right
    x_pentangle = [minlog10 + zero2axis_offset, maxlog10,  maxlog10, minlog10 + zero2axis_offset];
    y_pentangle = [minlog10 , minlog10,  minlog10 + zero2axis_offset, minlog10 + zero2axis_offset];
    tmph = fill(x_pentangle,y_pentangle,colors.lightgrey);
    set(tmph,'edgecolor',colors.lightgrey);
    set(tmph,'facealpha',bg_alpha_alt);
    set(tmph,'edgealpha',bg_alpha_alt);

    hold on;

    %% remove ticks

    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'color','none');
    set(gca,'FontName','Arial');
    xlim([minlog10 maxlog10]);
    ylim([minlog10 maxlog10]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% rotate to left-right view

    view(-45,90);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% main diamond plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    axesnum = 1;
    tmpaxes(axesnum) = axes('position',axes_positions(axesnum).box);


    %% gel preparation

    indices_left = find(mixedelements(1).counts_mod > mixedelements(2).counts_mod);
    indices_right = find(mixedelements(1).counts_mod < mixedelements(2).counts_mod);
    indices_middle = find(mixedelements(1).counts_mod == ...
                          mixedelements(2).counts_mod);

    %% only plot points once:
    [unique_counts,unique_indices,expander_indices] = ...
        unique([log10(mixedelements(1).counts_mod),log10(mixedelements(2).counts_mod)],...
               'rows');

    [pointcounts,pointindices] = hist(expander_indices,1:max(expander_indices));

    indices_left_unique = unique_indices(find(mixedelements(1).counts_mod(unique_indices) > mixedelements(2).counts_mod(unique_indices)));
    indices_right_unique = unique_indices(find(mixedelements(1).counts_mod(unique_indices) < mixedelements(2).counts_mod(unique_indices)));
    indices_middle_unique = unique_indices(find(mixedelements(1).counts_mod(unique_indices) == ...
                                                mixedelements(2).counts_mod(unique_indices)));


    [tmp,tmpindices] = sort(mixedelements(1).counts_mod(indices_middle),'ascend');
    indices_middle = indices_middle(tmpindices);

    %% background of diamonds

    Ncells = floor((maxlog10-minlog10)/cell_length) + 1;

    x1_centervals = -cell_length + ones(Ncells,1)*[maxlog10:-cell_length:minlog10];
    x2_centervals = x1_centervals';

    x1_indices = ceil((maxlog10 - log10(mixedelements(1).counts_mod))/cell_length);
    x2_indices = ceil((maxlog10 - log10(mixedelements(2).counts_mod))/cell_length);

    x1_indices(find(x1_indices<1)) = 1;
    x1_indices(find(x1_indices>Ncells)) = Ncells;
    x2_indices(find(x2_indices<1)) = 1;
    x2_indices(find(x2_indices>Ncells)) = Ncells;
    
    counts = zeros(Ncells,Ncells);
    for i=1:length(mixedelements(1).counts_mod)
        counts(x1_indices(i),x2_indices(i)) = ...
            counts(x1_indices(i),x2_indices(i)) + 1;
    end

    maxcounts = max(counts(:));
    if(isfield(settings,'maxcount_log10'))
        maxcountslog10 = ceil(settings.maxcount_log10);
        %% catch
        if (maxcountslog10 < 1)
            maxcountslog10 = 1;
        end
    else %% based on data
        maxcounts = max(counts(:));
        %% round up
        maxcountslog10 = ceil(log10(maxcounts));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add lines to block off zero countability lines

    transparency_alpha = 0.75;
    transparency_alpha_alt = 0.05;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%    tmpx = linspace(minlog10 + 1 - min2zero_offset,maxlog10,100);
    %%    tmpy = (minlog10 + 1 - min2zero_offset)*ones(size(tmpx));

    tmpx = linspace(minlog10,maxlog10,100);
    tmpy = (zerolog10)*ones(size(tmpx));
    
    tmph = plot(tmpx,tmpy,':');
    hold on;
    
    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%    tmpy = linspace(minlog10 + 1 - min2zero_offset,maxlog10,100);
    %%    tmpx = (minlog10 + 1 - min2zero_offset)*ones(size(tmpx));

    tmpy = linspace(minlog10,maxlog10,100);
    tmpx = (zerolog10)*ones(size(tmpx));

    tmph = plot(tmpx,tmpy,':');
    hold on;

    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%    tmpx = linspace(minlog10 + 1,maxlog10,100);
    %%    tmpy = (minlog10 + 1)*ones(size(tmpx));
    tmpx = linspace(log10(mincount1_nonzero),maxlog10,100);
    tmpy = (log10(mincount1_nonzero) - cell_length/sqrt(2))*ones(size(tmpx));
    
    tmph = plot(tmpx,tmpy,'-');
    hold on;
    
    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%    tmpy = linspace(minlog10 + 1,maxlog10,100);
    %%    tmpx = (minlog10 + 1)*ones(size(tmpx));
    tmpy = linspace(log10(mincount1_nonzero),maxlog10,100);
    tmpx = (log10(mincount1_nonzero) - cell_length/sqrt(2))*ones(size(tmpx));

    tmph = plot(tmpx,tmpy,'-');
    hold on;

    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% set up centers
    
    for i=1:Ncells
        for j=1:Ncells
            tmpx = [x1_centervals(i,j) - 0*cell_length/2 + 0;
                    x1_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x1_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x1_centervals(i,j) - 0*cell_length/2 + 0];
            tmpy = [x2_centervals(i,j) - 0*cell_length/2 + 0;
                    x2_centervals(i,j) - 0*cell_length/2 + 0;
                    x2_centervals(i,j) - 0*cell_length/2 + cell_length;
                    x2_centervals(i,j) - 0*cell_length/2 + cell_length];
            
            %% add histogram box if one ore more pairs of ranks are
            %% present
            %% else: add strength of divergence for middle of that box
            if (counts(i,j) > 0)

                factor = 0.0 + 1*(1 - log10(counts(i,j))/maxcountslog10);
                %%            factor = 1 - (0.02 + 0.98*(1 - log10(counts(i,j))/maxcountslog10));

                %%            set(tmph,'edgecolor',colors.blue);

                %%            tmpcolors = parula(10^4);

                %%            tmpcolors = inferno(10^4);
                %% tmpcolors = plasma(10^4);
                
                colorindex = ceil(factor*(10^4-1));
                if (colorindex == 0)
                    colorindex = 1;
                end
                if (colorindex > 10^4)
                    colorindex = 10^4;
                end

                tmph = fill(tmpx,tmpy,heatmapcolors(colorindex,:));
                set(tmph,'edgecolor',.7*heatmapcolors(colorindex,:));

                %%            tmph = fill(tmpx,tmpy,factor*[1 1 1]);
                %%            set(tmph,'edgecolor',.7*factor*[1 1 1]);
                
                set(tmph,'linewidth',.5);

                %% set(tmph,'facealpha',factor);
                %%            set(tmph,'edgealpha',factor);
                
                hold on;

                %%         else
                %%             factor = 0.9;
                %%             tmph = fill(tmpx,tmpy,factor*[1 1 .8]);
                %%             set(tmph,'edgecolor',.9*factor*[1 1 .8]);
                %%             
                %%             hold on;
            end
        end
    end

    %% set(gca,'clipping','off')


    %% logrankvals = [0:cell_length:maxlog10-cell_length];
    %% for i=1:length(logrankvals)
    %%     tmpx = [logrankvals(i) + 0;
    %%             logrankvals(i) + cell_length;
    %%             logrankvals(i) + cell_length;
    %%             logrankvals(i) + 0];
    %%     for j=1:length(logrankvals)
    %%         tmpy = [logrankvals(j) + 0;
    %%                 logrankvals(j) + 0;
    %%                 logrankvals(j) + cell_length;
    %%                 logrankvals(j) + cell_length];
    %%         
    %%         if (rand(1) < 0.3)
    %%             if (abs(i-j) < .01*(i+j)^2)
    %%                 factor = 1 - (i+j)/(10*length(logrankvals));
    %%                 tmph = fill(tmpx,tmpy,factor*[1 1 1]);
    %%                 set(tmph,'edgecolor',.9*factor*[1 1 1]);
    %%                 
    %%                 hold on;
    %%             end
    %%         end
    %%     end
    %% end



    %% indices_left = intersect(indices_left,topdownindices);
    %% indices_right = intersect(indices_right,topdownindices);

    %% %% left side, gel:
    %% 
    %% %% ordering is confusing but this works:
    %% tmph = loglog(mixedelements(2).counts_mod(indices_left_unique),...
    %%                  mixedelements(1).counts_mod(indices_left_unique),...
    %%                  'o');
    %% 
    %%    hold on;
    %% indices_left_unique
    
    %% 
    %% %% whos *unique*
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% hold on;
    %% 

    grid on;
    grid minor;

    %% 
    %% %% right side, gel:
    %% 
    %% tmph = loglog(mixedelements(2).counts_mod(indices_right_unique),...
    %%               mixedelements(1).counts_mod(indices_right_unique),...
    %%               'o');
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% %% middle side, gel:
    %% 
    %% tmph = loglog(mixedelements(2).counts_mod(indices_middle_unique),...
    %%              mixedelements(1).counts_mod(indices_middle_unique),...
    %%              'o');
    %% 
    %% set(tmph,'markerfacecolor',colors.paleblue);
    %% set(tmph,'markeredgecolor',colors.paleblue);
    %% 
    %% hold on;



    %% left side, points:

    pointsize = 1;

    %% tmph = plot(log10(mixedelements(2).counts_mod(indices_left_unique)),...
    %%               log10(mixedelements(1).counts_mod(indices_left_unique)),...
    %%               'o');
    %% set(tmph,'markerfacecolor',colors.blue);
    %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markersize',pointsize);

    hold on;

    %% right side, points:

    %% tmph = plot(log10(mixedelements(2).counts_mod(indices_right_unique)),...
    %%               log10(mixedelements(1).counts_mod(indices_right_unique)),...
    %%               'o');
    %% set(tmph,'markerfacecolor',colors.blue);
    %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markersize',pointsize);
    %% 
    %% hold on;

    %% middle, points:

    %% tmph = plot(log10(mixedelements(2).counts_mod(indices_middle_unique)),...
    %%               log10(mixedelements(1).counts_mod(indices_middle_unique)),...
    %%               'o');
    %% %% set(tmph,'markerfacecolor',colors.blue);
    %% %% set(tmph,'markeredgecolor',colors.blue);
    %% set(tmph,'markerfacecolor','k');
    %% set(tmph,'markeredgecolor','k');
    %% set(tmph,'markersize',pointsize);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add center line

    tmpcount1 = logspace(minlog10,maxlog10,100);
    tmph = plot(log10(tmpcount1),log10(tmpcount1),'-');

    hold on;

    %% grid on;

    set(tmph,'color','k');
    set(tmph,'linewidth',0.50);
    tmph.Color(4) = transparency_alpha;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% white out bottom square
    
    x_square = [minlog10, ...
                minlog10, ...
                zerolog10, ...
                zerolog10];
    y_square = [minlog10, ...
                zerolog10, ...
                zerolog10, ...
                minlog10];
    tmph = fill(x_square,y_square,'w');
    set(tmph,'edgecolor',colors.darkgrey);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% rotate to left-right view

    view(-45,90);
    set(gca,'FontName','Arial');
    set(gca,'fontsize',14);
    set(gca,'color','none');
    %% set(gca,'Color',colors.lightergrey);


    %% for use with layered plots
    %% set(gca,'box','off')

    %% adjust limits
    %% tmpv = axis;
    %% axis([]);
    xlim([minlog10 maxlog10]);
    ylim([minlog10 maxlog10]);

    %% adjust ticks

    tmpaxes(axesnum).TickLabelInterpreter='latex';

    %%     tmpxticks = get(gca,'xtick');
    %%     set(gca,'xtick',[tmpxticks(2) - min2zero_offset,tmpxticks(2:end)]);
    %%     tmpyticks = get(gca,'ytick');
    %%     set(gca,'ytick',[tmpyticks(2) - min2zero_offset,tmpyticks(2:end)]);

    tmpxticks = get(gca,'xtick');
    set(gca,'xtick',[zerolog10,tmpxticks(2:end)]);
    tmpyticks = get(gca,'ytick');
    set(gca,'ytick',[zerolog10,tmpyticks(2:end)]);
    set(gca,'FontName','Arial');

    
    clear tmpxticklabels_mod;
    tmpxticklabels = get(gca,'xticklabel');
    for i=2:length(tmpxticklabels)
        tmpexp = str2num(cell2mat(tmpxticklabels(i)));
        tmpxticklabels_mod{i} = sprintf('$10^{%d}$',tmpexp);
    end
    tmpxticklabels_mod{1} = '0';
    set(gca,'xticklabel',tmpxticklabels_mod)
    set(gca,'FontName','Arial');
    clear tmpyticklabels_mod;
    tmpyticklabels = get(gca,'yticklabel');
    for i=2:length(tmpyticklabels)
        tmpexp = str2num(cell2mat(tmpyticklabels(i)));
        tmpyticklabels_mod{i} = sprintf('$10^{%d}$',tmpexp);
    end
    tmpyticklabels_mod{1} = '0';
    set(gca,'yticklabel',tmpyticklabels_mod)
    set(gca,'FontName','Arial');

    %% change axis line width (default is 0.5)
    %% set(tmpaxes(axesnum),'linewidth',2)

    %% fix up tickmarks
    %% set(gca,'xtick',[1 100 10^4])
    %% set(gca,'xticklabel',{'','',''})
    %% set(gca,'ytick',[1 100 10^4])
    %% set(gca,'yticklabel',{'','',''})

    %% the following will usually not be printed 
    %% in good copy for papers
    %% (except for legend without labels)

    %% remove a plot from the legend
    %% set(get(get(tmph,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    %% %% legend

    %% tmplh = legend('stuff',...);
    %% tmplh = legend('','','');
    %% 
    %% tmplh.Interpreter = 'latex';
    %% set(tmplh,'position',get(tmplh,'position')-[x y 0 0])
    %% %% change font
    %% tmplh_obj = findobj(tmplh,'type','text');
    %% set(tmplh_obj,'FontSize',18);
    %% %% remove box:
    %% legend boxoff

    %% use latex interpreter for text, sans Arial

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% add words along edges of count turbulence histogram
    %% 
    %% space out vertically to prevent overlap
    %% 
    %% optional: include words that are requested
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf(1,['Using binwidth=%g for annotations in main plot ' ...
               '(default)\n\n'],binwidth);

    %%    Nbins = 40 - 1;
    %%    binwidth = (max(yrotated) - min(yrotated))/Nbins;
    wordbins = [min(yrotated):binwidth:max(yrotated)+binwidth];

    for ibin = 1:length(wordbins)-1
        indices = find((yrotated >= wordbins(ibin)) & (yrotated < wordbins(ibin+1)));
        
        %%%%%%%%%%%%%
        %% left side
        [delta,inceptionindex] = max(deltas_loss(indices));

        if ((length(inceptionindex) > 0) & (delta > 0))
            index = indices(inceptionindex);
            
            word = char(mixedelements(1).types(index));

            word_othercount = mixedelements(2).counts(index);
            if (length(word) > settings.max_plot_string_length)
                word = [word(1:settings.max_plot_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
            end
            if (word_othercount == 0)
                %%                word = [word, '\,$\bullet$'];
                %%                word = ['$\triangleleft$\,',word];
            end
            
            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');


            %% fprintf(1,'%s, %g\n',word,delta);
            
            yrotcenter = wordbins(ibin) + binwidth/2;
            xrot = xrotated(index);
            
            p1 = 10.^(1/sqrt(2)*(yrotcenter - xrot));
            p2 = 10.^(1/sqrt(2)*(yrotcenter + xrot));

            %%        tmpXcoords(ibin) = log10(1.10*mixedelements(2).counts_mod(index));
            %%        tmpYcoords(ibin) = log10(0.90*mixedelements(1).counts_mod(index));

            tmpXcoords(ibin) = log10(0.90*p2);
            tmpYcoords(ibin) = log10(1.10*p1);
            
            if (rem(ibin,2)==1)
                %%            tmphrightwords(i).Color = 'k';
                tmpcolor = 'k';
            else
                %%            tmphrightwords(i).Color = colors.darkergrey;
                tmpcolor = colors.darkergrey;
            end

            tmphleftwords(ibin) = text(tmpXcoords(ibin),tmpYcoords(ibin),...
                                       word,...
                                       'FontName','Arial',...
                                       'fontsize',16,...
                                       'units','data',...
                                       'horizontalalignment','right',...
                                       'color',tmpcolor,...
                                       'interpreter','latex');
            %%                    'rotation',rand(1)*20-5,...
        end
        
        %%    fprintf(1,'\n');

        %%%%%%%%%%%%%
        %% right side

        [delta,inceptionindex] = max(deltas_gain(indices));

        if ((length(inceptionindex) > 0) & (delta >= 0))
            index = indices(inceptionindex);
            
            word = char(mixedelements(1).types(index));

            word_othercount = mixedelements(1).counts(index);
            if (length(word) > settings.max_plot_string_length)
                word = [word(1:settings.max_plot_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
            end
            if (word_othercount == 0)
                %%%                word = ['$\bullet$\,',word];
                %%                               word = ['$\triangleright$\,',word];
            end
            
            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');


            %%        fprintf(1,'%s, %g\n',word,delta);

            %%        tmpXcoords(ibin) = log10(0.90*mixedelements(2).counts_mod(index));
            %%        tmpYcoords(ibin) =
            %%        log10(1.10*mixedelements(1).counts_mod(index));
            
            yrotcenter = wordbins(ibin) + binwidth/2;
            xrot = xrotated(index);
            
            r1 = 10.^(1/sqrt(2)*(yrotcenter - xrot));
            r2 = 10.^(1/sqrt(2)*(yrotcenter + xrot));

            %%        tmpXcoords(ibin) = log10(1.10*mixedelements(2).counts_mod(index));
            %%        tmpYcoords(ibin) = log10(0.90*mixedelements(1).counts_mod(index));

            tmpXcoords(ibin) = log10(1.10*r2);
            tmpYcoords(ibin) = log10(0.90*r1);


            if (rem(ibin,2)==1)
                %%            tmphrightwords(i).Color = 'k';
                tmpcolor = 'k';
            else
                %%            tmphrightwords(i).Color = colors.darkergrey;
                tmpcolor = colors.darkergrey;
            end

            tmphrightwords(ibin) = text(tmpXcoords(ibin),tmpYcoords(ibin),...
                                        word,...
                                        'FontName','Arial',...
                                        'fontsize',16,...
                                        'units','data',...
                                        'horizontalalignment','left',...
                                        'color',tmpcolor,...
                                        'interpreter','latex');
            %%                    'rotation',rand(1)*20-5,...
        end

    end


    %% some labels
    topleftwordindices = indices_left;
    %% include top word
    topwordindices = topleftwordindices(1:min(length(topleftwordindices)),settings.topNhistogram);

    %% most extreme:
    indices = find(mixedelements(2).counts_mod == max(mixedelements(2).counts_mod));
    [tmp,index] = min(mixedelements(1).counts_mod(indices));
    extremeindex = indices(index);

    mixedelements(1).types(extremeindex);
    mixedelements(1).counts_mod(extremeindex);
    mixedelements(2).counts_mod(extremeindex);


    topwordindices = unique([...
        topleftwordindices(1:min(length(topleftwordindices),settings.topNhistogram))]);
    %%                        extremeindex]);

    %% sort by vertical position
    [tmp, indices] = sort(yrotated(topwordindices),'ascend');
    topwordindices = topwordindices(indices);

    clear tmpleftwords
    clear tmprightwords

    vertratio = 1.25;
    horizratio = 2;


    for i=1:length(topwordindices)
        j = topwordindices(i);
        word = mixedelements(1).types(j);
        if (length(word) > settings.max_shift_string_length)
            word = [word(1:settings.max_shift_string_length-6),...
                    '...',...
                    word(end-2:end),...
                   ];
        end
        tmpword = sprintf('%s',word{1});
        
        tmpXcoords(i) = log10(0.90*mixedelements(2).counts_mod(j));
        tmpYcoords(i) = log10(1.10*mixedelements(1).counts_mod(j));

        %% check for overlap with preceding text
        tmpcolor = 'k';
        if (i > 1)
            jprev = topwordindices(i-1);
            if (yrotated(j)/vertratio < ...
                yrotated(jprev))
                tmpcolor = 'k';
            end
        end
        
        %%    tmphleftwords(i) = text(tmpXcoords(i),tmpYcoords(i),...
        %%                            tmpword,...
        %%                            'fontsize',14,...
        %%                            'units','data',...
        %%                            'horizontalalignment','right',...
        %%                            'color',tmpcolor,...
        %%                            'interpreter','latex');
        %%    %%                    'rotation',rand(1)*20-5,...
    end

    %%for prune_index = 1:5
    %%    for i=1:length(tmphleftwords)
    %%        tmppos = tmphleftwords(i).Position;
    %%        tmpxpos(i) = (tmppos(1) - tmppos(2))/sqrt(2);
    %%        tmpypos(i) = (tmppos(1) + tmppos(2))/sqrt(2);
    %%    end
    %%
    %%    %%    ratios = yrotated(topwordindices(2:end))./ ...
    %%    %%             yrotated(topwordindices(1:end-1));
    %%    
    %%    %% hardpush(log10(tmpxpos),log10(tmpypos),.1,10);
    %%
    %%    %% logarithmic differences
    %%    xratios = tmpxpos(2:end)./tmpxpos(1:end-1);
    %%    yratios = tmpypos(2:end)./tmpypos(1:end-1);
    %%    xratios(find(xratios<1)) = xratios(find(xratios<1)).^-1;
    %%    
    %%    shiftratio = 1.05;
    %%    j=1;
    %%    for i=2:length(tmphleftwords)
    %%        if (yratios(i-1) < vertratio)
    %%            if (xratios(i-1) < horizratio)
    %%                tmphleftwords(i).Visible = 'off'; %% too close
    %%                %% move texts out
    %%                %%                tmppos = tmphleftwords(i-1).Position;
    %%                %%                tmphleftwords(i).Position = ...
    %%                %%                    [tmppos(1)*shiftratio, tmppos(2)/shiftratio, 0];
    %%            end
    %%        end
    %%        if (strcmp(tmphleftwords(i).Visible,'on')==1)
    %%            tmphleftwords_new(j) = tmphleftwords(i);
    %%            j=j+1;
    %%        end
    %%    end
    %%    tmphleftwords = tmphleftwords_new;
    %%    clear tmphleftwords_new;
    %%end
    %%
    %%j=0;
    %%for i=1:length(tmphleftwords)
    %%    if (strcmp(tmphleftwords(i).Visible,'on')==1)
    %%        j=j+1;
    %%        if (rem(j,2)==1)
    %%            tmphleftwords(i).Color = 'k';
    %%        else
    %%            tmphleftwords(i).Color = colors.darkergrey;
    %%        end
    %%    end
    %%end

    %%% right side

    toprightwordindices = find(mixedelements(1).counts_mod <= mixedelements(2).counts_mod);

    %% find extra pieces
    %% top:
    topindex = find(strcmp(mixedelements(1).types,'rt'));
    %% most extreme:
    indices = find(mixedelements(1).counts_mod == max(mixedelements(1).counts_mod));
    [tmp,index] = min(mixedelements(2).counts_mod(indices));
    extremeindex = indices(index);

    mixedelements(1).types(extremeindex);
    mixedelements(1).counts_mod(extremeindex);
    mixedelements(2).counts_mod(extremeindex);

    topwordindices = unique([topindex; ...
                        toprightwordindices(1:min(length(toprightwordindices),settings.topNhistogram))]);
    %%                        extremeindex]);

    %% sort by vertical position
    [tmp, indices] = sort(yrotated(topwordindices),'ascend');
    topwordindices = topwordindices(indices);

    %%for i=1:length(topwordindices)
    %%    j = topwordindices(i);
    %%    word = mixedelements(1).types(j);
    %%    tmpword = sprintf('%s',word{1});
    %%
    %%    tmpXcoord = 0.90*mixedelements(2).counts_mod(j);
    %%    tmpYcoord = 1.10*mixedelements(1).counts_mod(j);
    %%
    %%    %% check for overlap with preceding text
    %%    tmpcolor = 'k';
    %%    if (i > 1)
    %%        jprev = topwordindices(i-1);
    %%        if (yrotated(j)/1.3 < ...
    %%            yrotated(jprev))
    %%            tmpcolor = 'k';
    %%        end
    %%    end
    %%
    %%    tmphrightwords(i) = text(tmpXcoord,tmpYcoord,...
    %%                             tmpword,...
    %%                             'fontsize',14,...
    %%                             'units','data',...
    %%                             'horizontalalignment','left',...
    %%                             'color',tmpcolor,...
    %%                             'interpreter','latex');
    %%    %%                    'rotation',rand(1)*20-5,...
    %%end
    %%
    %%%%    tmphrightwords = tmphrightwords(1:end-1);
    %%for prune_index = 1:5
    %%    for i=1:length(tmphrightwords)
    %%        tmppos = tmphrightwords(i).Position;
    %%        tmpxpos(i) = (tmppos(1) - tmppos(2))/sqrt(2);
    %%        tmpypos(i) = (tmppos(1) + tmppos(2))/sqrt(2);
    %%    end
    %%
    %%    %%    ratios = yrotated(topwordindices(2:end))./ ...
    %%    %%             yrotated(topwordindices(1:end-1));
    %%    
    %%    %% hardpush(log10(tmpxpos),log10(tmpypos),.1,10);
    %%
    %%    %% logarithmic differences
    %%    xratios = tmpxpos(2:end)./tmpxpos(1:end-1);
    %%    yratios = tmpypos(2:end)./tmpypos(1:end-1);
    %%    xratios(find(xratios<1)) = xratios(find(xratios<1)).^-1;
    %%    
    %%    shiftratio = 1.05;
    %%    j=1;
    %%    for i=2:length(tmphrightwords)
    %%        if (yratios(i-1) < vertratio)
    %%            if (xratios(i-1) < horizratio)
    %%                tmphrightwords(i).Visible = 'off'; %% too close
    %%                %% move texts out
    %%                %%                tmppos = tmphrightwords(i-1).Position;
    %%                %%                tmphrightwords(i).Position = ...
    %%                %%                    [tmppos(1)*shiftratio, tmppos(2)/shiftratio, 0];
    %%            end
    %%        end
    %%        if (strcmp(tmphrightwords(i).Visible,'on')==1)
    %%            tmphrightwords_new(j) = tmphrightwords(i);
    %%            j=j+1;
    %%        end
    %%    end
    %%    tmphrightwords = tmphrightwords_new;
    %%    clear tmphrightwords_new;
    %%end
    %%
    %%j=0;
    %%for i=1:length(tmphrightwords)
    %%    if (strcmp(tmphrightwords(i).Visible,'on')==1)
    %%        j=j+1;
    %%        if (rem(j,2)==1)
    %%            tmphrightwords(i).Color = 'k';
    %%        else
    %%            tmphrightwords(i).Color = colors.darkergrey;
    %%        end
    %%    end
    %%end





    %%%%%%%%%%%%%%%%%%%%
    %% axis labels
    %%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%
    %% left, system 1
    %%%%%%%%%%%%%%%%%%%%

    %%    tmpstrless{1} = '$\leftarrow$ less talked about';
    tmpstrless{1} = 'less';
    tmpstrless{2} = '\ \ \ \ talked $\rightarrow$';
    tmpstrless{3} = 'about';

    clear tmpstrmore;
    %%    tmpstrmore{1} = 'more talked about $\rightarrow$';
    tmpstrmore{1} = 'more';
    tmpstrmore{2} = '$\leftarrow$ talked\ \ \ \ ';
    tmpstrmore{3} = 'about';

    tmpXcoord = 0.32;
    tmpYcoord = 0.000;
    text(tmpXcoord,tmpYcoord,tmpstrless,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',-45,...
         'interpreter','latex')

    %%     'verticalalignment','middle',...

    tmpXcoord = 0.005;
    tmpYcoord = 0.32;
    text(tmpXcoord,tmpYcoord,tmpstrmore,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',-45,...
         'interpreter','latex')

    %%     'verticalalignment','middle',...


    %%    tmpxlabstr = {'Word Count $k$','for'};
    tmpxlabstr = {'Count $k$','for'};

    tmpxlabstr{end+1} = sprintf('%s',settings.system1_name_short);

    tmpXcoord = 0.16;
    tmpYcoord = 0.16;
    tmph = text(tmpXcoord,tmpYcoord,tmpxlabstr,...
                 'FontName','Arial',...
                'fontsize',18,...
                'units','normalized',...
                'horizontalalignment','center',...
                'rotation',-45,...
                'interpreter','latex');

    %% tmpxlab=xlabel(tmpxlabstr,...
    %%     'fontsize',16,...
    %%     'verticalalignment','top',...
    %%     'interpreter','latex');


    %%%%%%%%%%%%%%%%%%%%
    %% right, system 2
    %%%%%%%%%%%%%%%%%%%%

    clear tmpstrless;
    %%    tmpstrless{1} = '$\leftarrow$ less talked about';
    tmpstrless{1} = 'less';
    tmpstrless{2} = '$\leftarrow$ talked\ \ \ \ ';
    tmpstrless{3} = 'about';

    clear tmpstrmore;
    %%    tmpstrmore{1} = 'more talked about $\rightarrow$';
    tmpstrmore{1} = 'more';
    tmpstrmore{2} = '\ \ \ \ talked $\rightarrow$';
    tmpstrmore{3} = 'about';

    tmpXcoord = 0.68;
    tmpYcoord = 0.01;
    text(tmpXcoord,tmpYcoord,tmpstrless,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',45,...
         'interpreter','latex')

    %%     'verticalalignment','middle',...

    tmpXcoord = 0.99;
    tmpYcoord = 0.31;
    text(tmpXcoord,tmpYcoord,tmpstrmore,...
        'FontName','Arial',...
         'fontsize',18,...
         'units','normalized',...
         'color',colors.darkgrey,...
         'horizontalalignment','center',...
         'rotation',45,...
         'interpreter','latex')

    %%     tmpylabstr = {'Word Count $k$','for'};

    tmpylabstr = {'Count $k$','for'};
    tmpylabstr{end+1} = sprintf('%s',settings.system2_name_short);

    %% tmpylab=ylabel(tmpylabstr,...
    %%     'fontsize',16,...
    %%     'verticalalignment','bottom',...
    %%     'interpreter','latex');

    tmpXcoord = 0.84;
    tmpYcoord = 0.16;
    tmph = text(tmpXcoord,tmpYcoord,tmpylabstr,...
               'FontName','Arial',...
                'fontsize',18,...
                'units','normalized',...
                'horizontalalignment','center',...
                'rotation',45,...
                'interpreter','latex');


    %%%%%%%%%%%%
    %% title

    %% tmpstr = 'Rank comparison plot';
    %% 
    %% tmpXcoord = 0.00;
    %% tmpYcoord = 1.00;
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%             'fontsize',18,...
    %%             'units','normalized',...
    %%             'horizontalalignment','left',...
    %%             'verticalalignment','top',...
    %%             'rotation',0,...
    %%             'interpreter','latex');


    %% set(tmpxlab,'position',get(tmpxlab,'position') - [0 .1 0]);
    %% set(tmpylab,'position',get(tmpylab,'position') - [.1 0 0]);

    %% set 'units' to 'data' for placement based on data points
    %% set 'units' to 'normalized' for relative placement within axes
    %% tmpXcoord = ;
    %% tmpYcoord = ;
    %% tmpstr = sprintf(' ');
    %% or
    %% tmpstr{1} = sprintf(' ');
    %% tmpstr{2} = sprintf(' ');
    %%
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%     'fontsize',20,...
    %%     'units','normalized',...
    %%     'interpreter','latex')

    %% label (A, B, ...)
    %% tmplabelh = addlabel4(' A ',0.02,0.9,20);
    %% tmplabelh = addlabel5(loop_i,0.02,0.9,20);
    %% or:
    %% tmplabelXcoord= 0.015;
    %% tmplabelYcoord= 0.88;
    %% tmplabelbgcolor = 0.85;
    %% tmph = text(tmplabelXcoord,tmplabelYcoord,...
    %%    ' A ',...
    %%    'fontsize',24,
    %%         'units','normalized');
    %%    set(tmph,'backgroundcolor',tmplabelbgcolor*[1 1 1]);
    %%    set(tmph,'edgecolor',[0 0 0]);
    %%    set(tmph,'linestyle','-');
    %%    set(tmph,'linewidth',1);
    %%    set(tmph,'margin',1);

    %% rarely used (text command is better)
    %% title(' ','fontsize',24,'interpreter','latex')
    %% 'horizontalalignment','left');
    %% tmpxl = xlabel('','fontsize',24,'verticalalignment','top');
    %% set(tmpxl,'position',get(tmpxl,'position') - [ 0 .1 0]);
    %% tmpyl = ylabel('','fontsize',24,'verticalalignment','bottom');
    %% set(tmpyl,'position',get(tmpyl,'position') - [ 0.1 0 0]);
    %% title('','fontsize',24)


else
    error('No plot type specificed');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT: inset showing heatmap legend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (~strcmp(settings.turbulencegraph.labels,'off')) 
    axesnum = 3;
    tmpaxes_inset_heatmap = axes('position',axes_positions(axesnum).box);

    Nboxes = 20;
    countlevels = logspace(0,maxcountslog10,Nboxes);
    levels = linspace(10^4,1,Nboxes);

    for i=1:1:Nboxes
        colorindex = floor(levels(i));
        if (colorindex == 0)
            colorindex = 1;
        end
        if (colorindex > 10^4)
            colorindex = 10^4;
        end

        tmpx = [0 1 1 0];
        tmpy = [0 0 1 1] + i;
        tmph = fill(tmpx,tmpy,heatmapcolors(colorindex,:));
        set(tmph,'edgecolor',.7*heatmapcolors(colorindex,:));
        hold on;
    end

    exponents = [0:1:maxcountslog10];
    labels = 10.^exponents;

    for i=1:length(exponents)
        clear tmpstr;

        %%    tmpstr = sprintf('10$^{%g}$',exponents(i));
        tmpstr = sprintf('%s',addcommas(labels(i)));

        tmpXcoord = 1.5;
        tmpYcoord = (0.25  + exponents(i))*(Nboxes-1)/max(exponents);
        tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                    'FontName','Arial',...
                    'fontsize',16,...
                    'units','data',...
                    'horizontalalignment','left',...
                    'verticalalignment','middle',...
                    'interpreter','latex');


    end

    clear tmpstr;
    tmpstr = sprintf('Counts per cell');

    tmpXcoord = 0;
    tmpYcoord = (2.5 + Nboxes);
    tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
               'FontName','Arial',...
                'fontsize',16,...
                'units','data',...
                'horizontalalignment','left',...
                'verticalalignment','middle',...
                'interpreter','latex');



    xlim([0, Nboxes]);
    ylim([1, Nboxes+1]);
    set(gca,'FontName','Arial');
    set(gca,'visible','off');
    set(gca,'ydir','reverse');
end


%%%%%%%%%%%%%%%%%%%%%
%% PLOT: title, equation
%%%%%%%%%%%%%%%%%%%%%

axesnum = 5;
tmpaxes_title = axes('position',axes_positions(axesnum).box);

set(gca,'visible','off');
set(gca,'FontName','Arial');
%% tmpstr = sprintf('\\textbf{$\\Omega_{1}$: %s}',...
tmpstr = sprintf('$\\Omega_{1}$: %s',...
                 settings.system1_name);
tmpXcoords = 0.40;
tmpYcoords = 0.98;

if (~strcmp(settings.turbulencegraph.labels,'off')) 
    tmph = text(tmpXcoords,tmpYcoords,...
                tmpstr,...
                'FontName','Arial',...
                'fontsize',18,...
                'units','normalized',...
                'horizontalalignment','right',...
                'color',colors.verydarkgrey,...
                'interpreter','latex');
end

clear tmpstr;
%% tmpstr = sprintf('\\textbf{$\\Omega_{2}$: %s}',...
tmpstr = sprintf('$\\Omega_{2}$: %s',...
                 settings.system2_name);
tmpXcoords = 0.60;
tmpYcoords = 0.98;

if (~strcmp(settings.turbulencegraph.labels,'off')) 
    tmph = text(tmpXcoords,tmpYcoords,...
                tmpstr,...
                'FontName','Arial',...
                'fontsize',18,...
                'units','normalized',...
                'horizontalalignment','left',...
                'color',colors.verydarkgrey,...
                'interpreter','latex');
end

clear tmpstr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% following sections sets up text for 
%% instrument's specific expression and score,
%% and then adds to the top left corner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(settings.instrument,'alpha divergence type 2'))

    tmpstr{1} = sprintf('Instrument: \\bf %s', ...
                        title_str_abbrv);

    %%    tmpstr{end+1} = title_str_mod{1};
    %%    tmpstr{end+1} = sprintf('%s with $\\alpha=%s$', ...
    %%                            title_str_mod{2}, ...
    %%                            alpha_str);

    %%    if (settings.alpha == 0)
    %%        tmpstr{end+1} = '(Jenson-Shannon Divergence)';
    %%    end
    
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';


    if (settings.alpha == 0)

        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{0}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2})' ...
                            '= \\sum_{\\tau}' ... '
                            '\\delta D_{%s,\\tau}^{\\rm %s}$'],...
                                divergence_superscript_str, ...
                                alpha_str, ...
                                divergence_superscript_str);


        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            '=' ...
                            '\\frac{1}{2}' ...
                            '\\sum_{\\tau}' ...
                            '\\bigg[' ...
                            'p_{\\tau}^{(1)}' ...
                            '\\ln '...
                            '\\frac{2p_{\\tau}^{(1)}}' ...
                            '{p_{\\tau}^{(1)} + p_{\\tau}^{(2)}}$']);
        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            '+\\,\\,' ...
                            'p_{\\tau}^{(2)}' ...
                            '\\ln '...
                            '\\frac{2p_{\\tau}^{(2)}}' ...
                            '{p_{\\tau}^{(1)} + p_{\\tau}^{(2)}}' ...
                            '\\bigg]' ...
                            '$']);

        tmpstr{end+1} = '\mbox{}';
        
        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            '=' ...
                            'D^{\\rm JS}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2})$']);
    else
        prefactor = 0.5/((settings.alpha - 1)*settings.alpha);
        [n_prefactor,d_prefactor] = rat(0.5/((settings.alpha - 1)*settings.alpha));
        [n_exponent1,d_exponent1] = rat(1 - settings.alpha);
        [n_exponent2,d_exponent2] = rat(settings.alpha);

        if (d_prefactor == 1)
            if (n_prefactor == 1)
                prefactor_str = '';
            else
                prefactor_str = sprintf('%d',...
                                        n_prefactor);
            end
        else
            prefactor_str = sprintf('\\frac{%d}{%d}',...
                                    n_prefactor,...
                                    d_prefactor);
        end

        if (d_exponent1 == 1)
            exponent1_str = sprintf('%d',...
                                    n_exponent1);
        else
            exponent1_str = sprintf('%d/%d',...
                                    n_exponent1,...
                                    d_exponent1);
        end

        if (d_exponent2 == 1)
            exponent2_str = sprintf('%d',...
                                    n_exponent2);
        else
            exponent2_str = sprintf('%d/%d',...
                                    n_exponent2,...
                                    d_exponent2);
        end

        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{%s}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2}) ' ...
                            ' = ' ...
                            '\\sum_{\\tau}' ... '
                            '\\delta D_{%s,\\tau}^{\\rm %s}$'],...
                                alpha_str, ...
                                divergence_superscript_str, ...
                                alpha_str, ...
                                divergence_superscript_str);

        tmpstr{end+1} = sprintf(['$\\displaystyle  ' ...
                            ' = ' ...
                            '%s' ...
                            '\\sum_{\\tau}' ...
                            '\\bigg[' ...
                            '\\left(' ...
                            'p_{\\tau,2}^{%s}' ...
                            ' + ' ...
                            'p_{\\tau,1}^{%s}' ...
                            '\\right)$'], ...
                                prefactor_str, ...
                                exponent1_str, ...
                                exponent1_str);

        tmpstr{end+1} = sprintf(['$\\displaystyle  ' ...
                            '\\times\\,\\left(' ...
                            '\\frac{p_{\\tau,1}' ...
                            ' + ' ...
                            'p_{\\tau,2}}{2}' ...
                            '\\right)^{%s}$'], ...
                                alpha_str);

        
        tmpstr{end+1} = sprintf(['$\\displaystyle  ' ...
                            ' - ' ...
                            '\\left(' ...
                            'p_{\\tau,1}' ...
                            ' + ' ...
                            'p_{\\tau,2}' ...
                            '\\right)' ...
                            '\\bigg]$']);

    end
    
elseif (strcmp(settings.instrument,'probability divergence'))

    tmpstr{1} = sprintf('Instrument: \\bf %s', ...
                        title_str_abbrv);

    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    
    if (settings.alpha == 0) 
        %%         tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
        %%                             'D_{0}^{\\rm %s}' ...
        %%                             '(\\Omega_{1}\\,\\|\\,\\Omega_{2})' ...
        %%                             '= \\sum_{\\tau} \\delta D_{%s,\\tau}^{\\rm %s}$'], ...
        %%                             divergence_superscript_str, ...
        %%                             alpha_str, ...
        %%                             divergence_superscript_str);

        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{0}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2}) = %.3f$'], ...
                                divergence_superscript_str, ...
                                divergence_score);
        
        %%         tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
        %%                             '= \\ln' ...
        %%                             '\\frac{' ...
        %%                             '\\max' ...
        %%                             '\\left\\{p_{\\tau,1},p_{\\tau,2}\\right\\}}' ...
        %%                             '{\\min' ...
        %%                             '\\left\\{p_{\\tau,1},p_{\\tau,2}\\right\\}}$']);

        %%        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
        %%                            '= \\left|\\ln\\frac{p_{\\tau}^{(1)}}{p_{\\tau}^{(2)}}\\right|$']);
        
        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            '= \\frac{1}{N_{1} + N_{2}} \\sum_{\\tau} ' ...
                            '\\left(\\delta_{p_{\\tau,1},0} + \\delta_{0,p_{\\tau,2}}\\right)$']);
        tmpstr{end+1} = sprintf('\\,');
    elseif (settings.alpha == Inf)

        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{\\infty}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2}) = %.3f$'], ...
                                divergence_superscript_str, ...
                                divergence_score);

        tmpstr{end+1} = sprintf(['$\\displaystyle' ...
                            '= \\frac{1}{2}\\sum_{\\tau}' ...
                            '\\left(' ...
                            '1 - \\delta_{p_{\\tau,1},p_{\\tau,2}}' ...
                            '\\right)$']);
        tmpstr{end+1} = sprintf(['$\\displaystyle' ...
                            '\\times\\,\\max' ...
                            '\\left\\{' ...
                            'p_{\\tau,1}' ... 
                            ',' ...
                            'p_{\\tau,2}' ... 
                            '\\right\\}$']);
        
%%         tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
%%                             'D_{\\infty}^{\\rm %s}' ...
%%                             '(\\Omega_{1}\\,\\|\\,\\Omega_{2})' ...
%%                             '= \\sum_{\\tau} \\delta D_{%s,\\tau}^{\\rm %s}$'], ...
%%                             divergence_superscript_str, ...
%%                             alpha_str, ...
%%                             divergence_superscript_str);
%%         tmpstr{end+1} = sprintf(['$\\displaystyle' ...
%%                             '= \\sum_{\\tau}' ...
%%                             '\\left(' ...
%%                             '1 - \\delta_{p_{\\tau}^{(1)},p_{\\tau}^{(2)}}' ...
%%                             '\\right)$']);
%%         tmpstr{end+1} = sprintf(['$\\displaystyle' ...
%%                             '\\times\\,\\max' ...
%%                             '\\left\\{' ...
%%                             'p_{\\tau,1}' ... 
%%                             ',' ...
%%                             'p_{\\tau,2}' ... 
%%                             '\\right\\}$']);

    else
        [n_prefactor,d_prefactor] = rat((settings.alpha + 1)/settings.alpha);
        [n_exponent,d_exponent] = rat(1/(settings.alpha + 1));

        if (d_prefactor == 1)
            if (n_prefactor == 1)
                prefactor_str = '';
            else
                prefactor_str = sprintf('%d',...
                                        n_prefactor);
            end
        else
            prefactor_str = sprintf('\\frac{%d}{%d}',...
                                    n_prefactor,...
                                    d_prefactor);
        end

        if (d_exponent == 1)
            exponent_str = sprintf('%d',...
                                   n_exponent);
        else
            exponent_str = sprintf('%d/%d',...
                                   n_exponent,...
                                   d_exponent);
        end

        %%         tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
        %%                             'D_{%s}^{\\rm %s}' ...
        %%                             '(\\Omega_{1}\\,\\|\\,\\Omega_{2})' ...
        %%                             '= \\sum_{\\tau} \\delta D_{%s,\\tau}^{\\rm %s}$'], ...
        %%                                 alpha_str, ...
        %%                                 divergence_superscript_str, ...
        %%                                 alpha_str, ...
        %%                                 divergence_superscript_str);
        
        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{%s}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2}) = %.3f$'], ...
                                alpha_str, ...
                                divergence_superscript_str, ...
                                divergence_score);

        %%         tmpstr{end+1} = sprintf(['$\\displaystyle = ' ...
        %%                             '%s' ...
        %%                             '\\sum_{\\tau}' ...
        %%                             '\\left|' ...
        %%                             'p_{\\tau,2}^{%s}' ...
        %%                             ' - ' ...
        %%                             'p_{\\tau,2}^{%s}' ...
        %%                             '\\right|^{%s}$'], ...
        %%                             prefactor_str,...
        %%                             alpha_str, ...
        %%                             alpha_str, ...
        %%                             exponent_str);

        %% turning this off
        prefactor_str = '';
        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            '%s' ...
                            '\\propto' ...
                            '\\sum_{\\tau}' ...
                            '\\left|' ...
                            'p_{\\tau,1}^{%s}' ...
                            ' - ' ...
                            'p_{\\tau,2}^{%s}' ...
                            '\\right|^{%s}$'], ...
                                prefactor_str,...
                                alpha_str, ...
                                alpha_str, ...
                                exponent_str);


    end
    
elseif (strcmp(settings.instrument,'rank divergence'))    
    tmpstr{1} = sprintf('Instrument: {\\bf %s}', ...
                        title_str_abbrv);

    %%    tmpstr{end+1} = sprintf('%s with $\\alpha=%s$', ...
    %%                            title_str, ...
    %%                            alpha_str);

    %%    tmpstr{end+1} = sprintf('{\\bf %s}', ...
    %%                            title_str);
    
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';
    tmpstr{end+1} = '\mbox{}';

    if (settings.alpha == 0) 
        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{0}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2}) = %.3f$'], ...
                                divergence_superscript_str, ...
                                divergence_score);
        
        tmpstr{end+1} = '\mbox{}';
                            
%%                             'Omega_{1}\\,\\|\\,\\Omega_{2})' ...
%%                             '= \\sum_{\\tau} \\delta D_{%s,\\tau}^{\\rm %s}$'], ...
%%                             divergence_superscript_str, ...
%%                             alpha_str, ...
%%                             divergence_superscript_str);

%%         tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
%%                             '= \\sum_{\\tau}' ...
%%                             '\\ln' ...
%%                             '\\frac{' ...
%%                             '\\max' ...
%%                             '\\left\\{r_{\\tau,1},r_{\\tau,2}\\right\\}}' ...
%%                             '{\\min' ...
%%                             '\\left\\{r_{\\tau,1},r_{\\tau,2}\\right\\}}$']);

        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            '\\propto \\sum_{\\tau}' ...
                            '\\left|\\ln\\frac{r_{\\tau,1}}{r_{\\tau,2}}\\right|$']);
        tmpstr{end+1} = sprintf('\\,');
    elseif (settings.alpha == Inf)
        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{\\infty}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2}) = %.3f$'], ...
                                divergence_superscript_str, ...
                                divergence_score);
        tmpstr{end+1} = '\mbox{}';
        
        %%                            '= \\sum_{\\tau} \\delta D_{%s,\\tau}^{\\rm %s}$'], ...
        
        tmpstr{end+1} = sprintf(['$\\displaystyle' ...
                            '\\propto \\sum_{\\tau}' ...
                            '\\left(' ...
                            '1 - \\delta_{r_{\\tau,1},r_{\\tau,2}}' ...
                            '\\right)$']);
        tmpstr{end+1} = sprintf(['$\\displaystyle' ...
                            '\\, \\times \\max' ...
                            '\\left\\{' ...
                            '\\frac{1}{r_{\\tau,1}}' ... 
                            ',' ...
                            '\\frac{1}{r_{\\tau,2}}' ... 
                            '\\right\\}$']);
        
        %%                            '\\frac{1}{r_{\\tau}^{(1)}}' ... 
        %%                            '\\frac{1}{r_{\\tau}^{(2)}}' ... 

    else
        [n_prefactor,d_prefactor] = rat((settings.alpha + 1)/settings.alpha);
        [n_exponent,d_exponent] = rat(1/(settings.alpha + 1));

        if (d_prefactor == 1)
            if (n_prefactor == 1)
                prefactor_str = '';
            else
                prefactor_str = sprintf('%d',...
                                        n_prefactor);
%%                 prefactor_str = sprintf('\\frac{%d}{\\mathcal{N}_{1,2;%s}}',...
%%                                         n_prefactor,...
%%                                         alpha_frac_str);
            end
        else
            prefactor_str = sprintf('\\frac{%d}{%d}',...
                                    n_prefactor,...
                                    d_prefactor);
        end

        if (d_exponent == 1)
            exponent_str = sprintf('%d',...
                                   n_exponent);
        else
            exponent_str = sprintf('%d/%d',...
                                   n_exponent,...
                                   d_exponent);
        end
        
        prefactor_str = sprintf('a_{1,2;%s}', ...
                                alpha_frac_str);
        
        prefactor_str = '';

        %%         tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
        %%                             'D_{%s}^{\\rm %s}' ...
        %%                             '(\\Omega_{1}\\,\\|\\,\\Omega_{2})' ...
        %%                             '= \\sum_{\\tau} \\delta D_{%s,\\tau}^{\\rm %s}$'], ...
        %%                             alpha_str, ...
        %%                             divergence_superscript_str, ...
        %%                             alpha_str, ...
        %%                             divergence_superscript_str);

        tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
                            'D_{%s}^{\\rm %s}' ...
                            '(\\Omega_{1}\\,\\|\\,\\Omega_{2}) = %.3f$'], ...
                                alpha_str, ...
                                divergence_superscript_str, ...
                                divergence_score);

        %% note: prefactor_str = '';
        %% change in normalization
        tmpstr{end+1} = sprintf(['$\\displaystyle  ' ...
                            '%s' ...
                            '\\propto' ...
                            '\\sum_{\\tau}' ...
                            '\\left|' ...
                            '\\frac{1}' ...
                            '{r_{\\tau,1}^{%s}}' ...
                            ' - ' ...
                            '\\frac{1}' ...
                            '{r_{\\tau,2}^{%s}}' ...
                            '\\right|^{%s}$'], ...
                                prefactor_str, ...
                                alpha_str, ...
                                alpha_str, ...
                                exponent_str);
        
        %%                            '{\\left[r_{\\tau}^{(1)}\\right]^{%s}}' ...
        %%                            '{\\left[r_{\\tau}^{(2)}\\right]^{%s}}' ...

    end
    
%%    tmpstr{end+1} = sprintf(['$\\displaystyle ' ...
%%                        '= \\sum_{\\tau} \\delta D_{%s,\\tau}^{\\rm %s}$'],...
%%                            alpha_str, ...
%%                            divergence_superscript_str);


elseif (strcmp(settings.instrument,'none'))
    %% do nothing
else
    error('instrument not recognized');
end





%%                    settings.alphapowerstr,...
%%                    settings.alphapowerstr,...
%%                    settings.alphainvstr);

%% tmpstr{4} = sprintf('$\\displaystyle D_{%s}^{\\rm R}(\\Omega_{1}\\,\\|\\,\\Omega_{2}) =$',...
%%                     settings.alphastr);
%% tmpstr{5} = sprintf('$\\displaystyle \\sum_{\\tau} \\left|\\frac{1}{\\left[r_{\\tau}^{(1)}\\right]^{%s}} - \\frac{1}{\\left[r_{\\tau}^{(2)}\\right]^{%s}}\\right|^{%s}$',...
%%                     settings.alphapowerstr,...
%%                     settings.alphapowerstr,...
%%                     settings.alphainvstr);

%% tmpstr{3} = sprintf('$\\displaystyle D_{%s}^{\\rm R}(\\Omega_{1}\\,\\|\\,\\Omega_{2}) = \\sum_{\\tau} \\left|\\frac{1}{\\left[r_{\\tau}^{(1)}\\right]^{%s}} - \\frac{1}{\\left[r_{\\tau}^{(2)}\\right]^{%s}}\\right|^{%s}$',...
%%                     settings.alphastr,...
%%                     settings.alphastr,...
%%                     settings.alphastr,...
%%                     settings.alphainvstr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% add text to top left corner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (~strcmp(settings.instrument,'none'))

    %% Not anymore: append with divergence score
    tmpstr{end+1} = '\mbox{}';

    %%    tmpstr{end+1} = sprintf('= %0.3f', ...
    %%                            divergence_score);
    
    %%    tmpstr{end+1} = sprintf('= %s', ...
    %%                            latex_good_number(divergence_score));
    
    %% just messing around
    %%   tmpstr{end+1} = sprintf('= %s',latex_good_number(divergence_score/length(mixedelements(1).types)));
    
    tmpXcoords = -0.05;
    tmpYcoords = 0.942;

    tmph = text(tmpXcoords,tmpYcoords,...
                tmpstr,...
                'FontName','Arial',...
                'fontsize',16,...
                'units','normalized',...
                'horizontalalignment','left',...
                'verticalalignment','top',...
                'color',colors.darkgrey,...
                'interpreter','latex');
end

if ((strcmp(settings.plotkind,'rank') | ...
     strcmp(settings.plotkind,'probability'))...
    & ...
    ~strcmp(settings.turbulencegraph.labels,'off'))
%% if (strcmp(settings.instrument,'rank divergence'))
%% if (strcmp(settings.instrument,'abandoned'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: balance of size totals, type count, and exclusive type count
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    axesnum = 8;
    tmpaxes(axesnum) = axes('position',axes_positions(axesnum).box);
    set(gca,'visible','off');
    set(gca,'FontName','Arial');    
    binwidth = 0.8;
    tmpextrasep = 0.5;
    height = binwidth;
    
    %% use details instead
    
    i=3;
    sizeinfo(i).title = sprintf('total %s',settings.units);
    sumtc = details.totalcounts1 + details.totalcounts2;
    sizeinfo(i).width(1) = details.totalcounts1 / sumtc * 100;
    sizeinfo(i).width(2) = details.totalcounts2 / sumtc * 100;

    i=2;
    sizeinfo(i).title = sprintf('all %s',settings.typenameplural);
    sizeinfo(i).width(1) = details.N1 / details.N * 100;
    sizeinfo(i).width(2) = details.N2 / details.N * 100;

    i=1;
    sizeinfo(i).title = sprintf('exclusive %s',settings.typenameplural);
    sizeinfo(i).width(1) = details.N1exclusive / details.N1 * 100;
    sizeinfo(i).width(2) = details.N2exclusive / details.N2 * 100;
    
    for j=1:length(sizeinfo)
        %% system 1 
        width = sizeinfo(j).width(1);
        xpos =  - width;
        ypos = j - binwidth/2; %%  + tmpextrasep*floor((j-1)/3);
        [xpos ypos width height]
        tmprh = rectangle('position',[xpos ypos width height]);
        set(tmprh,'facecolor',colors.lightgrey);
        set(tmprh,'edgecolor',colors.lightgrey);
        hold on;

        %% system 2
        width = sizeinfo(j).width(2);
        xpos = 0;
        ypos = j - binwidth/2; %%   + tmpextrasep*floor((j-1)/3);
        tmprh = rectangle('position',[xpos ypos width height]);
        set(tmprh,'facecolor',colors.paleblue);
        set(tmprh,'edgecolor',colors.paleblue);
        hold on;
        
        clear tmpstr;
        tmpstr = sprintf('%.1f\\%% %s %.1f\\%%',...
                         sizeinfo(j).width(1),...
                         sizeinfo(j).title,...
                         sizeinfo(j).width(2));
        tmph = text(0,j,...
                    tmpstr, ...
                    'FontName','Arial',...
                    'fontsize',14,...
                    'units','data',...
                    'color',colors.darkergrey,...
                    'horizontalalignment','center',...
                    'interpreter','latex');

    end
    
    tmph = text(0,4,...
                'Balances:',...
                'FontName','Arial',...
                'fontsize',14,...
                'units','data',...
                'color',colors.darkergrey,...
                'horizontalalignment','center',...
                'interpreter','latex');


    xlim([-100 100]);
    %%    ylim([0 3]);

end

if (~strcmp(settings.instrument,'none'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: divergence element shift plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% options:
    %% 1. rank divergence
    %% 2. probability divergence
    %% 3. alpha divergence type 2

    axesnum = 2;
    tmpaxes(axesnum) = axes('position',axes_positions(axesnum).box);

    binwidth = 0.8;
    tmpextrasep = 0.5;
    height = binwidth;

    maxdelta = deltas(1);

    %% for double side
    %% dl_indices = find(deltas_loss > 0);
    %% dg_indices = find(deltas_gain > 0);

    %% for one side
    dl_indices = 1:(min(length(deltas_loss),settings.topNshift));
    dg_indices = 1:(min(length(deltas_gain),settings.topNshift));

    for j=1:(min(length(deltas_gain),settings.topNshift));
        
        %% left
        if (deltas_loss(dl_indices(j)) > 0)

            word = mixedelements(1).types{dl_indices(j)};

            fprintf(1,'- %s\n',word);
            word_otherprob = mixedelements(2).probs(dl_indices(j));
            
            %%    word = unstretchword(word);
            if (length(word) > settings.max_shift_string_length)
                word = [word(1:settings.max_shift_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
                fprintf(1,'- %s\n',word);
            end
            if (word_otherprob == 0)
                word = ['$\triangleleft$\,',word];
                %% word = [word, '\,$\bullet$'];
            end
            
            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');
            
            %% prevent some havoc
            word = regexprep(word,'$','\\$');
            word = regexprep(word,'#','\\#');
            word = regexprep(word,'_','\\_');

            
            rank1 = mixedelements(1).ranks(dl_indices(j));
            rank2 = mixedelements(2).ranks(dl_indices(j));
            
            width = 100*deltas(dl_indices(j))/sum(deltas);
            xpos = 0 - width;
            ypos = j - binwidth/2; %%  + tmpextrasep*floor((j-1)/3);
            tmprh = rectangle('position',[xpos ypos width height]);
            set(tmprh,'facecolor',colors.lightgrey);
            set(tmprh,'edgecolor',colors.lightgrey);
            hold on;
            
            tmpXcoord = 0;
            tmpYcoord = j;
            
            %%        tmpstr_word = sprintf('%d.\\,%s\\,',j,word);
            %%        tmpstr_word = sprintf('{\\color[rgb]{0.5 0.5 0.5}%d.} %s',j,word,j);

            tmpstr_word = sprintf('%s\\,',word);

            if (word_otherprob == 0)
                %%                zeroindicator = '$\bullet$';
                zeroindicator = '';
            else
                zeroindicator = '';
            end
            %%            tmpstr_shift = sprintf('\\,%s$\\leftarrow$%s%s',...
            tmpstr_shift = sprintf('\\,%s$\\rightleftharpoons$%s%s',...
                                   addcommas(rank1),...
                                   addcommas(rank2), ...
                                   zeroindicator);

            %%         tmpstr_shift = sprintf('(%d$\\rightarrow$%d,-%d) %s',...
            %%                                floor(rank1),...
            %%                                floor(rank2),...
            %%                                floor(abs(rank2-rank1)));

            if (mod(j,2)==1) 
                tmpcolor = 'k';
            else 
                tmpcolor = 'k';
            end
            tmph = text(tmpXcoord,tmpYcoord,tmpstr_word,...
                        'FontName','Arial',...
                        'fontsize',16,...
                        'units','data',...
                        'horizontalalignment','right',...
                        'color',tmpcolor,...
                        'interpreter','latex');

            tmph = text(tmpXcoord,tmpYcoord,tmpstr_shift,...
                        'FontName','Arial',...
                        'fontsize',16,...
                        'units','data',...
                        'horizontalalignment','left',...
                        'color',colors.darkgrey,...
                        'interpreter','latex');
        end

        %%%%%%%%%%%%%%%%%%%%%%
        %% right side of shift
        if (deltas_gain(dg_indices(j)) > 0) 
            
            word = mixedelements(1).types{dg_indices(j)};

            word_otherprob = mixedelements(1).probs(dg_indices(j));
            fprintf(1,'+ %s\n',word);
            if (length(word) > settings.max_shift_string_length)
                word = [word(1:settings.max_shift_string_length-6),...
                        '...',...
                        word(end-2:end),...
                       ];
                fprintf(1,'+ %s\n',word);
            end
            if (word_otherprob == 0)
                word = [word,'\,$\triangleright$'];
                %% word = ['$\bullet$\,',word];
            end

            word = regexprep(word,'^''','`');
            word = regexprep(word,'&','\\&');

            %% prevent some havoc
            word = regexprep(word,'$','\\$');
            word = regexprep(word,'#','\\#');
            word = regexprep(word,'_','\\_');


            rank1 = mixedelements(1).ranks(dg_indices(j));
            rank2 = mixedelements(2).ranks(dg_indices(j));

            width = 100*deltas(dg_indices(j))/sum(deltas);
            fprintf(1,'%g\n',width);
            xpos = 0;
            ypos = j - binwidth/2; %%   + tmpextrasep*floor((j-1)/3);
            tmprh = rectangle('position',[xpos ypos width height]);
            set(tmprh,'facecolor',colors.paleblue);
            set(tmprh,'edgecolor',colors.paleblue);
            hold on;
            
            tmpXcoord = 0;
            tmpYcoord = j;

            %%        tmpstr = sprintf('%s',word);
            %%         tmpstr = sprintf('%s (%d$\\rightarrow$%d,+%d)',...
            %%                          word,...
            %%                          floor(rank1),...
            %%                          floor(rank2),...
            %%                          floor(abs(rank2-rank1)));

            %%        tmpstr_word = sprintf('\\,%d.\\,%s',j,word);
            tmpstr_word = sprintf('\\,%s',word);

            if (word_otherprob == 0)
                %%                zeroindicator = '$\bullet$';
                zeroindicator = '';
            else
                zeroindicator = '';
            end
            tmpstr_shift = sprintf('%s%s$\\rightleftharpoons$%s\\,',...
                                   zeroindicator,...
                                   addcommas(rank1),...
                                   addcommas(rank2));

            %%         tmpstr_shift = sprintf('(%d$\\rightarrow$%d,+%d) %s',...
            %%                                floor(rank1),...
            %%                                floor(rank2),...
            %%                                floor(abs(rank2-rank1)));
            
            tmph = text(tmpXcoord,tmpYcoord,tmpstr_word,...
                        'FontName','Arial',...
                        'fontsize',16,...
                        'units','data',...
                        'horizontalalignment','left',...
                        'interpreter','latex');

            tmph = text(tmpXcoord,tmpYcoord,tmpstr_shift,...
                        'FontName','Arial',...
                        'fontsize',16,...
                        'units','data',...
                        'horizontalalignment','right',...
                        'color',colors.grey,...
                        'interpreter','latex');

        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% summary bars
    %% replace with percentages
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% left

    divergence_loss = 100*sum(deltas_loss(find(deltas_loss>0)))/sum(deltas);
    divergence_gain = 100*sum(deltas_gain(find(deltas_gain>0)))/sum(deltas);

    %% width = sum(deltas_loss(1:topNdeltasum))/20;

    tmpXcoord = 0;
    %% tmpYcoord = -1 + binwidth/2; %%  + tmpextrasep*floor((j-1)/3);

    tmpYcoord = settings.topNshift + 2;

    clear tmpstr;

    %% tmpstr = sprintf('(loss) %02.2f\\%% || %02.2f\\%% (gain)',divergence_loss,divergence_gain);

    tmpstr = sprintf('%02.1f\\%%---%02.1f\\%%',divergence_loss,divergence_gain);

    tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
                'FontName','Arial',...
                'fontsize',14,...
                'units','data',...
                'color',colors.darkergrey,...
                'horizontalalignment','center',...
                'verticalalignment','middle',...
                'interpreter','latex');


    %% tmprh = rectangle('position',[xpos ypos width height]);
    %% set(tmprh,'facecolor',colors.lightgrey);
    %% set(tmprh,'edgecolor',colors.lightgrey);
    %% hold on;

    %% right

    %% width = sum(deltas_gain(1:topNdeltasum))/20;

    %% tmpXcoord = 0;
    %% tmpYcoord = -1 + binwidth/2; %%  + tmpextrasep*floor((j-1)/3);
    %% 
    %% clear tmpstr;
    %% tmpstr = sprintf('  gain: \\%%%02.2f',divergence_gain);
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%             'fontsize',16,...
    %%             'units','data',...
    %%             'horizontalalignment','left',...
    %%             'verticalalignment','middle',...
    %%             'interpreter','latex');

    %% tmprh = rectangle('position',[xpos ypos width height]);
    %% set(tmprh,'facecolor',colors.paleblue);
    %% set(tmprh,'edgecolor',colors.paleblue);
    %% hold on;

    %% tmpXcoord = 0;
    %% tmpYcoord = j;
    %%     tmpstr = sprintf('%s',word);
    %% tmpstr = sprintf('(%d$\\rightarrow$%d) %s',rank1,rank2,word);

    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%             'fontsize',16,...
    %%             'units','data',...
    %%             'horizontalalignment','right',...
    %%            'interpreter','latex');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    set(gca,'ydir','reverse');
    set(gca,'FontName','Arial');
    %% tmph = plot(deltas(1:20));

    %% lines of constant RTD:
    %% c=.00001; r2 = ((c^.5 + 1./r.^.5)).^-2;
    set(gca,'FontName','Arial');
    set(gca,'fontsize',16);
    set(gca,'color','none');
    %% set(gca,'color',colors.lightergrey);

    %% set(gca,'visible','off');
    tmpaxes(axesnum).YAxis.Visible = 'off';
    tmpaxes(axesnum).TickDir = 'in';

    %% for use with layered plots
    %% set(gca,'box','off')

    %% adjust limits
    %% tmpv = axis;
    %% axis([]);
    
    tmpxlimvals = get(gca,'xlim');
    %%    xlimmax = max(abs(tmpxlimvals));
    xlimmax = 100*maxdelta/sum(deltas);
    xlim(xlimmax*[-1 1]);
    
    ylim([-.5, settings.topNshift+0.5]);

    %% change axis line width (default is 0.5)
    %% set(tmpaxes(axesnum),'linewidth',2)

    %% fix up tickmarks

    tmpxticklabels = get(gca,'xticklabel');
    tmpexp = tmpaxes(axesnum).XAxis.Exponent;
    for i=1:length(tmpxticklabels)
        tmpxticklabels{i} = regexprep(tmpxticklabels{i},'-','');
    end
    set(gca,'xticklabel',tmpxticklabels);
    set(gca,'FontName','Arial');
    %% set(gca,'xtick',[1 100 10^4])
    %% set(gca,'xticklabel',{'','',''})
    %% set(gca,'ytick',[1 100 10^4])
    %% set(gca,'yticklabel',{'','',''})

    %% the following will usually not be printed 
    %% in good copy for papers
    %% (except for legend without labels)

    %% remove a plot from the legend
    %% set(get(get(tmph,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    %% %% legend

    %% tmplh = legend('stuff',...);
    %% tmplh = legend('','','');
    %% 
    %% tmplh.Interpreter = 'latex';
    %% set(tmplh,'position',get(tmplh,'position')-[x y 0 0])
    %% %% change font
    %% tmplh_obj = findobj(tmplh,'type','text');
    %% set(tmplh_obj,'FontSize',18);
    %% %% remove box:
    %% legend boxoff

    %% use latex interpreter for text, sans Arial

    %% tmpstr = sprintf('Probability divergence word shift contribution $\\delta D_{%s}^{\\rm R}$ (\\%%)',settings.alphastr);

    clear tmpstr;
    if (tmpexp == 0)
        tmpstr = sprintf(['Divergence contribution ' ...
                          '$\\delta D_{%s,\\tau}^{\\rm %s}$' ...
                          '(\\%%)'], ...
                         alpha_str, ...
                         divergence_superscript_str);

    else
        tmpstr = sprintf(['Divergence contribution ' ...
                          '$\\delta D_{%s,\\tau}^{\\rm %s}$ ' ...
                          '($\\times10^{%d}$\\%%)'], ...
                         alpha_str, ...
                         divergence_superscript_str, ...
                         tmpexp);
    end

    tmpxlab=xlabel(tmpstr,...
                    'FontName','Arial',...
                   'fontsize',20,...
                   'verticalalignment','bottom',...
                   'interpreter','latex');


    set(gca,'xaxislocation','top');
    set(gca,'FontName','Arial');
    tmpylab=ylabel('',...
                   'FontName','Arial',...
                   'fontsize',16,...
                   'verticalalignment','bottom',...
                   'interpreter','latex');

    %% set(tmpxlab,'position',get(tmpxlab,'position') - [0 .1 0]);
    %% set(tmpylab,'position',get(tmpylab,'position') - [.1 0 0]);

    %% set 'units' to 'data' for placement based on data points
    %% set 'units' to 'normalized' for relative placement within axes
    %% tmpXcoord = ;
    %% tmpYcoord = ;
    %% tmpstr = sprintf(' ');
    %% or
    %% tmpstr{1} = sprintf(' ');
    %% tmpstr{2} = sprintf(' ');
    %%
    %% tmph = text(tmpXcoord,tmpYcoord,tmpstr,...
    %%     'fontsize',20,...
    %%     'units','normalized',...
    %%     'interpreter','latex')

    %% label (A, B, ...)
    %% tmplabelh = addlabel4(' A ',0.02,0.9,20);
    %% tmplabelh = addlabel5(loop_i,0.02,0.9,20);
    %% or:
    %% tmplabelXcoord= 0.015;
    %% tmplabelYcoord= 0.88;
    %% tmplabelbgcolor = 0.85;
    %% tmph = text(tmplabelXcoord,tmplabelYcoord,...
    %%    ' A ',...
    %%    'fontsize',24,
    %%         'units','normalized');
    %%    set(tmph,'backgroundcolor',tmplabelbgcolor*[1 1 1]);
    %%    set(tmph,'edgecolor',[0 0 0]);
    %%    set(tmph,'linestyle','-');
    %%    set(tmph,'linewidth',1);
    %%    set(tmph,'margin',1);

    %% rarely used (text command is better)
    %% title(' ','fontsize',24,'interpreter','latex')
    %% 'horizontalalignment','left');
    %% tmpxl = xlabel('','fontsize',24,'verticalalignment','top');
    %% set(tmpxl,'position',get(tmpxl,'position') - [ 0 .1 0]);
    %% tmpyl = ylabel('','fontsize',24,'verticalalignment','bottom');
    %% set(tmpyl,'position',get(tmpyl,'position') - [ 0.1 0 0]);
    %% title('','fontsize',24)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% automatic creation of postscript
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% without name/date
imageformat.type = 'pdf';
%imageformat.type = 'png';
imageformat.dpi = 600;
imageformat.deleteps = 'yes';
imageformat.open = 'yes'; 
imageformat.copylink = 'no';
imageformat.bordersize = 0;
if(isfield(settings,'imageformat'))
    if(isfield(settings.imageformat,'type'))
        imageformat.type = settings.imageformat.type;
    end
    if(isfield(settings.imageformat,'dpi'))
        imageformat.dpi = settings.imageformat.dpi;
    end
    if(isfield(settings.imageformat,'deleteps'))
        imageformat.deleteps = settings.imageformat.deleteps;
    end
    if(isfield(settings.imageformat,'open'))
        imageformat.open = settings.imageformat.open;
    end
    if(isfield(settings.imageformat,'copylink'))
        imageformat.copylink= settings.imageformat.copylink;
    end

end

print_universal(tmpfilenoname,imageformat);


%% name label
%% tmpt = pwd;
%% tmpnamememo = sprintf('[source=%s/%s.ps]',tmpt,tmpfilename);
%% 
%% [tmpXcoord,tmpYcoord] = normfigcoords(1.05,.05);
%% tmph = text(tmpXcoord,tmpYcoord,tmpnamememo,...
%%      'units','normalized',...
%%      'fontsize',2,...
%%      'rotation',90,'color',0.8*[1 1 1]);

%% [tmpXcoord,tmpYcoord] = normfigcoords(1.1,.05);
%% datenamer(tmpXcoord,tmpYcoord,90);

%% automatic creation of postscript
%% psprintcpdf(tmpfilename);


%% archivify (0 = off, non-zero = on)
archiveswitch = 0;
figarchivify(tmpfilenoname,archiveswitch);

%% prevent hidden figure clutter/bloat
%% may need to switch this off for some test
close(tmpfigh);

%% clean up tmp* files
clear tmp*

more on;

if (isfield(settings,'alpha'))
    fprintf(1,'alpha used: %s\n',alpha_str);
end

disp('Todo: Must plot points for a check');

disp('Todo: Add psd logo');

disp('Todo: Make minprob_log10 an optional setting');

disp(['Todo: Make words shown on rank-rank plot an optional ' ...
      'setting'])

disp('Todo: Add a tiny watermark');

disp('Make inset scale have shaded boxes under contours');

disp('Remove these reminders');
%
%% Keep other words but grey them out


%% disp('Todo: make talked about an option');
%% disp('Todo: Word Rank r -> make a setting')

if (strcmp(settings.plotkind,'rank') || strcmp(settings.plotkind,'probability'))
    details
    things.details = details;
end

things.divergence_score = divergence_score;
