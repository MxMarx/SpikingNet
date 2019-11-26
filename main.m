clear o
j = 1
o = neuronNetwork;
o.p_ee = 60;

% raster = ExtractRaster()

o.refractory = 1;
o.mu_e_range = [.90 1.01];
o.mu_i_range = .99;
o.dt = .2;
o.W_ee = .06;
% o.W_ii = -.02;
o.N = 1000;
o.cluster_p_ratio = 4;
o.clusters = 8;
o.cluster_w_ratio = 1.2;
o.t_span = 3500;

o.constructNetwork('type','random')

o.DLM = raster(j).DLM;

o.simulateNetwork
o.plot_raster('sort','none')
export_fig('LMAN Raster - Undirected.png','-m3')
export_fig('LMAN Raster - Directed.png','-m3')




ISI = [];
for i = o.excitatory_idx 
    ISI = [ISI diff(o.spikes{i})];
end
LMANISI{j} = ISI;


figure
g = gramm('x',fliplr(o.stimulusTrain))
g.geom_raster
g.set_order_options('x',0);
g.set_names('x','Time (ms)','y','Cell Index','color','Cell type');
g.draw
export_fig('DLM - Directed Input.png','-m3')


figure
g = gramm('x', LMANISI,'color', {'Directed','Undirected'})
g.stat_bin('edges',0:1:100,'normalization','pdf','geom','stairs','fill','transparent')
g.set_names('x','LMAN ISI (ms)','y','Probability density','color','Song type')
g.draw
export_fig('LMAN ISI Distribution.png','-m3')

o.saveFigures = true;
o.saveDirectory = 'C:\Users\russe\OneDrive - UW\Grad School\Fairhall Lab\figures\Stimulation\ring_mu.92_3'
o.plot_raster('sort','none')
o.plot_weights
o.plot_mean_voltage
o.plot_periodogram
o.plot_correlation
close all



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
idx = 1:200
g = digraph(o.W(idx,idx))
h = plot(g)
colormap(plasma)
box off; axis off
caxis([-.2,.8])
h.EdgeAlpha = .2

for i = 1:10:length(o.voltageHistory)
    h.NodeCData = o.voltageHistory(idx,i);
    h.EdgeCData = 6*(o.syn_out_history(g.Edges.EndNodes(:,1) + idx(1),i)) - .3;
    drawnow
end
