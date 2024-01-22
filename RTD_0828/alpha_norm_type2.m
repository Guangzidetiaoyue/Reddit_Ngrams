function divergence_elements = alpha_norm_type2(x1,x2,alpha)
%% divergences_elements = alpha_norm_type2(x1,x2,alpha)
%% 
%% returns per type divergence values for alpha type2 norms 
%% 
%% alpha >= 0 and may be specified as Inf
%% 
%% similar to p-norm but 
%% normalized by a (alpha+1)/alpha prefactor and using a power 1/(alpha+1)
%% 
%% expects x1 and x2 to be of the same length
%% for ranks, x = 1/r.
%% 
%% (x1 and x2 may also be matrices)

if (alpha < 0)
    error('alpha must be >= 0');
elseif (alpha == Inf)
    divergence_elements = max(x1,x2);
    divergence_elements(find(x1==x2)) = 0;
elseif (alpha == 0)
    divergence_elements = ...
        abs(log(x1./x2));
    %% or:  log(max(1./x1,1./x2)./min(1./x1,1./x2));
    %% or:  log(max(x1,x2)./min(x1,x2));
else
    divergence_elements = ...
        (alpha+1)/alpha* ...
        (abs(x1.^alpha - x2.^alpha)).^(1./(alpha+1));
end
