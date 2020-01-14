%% Get the input from DLM
raster = ExtractRaster()

%% Simulate LMAN from the first two DLM input trains
% raster(1) = directed
% raster(2) = undirected

for j = 1:2
    rng(20) % reset the random number generator
    o = neuronNetwork;
    
    % any parameters not set will be the defaults defined in neuronNetwork.m
    % see neuronNetwork.m for parameter definitions
    o.p_ee = 10
    o.p_ii = 4;
    o.p_ie = 60;
    o.p_ei = 12
    o.V_reset = 0
    o.refractory = .2;
    o.mu_e_range = [.85];
    o.mu_i_range = [.85, .9];
    o.dt = .2;
    o.W_ee = .1;
    o.W_ii = -.2;
    o.W_ei = .1
    o.W_ie = -.3
    o.N = 1000;
    o.cluster_p_ratio = 1;
    o.clusters = 8;
    o.cluster_w_ratio = 1;
    o.t_span = (630+10)*10-1;
    o.tau2_e = 3
    
    % Make the weight matrix
    o.constructNetwork('type','clustered')
    
    % Generate the input data from DLM
    o.generateStimulusTrain(raster(j).DLM)
    
    % Simulate the network
    o.simulateNetwork
    
    o.plot_raster
    drawnow
    
    % Save the LMAN ISI
    ISI = [];
    for i = o.excitatory_idx
        ISI = [ISI diff(o.spikes{i})];
    end
    LMANISI{j} = ISI;
    
end



plot(epsp)
hold on
plot(ipsp)

%% Plot ISI distribution
figure
g = gramm('x', LMANISI,'color', {'Directed','Undirected'})
g.stat_bin('edges',0:1:100,'normalization','pdf','geom','stairs','fill','transparent')
g.set_names('x','LMAN ISI (ms)','y','Probability density','color','Song type')
g.set_text_options('base_size',12)
% g.axe_property('XScale','log')
g.set_title('Random Network')
g.draw



figure
g = gramm('x', LMANISI,'color', {'Directed','Undirected'})
g.stat_bin('edges',logspace(.5,3,70),'normalization','pdf','geom','stairs','fill','transparent')
g.set_names('x','LMAN ISI (ms)','y','Probability density','color','Song type')
g.set_text_options('base_size',12)
g.set_title('Random Network')
g.axe_property('XScale','log')
g.draw




%% Plot DLM Input
figure
g = gramm('x',fliplr(o.stimulusTrain))
g.geom_raster
g.set_order_options('x',0);
g.set_names('x','Time (ms)','y','Cell Index','color','Cell type');
g.draw
% export_fig('DLM - Directed Input.png','-m3')








g = o.plot_raster('sort','none')

%% Make everything transparent and plack
g.facet_axes_handles.Color = [0,0,0,0]
g.facet_axes_handles.XColor = 'w'
g.facet_axes_handles.YColor = 'w'
for i = findall(gcf,'Type','text')'
    i.Color = 'w';
end
% export_fig('LMAN ISI Distribution.png','-m3')





%% Plot other stuff
% o.saveFigures = true;
% o.saveDirectory = 'C:\Users\russe\OneDrive - UW\Grad School\Fairhall Lab\figures\Stimulation\ring_mu.92_3'
% o.plot_raster('sort','none')
% o.plot_weights
% o.plot_mean_voltage
% o.plot_periodogram
% o.plot_correlation
% export_fig('AreaX-CorrelationGramm-Directed.png', '-m3','-trans')

