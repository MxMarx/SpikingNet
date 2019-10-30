function plot_mean_voltage(o)

g = gramm('x',1:o.t_span/o.dt,'y',o.syn_out_history,'color',o.neuron_names);
g.stat_summary('setylim',1,'type','sem','geom','line')
g.set_names('x','Time (ms)','y','Voltage','color','Cell type');
g.set_line_options('base_size',1)

% Set the transparency
figure('Position',[10,10,1200,800])
g.draw;
g.facet_axes_handles.Children(1).Color(4) = .5
g.facet_axes_handles.Children(2).Color(4) = .5

o.saveCurrentFigure('voltage')
