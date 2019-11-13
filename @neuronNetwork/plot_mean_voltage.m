function plot_mean_voltage(o)

g = gramm('x',(1:o.t_span/o.dt)*o.dt, 'y',o.syn_out_history,'color',o.neuron_names);
g.stat_summary('setylim',1,'type','sem','geom','line')
g.set_names('x','Time (ms)','y','Voltage','color','Cell type');
g.set_line_options('base_size',1)

% Set the transparency
figure('Position',[10,10,1200,800])
g.draw;
g.facet_axes_handles.Children(1).Color(4) = .5
g.facet_axes_handles.Children(2).Color(4) = .5


pos = get(g.facet_axes_handles, 'Position');
yl = ylim(g.facet_axes_handles);
xl = xlim(g.facet_axes_handles);
for i = 0:500:o.t_span
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
        [.03,.06]);
end




o.saveCurrentFigure('voltage')
