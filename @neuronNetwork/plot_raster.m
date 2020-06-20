function g = plot_raster(o,varargin)
% Make a raster plot
p = inputParser;
p.addParameter('sort','none', @(x) any(validatestring(x,{'cluster','rate','none','distance'})));
p.parse(varargin{:});

switch p.Results.sort
    case 'cluster'
        % Sort by dendrogram
        x = downsample(o.syn_out_history',8)';
        D = pdist(x,'correlation');
        D(isnan(D)) = 0;
        tree = linkage(D,'average');
        sortOrder = optimalleaforder(tree,D,'Criteria','group');
        
    case 'rate'
        % Sort by firing rate
        [~, sortOrder] = sort(cellfun(@length,o.spikes));
    case 'none'
        sortOrder = 1:o.N;
    case 'distance'
        dist = vecnorm(o.neuronCoordinates,2,2);
        [~, sortOrder] = sort(dist);
        sortOrder = [sortOrder' length(sortOrder)+1:o.N];
end

color = zeros(o.N,1);
edges = round(linspace(1,o.Ne,o.clusters + 1));
for i = 1:o.clusters
    color(edges(i):edges(i+1)) = i;
end


figure('Position',[10,10,1500,800])
% g = gramm('x',o.spikes(sortOrder),'color',o.neuron_names(sortOrder));
g = gramm('x',o.spikes(sortOrder),'color',color(sortOrder));
g.set_continuous_color('active',0);
g.geom_raster('geom','point');
% g.geom_raster('geom','line');
g.set_point_options('base_size',3);
g.set_order_options('color',-1)
g.set_names('x','Time (ms)','y','Cell Index','color','Cluster');
g.set_limit_extra([0.01,0],[0,0])
g.set_text_options('base_size',14)
g.draw;
g.legend_axe_handle.Children(end-2).String = 'Inhibitory';

% pos = get(g.facet_axes_handles, 'Position');
% yl = ylim(g.facet_axes_handles);
% xl = xlim(g.facet_axes_handles);
% for i = 500
%     % Positins for the end of the Arrow in data units.
%     xPosition = i;
%     yPosition = -100;
%     HWHM = i;
%     HM = -60;
%     % Create a textarrow annotation at the coordinates in data units
%     % the textarrow coordinates are given [end_x, head_x], [end_y, head_y]
%     ta1 = annotation('textarrow',...
%         [(xPosition + abs(min(xl)))/diff(xl) * pos(3) + pos(1),...
%         (HWHM + abs(min(xl)))/diff(xl) * pos(3) + pos(1) ],...
%         [(yPosition - min(yl))/diff(yl) * pos(4) + pos(2),...
%         (HM - min(ylim))/diff(yl) * pos(4) + pos(2)]);
% end

    


o.saveCurrentFigure('raster')