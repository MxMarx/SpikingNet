function plot_degree(o)

figure
clear g

x = [
    full(sum(o.W > 0,1))'
    full(sum(o.W < 0,1))'
    ];

color = repelem({'Excitatory Cells','Inhibitory Cells','Excitatory Cells','Inhibitory Cells'},1,[o.Ne,o.Ni,o.Ne,o.Ni]);
column = repelem({'Excitatory Input','Inhibitory Input'},1,[o.N,o.N]);

g(1,1) = gramm('x',full(x), 'color', color','column',column);
g(1,1).stat_bin('fill','transparent','normalization','pdf','geom','overlaid_bar','edges',0:max(x));
g(1,1).stat_density();
g(1,1).set_names('x','In-degree','color','Target Type');

x = {
    full(sum(o.W(o.excitatory_idx, o.excitatory_idx) ~= 0,2))
    full(sum(o.W(o.excitatory_idx, o.inhibitory_idx) ~= 0,2))
    full(sum(o.W(o.inhibitory_idx, o.excitatory_idx) ~= 0,2))
    full(sum(o.W(o.inhibitory_idx, o.inhibitory_idx) ~= 0,2))
    };
color = {'Excitatory Target','Inhibitory Target','Excitatory Target','Inhibitory Target'}
column = {'Excitatory Source','Excitatory Source','Inhibitory Source','Inhibitory Source'}

g(2,1) = gramm('x',x, 'color', color,'column',column);
g(2,1).stat_bin('fill','transparent','normalization','pdf','geom','overlaid_bar','edges',0:max(vertcat(x{:})));
g(2,1).stat_density();
g(2,1).set_names('x','out-degree','color','Input type');

g.axe_property('XLim',[0, max(vertcat(x{:}))]);
% g(2,1).axe_property('XLim',[0, max(vertcat(x{:}))])

g.draw
o.saveCurrentFigure('degree')


if ~isempty(o.neuronCoordinates)
    clear g
    x = vecnorm(o.neuronCoordinates');
%         [~, i] = sort(x);
%         x = 1:length(x)
%         x(i) = x;
        
    y = full([
        sum(o.W(1:o.Ne,1:o.Ne)>0,2)
        sum(o.W(1:o.Ne,1:o.Ne)>0,1)'
    ]);
    

    x = [x x];

% y = y([i i+length(i)])
column = repelem({'Out-degree','In-degree'},1,[o.Ne,o.Ne]);

    figure
    g = gramm('x',x,'y',y,'column',column);
    g.geom_point
    g.stat_smooth
    g.set_point_options('base_size',2);
    g.set_names('x','Distance from center of network', 'y', 'Degree of connectivity')
    g.draw
    
end
