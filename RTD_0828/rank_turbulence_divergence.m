function [divergence_elements,normalization] = rank_turbulence_divergence(mixedelements,alpha)
%% [divergences_elements,normalization] = rank_turbulence_divergence(mixedelements,alpha)
%% 
%% returns per type divergence values for rank turbulence divergence
%% 
%% normalization is computational such that disjoint version gives 1
%% 
%% alpha >= 0 and may be specified as Inf
%% 
%% see:
%% "Allotaxonometry and rank-turbulence divergence: A universal
%% instrument for comparing complex systems"
%% https://arxiv.org/abs/2002.09770
%% 
%% for mixedelements construction, use combine_distributions


%% inversese of ranks give base measure of importantce
x1 = mixedelements(1).ranks.^-1;
x2 = mixedelements(2).ranks.^-1;

if (alpha < 0)
    error('alpha must be >= 0');
elseif (alpha == Inf)
    divergence_elements = max(x1,x2);
    divergence_elements(find(x1==x2)) = 0;
elseif (alpha == 0)
    divergence_elements = ...
        log(max(1./x1,1./x2)./min(1./x1,1./x2));
    %% or:  log(max(x1,x2)./min(x1,x2));
else
    divergence_elements = ...
        (alpha+1)/alpha* ...
        (abs(x1.^alpha - x2.^alpha)).^(1./(alpha+1));
end

%% normalization
%% treat as disjoint
indices1 = find(mixedelements(1).counts>0);
indices2 = find(mixedelements(2).counts>0);
N1 = length(indices1);
N2 = length(indices2);

%% ranks for first system's elements
ranks1disjoint = N2 + N1/2;
x1disjoint = 1/ranks1disjoint;
%% ranks for second system's elements
ranks2disjoint = N1 + N2/2;
x2disjoint = 1/ranks2disjoint;

if (alpha == Inf)
    normalization = sum(x1(indices1)) + sum(x2(indices2));
elseif (alpha == 0)
    normalization = ...
        sum(abs(log(x1(indices1) / x2disjoint))) + ...
        sum(abs(log(x2(indices2) / x1disjoint)));
else
    normalization = ...
        (alpha+1)/alpha * ...
        sum((abs(x1(indices1).^alpha - x2disjoint.^alpha)).^(1./(alpha+1))) + ...
        (alpha+1)/alpha * ...
        sum((abs(x1disjoint.^alpha - x2(indices2).^alpha)).^(1./(alpha+1)));
end

divergence_elements = ...
    divergence_elements / normalization;

