function o = constructNetwork(o,varargin)
%{
Make the weight matrix.
o = constructNetwork()

o = constructNetwork('type', 'clustered')
    Discrete clusters of neurons. Set cluster_p_ratio to the ratio of
    in-cluster/out-cluster connections.

o = constructNetwork('type', 'ring')
    Continuous ring on neurons. Set cluster_p_ratio to the ratio of
    in-ring/out-ring connections.

o = constructNetwork('type', 'sheet')
    2-dimensional local connectivity

o = constructNetwork('type', 'WattsStrogatz')
o = constructNetwork('type', 'BarabasiAlbert')

Visualize the weight matrix with o.plot_weights()
%}

p = inputParser;
p.addParameter('type','clustered', @(x) any(validatestring(x,{'clustered','ring','WattsStrogatz','BarabasiAlbert','sphere'})));
p.addParameter('dimensions',3);
p.addParameter('networkRadius',5);
p.addParameter('neuronRadius',1);

p.parse(varargin{:});

%% Make the network
o.Ne = round(o.N*o.proportion_e); % round for equals cells per cluster
o.Ni = o.N - o.Ne;
o.excitatory_idx = 1:o.Ne;
o.inhibitory_idx = o.Ne+1:o.N;


% Balance the weights
o.W_ee = o.W_ee / (o.p_ee);
o.W_ei = o.W_ei / (o.p_ei);
o.W_ie = o.W_ie / (o.p_ie);
o.W_ii = o.W_ii / (o.p_ii);

% % Turn out-degree to in-degree
% o.p_ie = o.Ne * o.p_ie / o.Ni;
% o.p_ei = o.Ni * o.p_ei / o.Ne;



% Turn in-degree into in-probability
% o.p_ee = o.p_ee / o.Ne;
% o.p_ei = o.p_ei / o.Ne;
% o.p_ie = o.p_ie / o.Ni;
% o.p_ii = o.p_ii / o.Ni;






% Make the connectivity matrix
W = sparse(zeros(o.N));


% make the within-cluster connectivity R times greater than
% extra-cluster connectivity
in_cluster_p = o.cluster_p_ratio * o.p_ee * o.Ne / (o.cluster_p_ratio * o.Ne / o.clusters + (o.Ne - o.Ne/o.clusters));
out_cluster_p = in_cluster_p / o.cluster_p_ratio;



connectMask = repmat(out_cluster_p, o.Ne); % mask of connection probabilities
weightsMask = repmat(o.W_ee,        o.Ne); % mask of weights



% Use bernoulli to set the probabilities, exponential to set the weights

switch p.Results.type
    case 'clustered'
        % Set the clusters
        edges = round(linspace(1,o.Ne,o.clusters + 1));
        for i = 1:o.clusters
            o.clusterIndex(edges(i):edges(i+1)) = i;
            connectMask(edges(i):edges(i+1), edges(i):edges(i+1)) = in_cluster_p;
            weightsMask(edges(i):edges(i+1), edges(i):edges(i+1)) = o.W_ee * o.cluster_w_ratio;
        end
        %         W(o.excitatory_idx, o.excitatory_idx) = (rand(o.Ne,o.Ne) < connectMask) .* exprnd(weightsMask);
        W(o.excitatory_idx, o.excitatory_idx) = (rand(o.Ne,o.Ne) < connectMask) .* (weightsMask);
        
    case 'ring'
        connectMask = repmat(out_cluster_p, o.Ne); % mask of connection probabilities
        weightsMask = repmat(o.W_ee,        o.Ne); % mask of weights
        mask = ~tril(ones(o.Ne), -floor(o.Ne/o.clusters)) & ~triu(ones(o.Ne), floor(o.Ne/o.clusters));
        mask = mask | tril(ones(o.Ne), -floor(o.Ne - o.Ne/o.clusters));
        mask = mask | triu(ones(o.Ne), floor(o.Ne - o.Ne/o.clusters));
        connectMask(mask) = in_cluster_p;
        weightsMask(mask) = o.W_ee * o.cluster_w_ratio;
        W(o.excitatory_idx, o.excitatory_idx) = (rand(o.Ne,o.Ne) < connectMask) .* exprnd(weightsMask);
        
    case 'WattsStrogatz'
        beta = o.cluster_p_ratio / (o.cluster_p_ratio + 1);
        W(o.excitatory_idx, o.excitatory_idx) = WattsStrogatz(o.Ne, round(o.p_ee*o.Ne), beta) .* exprnd(weightsMask);
        
    case 'BarabasiAlbert'
        beta = .1;
        W(o.excitatory_idx, o.excitatory_idx) =BarabasiAlbert(o.Ne, round(o.p_ee*o.Ne), beta) .* exprnd(weightsMask);
        
    case 'sphere'
        % Generate points in a sphere
        % https://www.mathworks.com/matlabcentral/fileexchange/9443-random-points-in-an-n-dimensional-hypersphere?s_tid=answers_rc2-3_p6_MLT
        X = randn(o.Ne, p.Results.dimensions);
        s2 = sum(X.^2,2);
        o.neuronCoordinates = X.*repmat(p.Results.networkRadius*(gammainc(s2/2,p.Results.dimensions/2).^(1/p.Results.dimensions))./sqrt(s2),1, p.Results.dimensions);
        
        % Get the distance between all the points, turn this into relative probability of a synapse
        dist = pdist2(o.neuronCoordinates, o.neuronCoordinates);
        
        % P_ij is the *relative* probability of neuron i connecting to neuron j.
        % A guassian distribution seemed like a good starting point.
        P_ij = normpdf(dist, 0, p.Results.neuronRadius);
        
        % Get rid of the diagonal
        P_ij = P_ij .* ~eye(size(P_ij));
        
        
        for i = 1:o.Ne
%             k = poissrnd(o.p_ee);
            k = normrnd(o.p_ee,  sqrt(o.p_ee) * o.sigma);
            k = max(round(k),0);
%             idx = datasample(1:o.Ne, k, 'Replace', false, 'Weights', P_ij(:,i));
            idx = datasample(1:o.Ne, k, 'Replace', false, 'Weights', P_ij(:,i) ./ (sum(W(1:o.Ne,1:o.Ne) > 0,2) + 1));
            W(idx, i) = o.W_ee;
        end
        
end


% W(o.excitatory_idx, o.inhibitory_idx) = (rand(o.Ne,o.Ni) < o.p_ei)      .* exprnd(o.W_ei,o.Ne,o.Ni);
% W(o.inhibitory_idx, o.excitatory_idx) = (rand(o.Ni,o.Ne) < o.p_ie)      .* -exprnd(-o.W_ie,o.Ni,o.Ne);
% W(o.inhibitory_idx, o.inhibitory_idx) = (rand(o.Ni,o.Ni) < o.p_ii)      .* -exprnd(-o.W_ii,o.Ni,o.Ni);
% W(o.excitatory_idx, o.inhibitory_idx) = (rand(o.Ne,o.Ni) < o.p_ei / o.Ni)      .* o.W_ei;
% W(o.inhibitory_idx, o.excitatory_idx) = (rand(o.Ni,o.Ne) < o.p_ie / o.Ne)      .* o.W_ie;
% W(o.inhibitory_idx, o.inhibitory_idx) = (rand(o.Ni,o.Ni) < o.p_ii / o.Ni)      .* o.W_ii;

% % Inhibitory to excitatory
% for i = o.inhibitory_idx
% %     k = poissrnd(o.p_ie);
%     k = normrnd(o.p_ie, sqrt(o.p_ie) * o.sigma);
%     k = max(round(k),0);
%     idx = datasample(o.excitatory_idx, k, 'Replace', false);
%     W(i, idx) = o.W_ie;
% end

% % Excitatory to inhibitatory
% for i = o.excitatory_idx
% %     k = poissrnd(o.p_ei);
%     k = normrnd(o.p_ei,  sqrt(o.p_ei) * o.sigma);
%     k = max(round(k),0);
%     idx = datasample(o.inhibitory_idx, k, 'Replace', false);
%     W(i, idx) = o.W_ei;
% end
% 
% % Inhibitory to inhibitatory
% for i = o.inhibitory_idx
% %     k = poissrnd(o.p_ii);
%     k = normrnd(o.p_ii,  sqrt(o.p_ii) * o.sigma);
%     k = max(round(k),0);
%     idx = datasample(o.inhibitory_idx, k, 'Replace', false);
%     W(i, idx) = o.W_ii;
% end

% Inhibitory to excitatory
for i = o.excitatory_idx
%     k = poissrnd(o.p_ie);
    k = normrnd(o.p_ie, sqrt(o.p_ie) * o.sigma);
    k = max(round(k),0);
    idx = datasample(o.inhibitory_idx, k, 'Replace', false);
    W(idx, i) = o.W_ie;
end

% Excitatory to inhibitatory
for i = o.inhibitory_idx
%     k = poissrnd(o.p_ei);
    k = normrnd(o.p_ei,  sqrt(o.p_ei) * o.sigma);
    k = max(round(k),0);
    idx = datasample(o.excitatory_idx, k, 'Replace', false);
    W(idx, i) = o.W_ei;
end

% Inhibitory to inhibitatory
for i = o.inhibitory_idx
%     k = poissrnd(o.p_ii);
    k = normrnd(o.p_ii,  sqrt(o.p_ii) * o.sigma);
    k = max(round(k),0);
    idx = datasample(o.inhibitory_idx, k, 'Replace', false);
    W(idx, i) = o.W_ii;
end



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



