function plot_degree(o)

figure
% x = indegree(digraph(o.W(o.excitatory_idx,o.excitatory_idx)));
x = sum(o.W(o.excitatory_idx,o.excitatory_idx),2)
g = gramm('x',x)
g.stat_bin('fill','transparent','normalization','pdf')
g.stat_density
g.set_names('x','Degree')
g.draw

o.saveCurrentFigure('degree')