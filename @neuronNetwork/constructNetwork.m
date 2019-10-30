function o = constructNetwork(o,varargin)

p = inputParser;
p.addParameter('type','random');
p.parse(varargin{:});

%% Make the network
o.Ne = round(o.N*o.proportion_e); % round for equals cells per cluster
o.Ni = o.N - o.Ne;
o.excitatory_idx = 1:o.Ne;
o.inhibitory_idx = o.Ne+1:o.N;


% Make the connectivity matrix
W = sparse(o.N);


% make the within-cluster connectivity R times greater than
% extra-cluster connectivity
in_cluster_p = o.cluster_p_ratio * o.p_ee * o.Ne / (o.cluster_p_ratio * o.Ne / o.clusters + (o.Ne - o.Ne/o.clusters));
out_cluster_p = in_cluster_p / o.cluster_p_ratio;



connectMask = repmat(out_cluster_p, o.Ne); % mask of connection probabilities
weightsMask = repmat(o.W_ee,        o.Ne); % mask of weights

% Set the clusters
edges = round(linspace(1,o.Ne,o.clusters + 1));
for i = 1:o.clusters
    connectMask(edges(i):edges(i+1), edges(i):edges(i+1)) = in_cluster_p;
    weightsMask(edges(i):edges(i+1), edges(i):edges(i+1)) = o.W_ee * o.cluster_w_ratio;
end


% Use bernoulli to set the probabilities, exponential to set the weights

switch p.Results.type
    case 'random'
        W(o.excitatory_idx, o.excitatory_idx) = (rand(o.Ne,o.Ne) < connectMask) .* exprnd(weightsMask);
    case 'WattsStrogatz'
        beta = .6;
        W(o.excitatory_idx, o.excitatory_idx) = WattsStrogatz(o.Ne, round(o.p_ee*o.Ne), beta) .* exprnd(weightsMask);
    case 'BarabasiAlbert'
        beta = .1;
        W(o.excitatory_idx, o.excitatory_idx) =BarabasiAlbert(o.Ne, round(o.p_ee*o.Ne), beta) .* exprnd(weightsMask);
end


W(o.excitatory_idx, o.inhibitory_idx) = (rand(o.Ne,o.Ni) < o.p_ei)      .* exprnd(o.W_ei,o.Ne,o.Ni);
W(o.inhibitory_idx, o.excitatory_idx) = (rand(o.Ni,o.Ne) < o.p_ei)      .* -exprnd(-o.W_ie,o.Ni,o.Ne);
W(o.inhibitory_idx, o.inhibitory_idx) = (rand(o.Ni,o.Ni) < o.p_ei)      .* -exprnd(-o.W_ii,o.Ni,o.Ni);


% Get rid of the diagonal, neurons can't connect to themselves
W(1:length(W)+1:numel(W)) = 0;
o.W = sparse(W);

%% Biases
o.mu = zeros(o.N,1);
o.mu(o.excitatory_idx) = range(o.mu_e_range)*rand(o.Ne,1) + o.mu_e_range(1); %define the bias for all excitatory neurons
o.mu(o.inhibitory_idx) = range(o.mu_i_range)*rand(o.Ni,1) + o.mu_i_range(1); %define the bias for all inhibitory neurons

%% Time constants
o.tau = [
    repmat(o.tau_e,o.Ne,1)
    repmat(o.tau_i,o.Ni,1)
    ];

o.neuron_names = [
    repmat({'Excitatory'}, o.Ne, 1)
    repmat({'Inhibitory'}, o.Ni, 1)
    ];


end


function W = WattsStrogatz(N,K,beta)
% H = WattsStrogatz(N,K,beta) returns a Watts-Strogatz model graph with N
% nodes, N*K edges, mean node degree 2*K, and rewiring probability beta.
%
% beta = 0 is a ring lattice, and beta = 1 is a random graph.

% Connect each node to its K next and previous neighbors. This constructs
% indices for a ring lattice.
s = repelem((1:N)',1,K);
t = s + repmat(1:K,N,1);
t = mod(t-1,N)+1;

% Rewire the target node of each edge with probability beta
for source=1:N
    switchEdge = rand(K, 1) < beta;
    
    newTargets = rand(N, 1);
    newTargets(source) = 0;
    newTargets(s(t==source)) = 0;
    newTargets(t(source, ~switchEdge)) = 0;
    
    [~, ind] = sort(newTargets, 'descend');
    t(source, switchEdge) = ind(1:nnz(switchEdge));
end
g = digraph(s,t);
W = full(adjacency(g));
end


function W = BarabasiAlbert(N,K,beta)
W = zeros(N);
additions = 4;
for trials = 1:K/(2*additions)
    for i = 1:N
        j = randsample(N, 4, true, sum(W,2) + beta);
        W(i,j) = 1;
        j = randsample(N, 4, true, sum(W,1) + beta);
        W(j,i) = 1;
    end
end
end



