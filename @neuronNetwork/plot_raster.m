function plot_raster(o,varargin)

p = inputParser;
p.addParameter('sort','none', @(x) any(validatestring(x,{'cluster','rate','none'})));
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
end

color = zeros(o.N,1);
edges = round(linspace(1,o.Ne,o.clusters + 1));
for i = 1:o.clusters
    color(edges(i):edges(i+1)) = i;
end

color = max(color) - color;

figure('Position',[10,10,1000,800])
% g = gramm('x',o.spikes(sortOrder),'color',o.neuron_names(sortOrder));
g = gramm('x',o.spikes(sortOrder),'color',color(sortOrder));

g.geom_raster('geom','line');
g.set_order_options('x',0);
g.set_names('x','Time (ms)','y','Cell Index','color','Cell type');
g.draw;


pos = get(g.facet_axes_handles, 'Position');
yl = ylim(g.facet_axes_handles);
xl = xlim(g.facet_axes_handles);
for i = []%500
    % Positins for the end of the Arrow in data units.
    xPosition = i;
    yPosition = -100;
    HWHM = i;
    HM = -60;
    % Create a textarrow annotation at the coordinates in data units
    % the textarrow coordinates are given [end_x, head_x], [end_y, head_y]
    ta1 = annotation('textarrow',...
        [(xPosition + abs(min(xl)))/diff(xl) * pos(3) + pos(1),...
        (HWHM + abs(min(xl)))/diff(xl) * pos(3) + pos(1) ],...
        [(yPosition - min(yl))/diff(yl) * pos(4) + pos(2),...
        (HM - min(ylim))/diff(yl) * pos(4) + pos(2)]);
end

    


o.saveCurrentFigure('raster')