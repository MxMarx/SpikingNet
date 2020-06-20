function  [C1, C2, C] = calculateClusteringCoef(o)
%CLUSTCOEFF Compute two clustering coefficients, based on triangle motifs count and local clustering
% C1 = number of triangle loops / number of connected triples
% C2 = the average local clustering, where Ci = (number of triangles connected to i) / (number of triples centered on i)
% Ref: M. E. J. Newman, "The structure and function of complex networks"
% Note: Valid for directed and undirected graphs
%
% @input A, NxN adjacency matrix
% @output C1, a scalar of the average clustering coefficient (definition 1).
% @output C2, a scalar of the average clustering coefficient (definition 2).
% @output C, a 1xN vector of clustering coefficients per node (where mean(C) = C2).
%
% Other routines used: degrees.m, isDirected.m, kneighbors.m, numEdges.m, subgraph.m, loops3.m, numConnTriples.m

% Updated: Returns C vector of clustering coefficients.

% IB, Last updated: 3/23/2014
% Input [in definition of C1] by Dimitris Maniadakis.

% Credit to https://github.com/ivanbrugere/matlab-networks-toolbox/

%%
% Number of timepoints to sample
sample_N = 100;

% Make the adjacency matrix
A = o.W(o.excitatory_idx, o.excitatory_idx);
A = full(A);
% Make it undirected
A = A | A';

samples = ceil(linspace(1, size(o.syn_out_history,2), sample_N));

% initialize output
C = nan(o.Ne,length(samples));
C1 = zeros(length(samples), 1);

% Calculate number of loops/cycles of length 3
loops3 = @(adj) trace(adj^3)/6;


for i = 1:length(samples)
    numConnTriples = 0;
    % Get the neurons the spiked at i
    spikes = o.syn_out_history(o.excitatory_idx, samples(i)) > .05;
    for j = find(spikes)' % for each neuron that spiked
        neigh = A(:, j) & spikes; % Points connected to j
        numTris = sum(A(neigh,neigh), 'all') / 2;
        if numTris > 0
            x=sum(neigh);
            x=x*(x-1)/2;
            C(j,i)=numTris./x;
        else
            C(j,i) = 0;
        end
        
        if sum(neigh)>1 % handle leaves, no triple here
            numConnTriples = numConnTriples + nchoosek(sum(neigh), 2);
        end
    end
    
    
    C1(i) = 3*loops3(A(spikes,spikes)) / numConnTriples;
    
end

C2 = nanmean(C);

%%





figure('Color','k')
h = plot(graph(A(spikes, spikes)))
layout(h,'force', 'UseGravity', 'on')
box off
axis off
h.NodeCData = C(spikes,i)






