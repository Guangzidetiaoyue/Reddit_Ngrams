function mixedelements = combine_distributions(elements1,elements2)
%% mixedelements = combine_distributions(elements1,elements2)
%% 
%% expects input of the form of two structures of matching form
%% 
%% using elements1 as an example:
%% 
%% two pieces are required:
%% 
%% elements1.types 
%% - cell array
%% - names of things (types, elements, species, ...)
%% - single column
%% 
%% elements1.counts
%% - counts of things 
%% - more generally may be sizes of things
%% - single column
%% 
%% computed:
%% 
%% elements1.ranks
%% - ranks of things based on counts or sizes
%% - same shape as elements1.counts
%% 
%% optional:
%% 
%% elements1.totalcount (overall count for normalization)
%% elements1.probs ( = elements1.counts/elements1.totalcount)
%% 
%% produces:
%% 
%% mixedelements(1).types (cell array, names of things, union)
%% redundant: mixedelements(2).types
%% 
%% for i=1,2:
%% 
%% mixedelements(i).counts (counts of things, includes 0s for types missing)
%% 
%% computed: 
%% 
%% mixedelements(i).ranks (ranks, tied, based on counts with 0s)
%% 
%% optional:
%% 
%% mixedelements(i).probs (probabilities of things, with 0s)
%% %% mixedelements(i).totalcounts (carried over)

mixedelements(1).types = ...
    union(elements1.types,...
          elements2.types,...
          'stable');

mixedelements(2).types = mixedelements(1).types;

N = length(mixedelements(1).types);

%% first distribution
i = 1;

[presence,indices] = ...
    ismember(mixedelements(1).types,...
             elements1.types);
newindices = find(presence==1);

mixedelements(i).counts = zeros(N,1);
mixedelements(i).counts(newindices) = elements1.counts(indices(newindices));

%% compute ranks
mixedelements(i).ranks = tiedrank(-mixedelements(i).counts);

if (isfield(elements1,'probs'))
    mixedelements(i).probs = zeros(N,1);
    mixedelements(i).probs(newindices) = ...
        elements1.probs(indices(newindices));
end

if (isfield(elements1,'totalcounts'))
    mixedelements(i).totalcounts = elements1.totalcounts;
end

%% second distribution
i = 2;

[presence,indices] = ...
    ismember(mixedelements(1).types,...
             elements2.types);
newindices = find(presence==1);

mixedelements(i).counts = zeros(N,1);
mixedelements(i).counts(newindices) = elements2.counts(indices(newindices));

%% compute ranks
mixedelements(i).ranks = tiedrank(-mixedelements(i).counts);

if (isfield(elements2,'probs'))
    mixedelements(i).probs = zeros(N,1);
    mixedelements(i).probs(newindices) = ...
        elements2.probs(indices(newindices));
end

if (isfield(elements2,'totalcounts'))
    mixedelements(i).totalcounts = elements2.totalcounts;
end