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

figure('Position',[10,10,1000,800])
g = gramm('x',o.spikes(sortOrder),'color',o.neuron_names(sortOrder));
g.geom_raster('geom','line');
g.set_order_options('x',0);
g.set_names('x','Time (ms)','y','Cell Index','color','Cell type');
g.draw;

o.saveCurrentFigure('raster')