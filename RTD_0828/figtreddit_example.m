%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create an allotaxonomograph 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datevec1 = [2020 05 10];%[2015 07 01];%[2020 05 25];%[2019 10 01];%[2017 03 15];%[2016 11 09];%[2011 09 17];%[2011 09 17]
datevec2 = [2021 12 31];%[2016 06 25];%[2021 12 31];%[2020 02 11];%[2018 07 11];%[2020 11 04];%[2012 12 21];%[2021 12 31]

%% - if statement here is to avoid reloading the data set every time
%% - clear elements to force reload
if (~exist('elements'))
    textfile1 = sprintf('../data_files/RC_%04d-%02d-%02d.tsv',...
                        datevec1(1),...
                        datevec1(2),...
                        datevec1(3));

    textfile2 = sprintf('../data_files/RC_%04d-%02d-%02d.tsv',...
                        datevec2(1),...
                        datevec2(2),...
                        datevec2(3));

    story_wrangler_twitter_data(1).table = readtable(textfile1,...
                                                     'filetype','text',...
                                                     'delimiter','\t');
    story_wrangler_twitter_data(2).table = readtable(textfile2,...
                                                     'filetype','text',...
                                                     'delimiter','\t');

    %% subsample for latin characters
    for i=1:length(story_wrangler_twitter_data)
        %%    indices =
        %%    ~cellfun(@isempty,regexp(story_wrangler_twitter_data(i).table{:,1},'^[@#-''A-Za-z]+$','match'));
        indices = ~cellfun(@isempty,regexp(story_wrangler_twitter_data(i).table{:,1},'^[A-Za-z][-''A-Za-z]+$','match'));

        story_wrangler_twitter_data(i).table = ...
            story_wrangler_twitter_data(i).table(indices,:);
        length(indices)
    end

    indices = [1 2];
    for i=1:2
        elements(i).types = story_wrangler_twitter_data(indices(i)).table{:,1};
        elements(i).counts = story_wrangler_twitter_data(indices(i)).table{:,2};
        elements(i).probs = story_wrangler_twitter_data(indices(i)).table{:,4};

        elements(i).ranks = tiedrank(-elements(i).counts);
        elements(i).totalunique = length(elements(i).types);
    end

    
mixedelements = combine_distributions(elements(1),elements(2));
else
    fprintf(1,'elements not reloaded; delete if needed\n');
end

%% some settings
datetag_str = sprintf('%04d-%02d-%02d-%04d-%02d-%02d', ...
                     datevec1(1), ...
                     datevec1(2), ...
                     datevec1(3));

settings.system1_name = sprintf('Reddit on %04d/%02d/%02d',...
                   datevec1(1),...
                   datevec1(2),...
                   datevec1(3));
settings.system2_name = sprintf('Reddit on %04d/%02d/%02d',...
                   datevec2(1),...
                   datevec2(2),...
                   datevec2(3));


settings.typename = 'word';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%

settings.binwidth = 0.21;
settings.topNshuffling = 25;
settings.topNshift = 40;
settings.topNdeltasum = 'all';

settings.max_plot_string_length = 15;
settings.max_shift_string_length = 25;

settings.imageformat.open = 'yes'; %no
% settings.imageformat.type = 'png';
% settings.imageformat.dpi = 600;
% settings.imageformat.deleteps = 'yes';
% settings.imageformat.open = 'yes'; 
% settings.imageformat.copylink = 'no';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% make some flip books
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% example flipbook series for rank divergence for 1 and 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settings.plotkind = 'rank';
%% settings.plotkind = 'probability';
%% settings.plotkind = 'count';

settings.instrument = 'rank divergence';
%% settings.instrument = 'probability divergence';
%% settings.instrument = 'alpha divergence type 2';

%% move the shift (adds to 0.60)
settings.xoffset = +0.05;

%% alphavals = [(0:18)/12, 2, 3, 5, 10, Inf]';

settings.alpha = 1/4;

tag = sprintf('%04d-%02d-%02d-%04d-%02d-%02d-rank-div-alpha-third',...
              datevec1(1),...
              datevec1(2),...
              datevec1(3),...
              datevec2(1),...
              datevec2(2),...
              datevec2(3));

figallotaxonometer9000(mixedelements,tag,settings);



