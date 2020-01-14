time_padding = 10;
clustRep = (630+time_padding) ;

o = DR
o = UR
% 
spikes = cellfun(@(x) mod(x,clustRep), o.spikes(1:o.Ne),'UniformOutput',0);
trial = cellfun(@(x) ceil(x/clustRep), o.spikes(1:o.Ne),'UniformOutput',0);
neuron = cellfun(@(x,y) repmat(y,1,length(x)), o.spikes(1:o.Ne), num2cell(1:o.Ne),'UniformOutput',0);
spikes = [spikes{:}];
trial = [trial{:}];
neuron = [neuron{:}];
cluster = o.clusterIndex(neuron);


[~, subset] = unique(cluster);
% subset = ismember(neuron,neuron(subset) + 4);
% subset = ismember(neuron,neuron(subset) + 12);
subset = ismember(neuron,neuron(subset) + 21);

subset = subset & cluster < 5;



% figure('Position',[10,10,1200,700])
% % g = gramm('x',spikes, 'y',trial,'subset',subset)
% g = gramm('x',spikes, 'y',trial,'subset',subset,'color',cluster)
% % g.set_limit_extra(0,0,0)
% g.facet_wrap(cluster,'ncols',4,'column_labels',1)
% g.geom_raster('geom','line')
% % g.stat_density('bandwidth',1.5,'npoints',600)
% g.set_point_options('base_size',1.5)
% g.set_continuous_color('active',0)
% g.set_names('color','Trial #','column','Neuron','x','Time (ms)','y','Trial #')
% % g.axe_property('XLim',[-20,740])
% g.no_legend
% g.draw

% figure('Position',[10,10,2000,400])
figure('Position',[10,10,1200,400])

% g = gramm('x',spikes, 'y',trial,'subset',subset)
g = gramm('x',spikes, 'y',trial,'subset',subset,'color',cluster)
% g.set_limit_extra(0,0,0)
g.facet_wrap(cluster,'ncols',4,'column_labels',1)
g.geom_raster('geom','line')
% g.stat_density('bandwidth',1.5,'npoints',600)
g.set_point_options('base_size',1.5)
g.set_continuous_color('active',0)
g.set_names('color','Trial #','column','Neuron','x','Time (ms)','y','Trial #')
% g.axe_property('XLim',[-20,740])
g.no_legend
g.draw


y = ceil(o.t_span / clustRep);
j = unique(neuron(subset));


for i = 1:4
    x = o.stimulusTrain{j(i)};
    x = x(x<clustRep);
    line(g.facet_axes_handles(i),[x;x], repmat([y+2;y+4],size(x)), 'Color', 'w');
    g.facet_axes_handles(i).Clipping = 'off';
%     g.facet_axes_handles(i).XRuler.TickLength = [0,0];
g.facet_axes_handles(i).YLim = [0, y + 2];
end


for i = findall(gcf,'Type','text')'
    i.Color = 'w';
end
for i = findall(gcf,'Type','axes')'
    i.Color = [0,0,0,0];
    i.XColor = 'w'
    i.YColor = 'w'
end
set(gcf,'color','k')
% 
% 
% export_fig('LMAN-Stacked-Clustered-Directed-OneRow.png', '-m3','-trans')
% export_fig('LMAN-Stacked-Clustered-Undirected-OneRow.png', '-m3','-trans')
% export_fig('LMAN-Stacked-Random-Directed-OneRow.png', '-m3','-trans')
% export_fig('LMAN-Stacked-Random-Undirected-OneRow.png', '-m3','-trans')

% export_fig('LMAN-Stacked-Random-Directed.png', '-m3','-trans')

% export_fig('LMAN-Stacked-Undirected.png', '-m3','-trans')
% export_fig('LMAN-Stacked-Directed.png', '-m3','-trans')
% 
% 
% 
% export_fig('LMAN-Stacked-Clustered-Directed.png', '-m3','-trans')
% export_fig('LMAN-Stacked-Random-Directed.png', '-m3','-trans')
% 
% 
% 
% export_fig('LMAN-Stacked-Clustered-Undirected.png', '-m3','-trans')
% export_fig('LMAN-Stacked-Random-Undirected.png', '-m3','-trans')
% 
% 
% 
% 
% 


% export_fig('LMAN-Neuron-Random-Undirected - 1.png', '-m3','-trans')
% export_fig('LMAN-Neuron-Random-Directed - 1.png', '-m3','-trans')

% export_fig('LMAN-Neuron-Random-Undirected - 2.png', '-m3','-trans')






