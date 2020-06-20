function plot_mean_voltage(o)

bin_size = 1 % bin size in ms
edges = round(linspace(0, o.t_span, o.t_span/bin_size));
binned_spikes = zeros(o.N, length(edges)-1);
for i = 1:length(o.W)
    if isempty(o.spikes{i})
            continue
    end
    binned_spikes(i,:)=histcounts(o.spikes{i}, edges);
end
% convolve the spikes with a gaussian
sigma = 5; % standard deviation is milliseconds
binned_spikes = conv2(binned_spikes, normpdf(linspace(-30,30,50), 0,sigma), 'same');



g = gramm('x',linspace(0,o.t_span,size(binned_spikes,2)), 'y',binned_spikes .* 1000,'color',o.neuron_names);
g.stat_summary('setylim',1,'type','sem','geom','line')
g.set_names('x','Time (ms)','y','Mean spike rate (Hz)','color','Cell type');
g.set_line_options('base_size',1)



% g = gramm('x',(1:o.t_span/o.dt)*o.dt, 'y',o.syn_out_history,'color',o.neuron_names);
% g.stat_summary('setylim',1,'type','sem','geom','line')
% g.set_names('x','Time (ms)','y','Voltage','color','Cell type');
% g.set_line_options('base_size',1)

% Set the transparency
figure('Position',[10,10,1200,800])
g.draw;
% g.facet_axes_handles.Children(1).Color(4) = .5
% g.facet_axes_handles.Children(2).Color(4) = .5

% pos = get(g.facet_axes_handles, 'Position');
% yl = ylim(g.facet_axes_handles);
% xl = xlim(g.facet_axes_handles);
% for i = 0:500:o.t_span
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
%         [.03,.06]);
% end




o.saveCurrentFigure('voltage')

