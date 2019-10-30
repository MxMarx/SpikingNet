clear all
o = neuronNetwork;
o.p_ee = .15

% o.W_ee = .025
% o.W_ie = -.3
% o.W_ii = -.15
% o.W_ei = .15
o.mu_e_range = .92;
o.mu_i_range = .9;
o.dt = .2

o.N = 1024
o.cluster_p_ratio = 4
o.clusters = 12;
o.cluster_w_ratio = 2.2;
o.t_span = 8000;
% o.constructNetwork('type','BarabasiAlbert')
% o.constructNetwork('type','WattsStrogatz')
o.constructNetwork
o.simulateNetwork('plasticity',0)
o.plot_raster('sort','none')



o.saveFigures = true;
o.saveDirectory = 'C:\Users\russe\OneDrive - UW\Grad School\Fairhall Lab\figures\Clustered'
o.plot_weights
o.plot_degree

o.plot_raster('sort','none')
o.plot_periodogram
o.plot_mean_voltage
o.plot_correlation

close all



g = digraph(o.W(o.excitatory_idx,o.excitatory_idx))
figure
h = plot(g)
h.layout('force','WeightEffect','none','Iterations',500)
h.layout('circle')

h.EdgeAlpha = .01


histogram(indegree(digraph(o.W(o.excitatory_idx,o.excitatory_idx))))
histogram(outdegree(digraph(o.W(o.excitatory_idx,o.excitatory_idx))))

% 
% 
figure('Color','k')
idx = 1:500
g = digraph(o.W(idx,idx))
h = plot(g)
colormap(plasma)
box off; axis off
caxis([-.3,.8])
h.EdgeAlpha = .2

for i = 1:10:length(o.voltageHistory)
    h.NodeCData = o.voltageHistory(idx,i);
    h.EdgeCData = 6*(o.syn_out_history(g.Edges.EndNodes(:,1) + idx(1),i)) - .3;
    drawnow
end
