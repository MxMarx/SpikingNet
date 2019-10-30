function plot_periodogram(o)
%% Individual periodogram
max_freq = 1000;
[pxxO,f] = periodogram(o.syn_out_history', [],[],1000/o.dt);
[pxxV,f] = periodogram(o.voltageHistory', [],[],1000/o.dt);
idx = find(f>max_freq,1);
pxxO = pxxO(1:idx,:);
pxxV = pxxV(1:idx,:);
x = f(1:idx);
y = pow2db([pxxO,pxxV]');
g = gramm('x',x,'y',y,'color',[o.neuron_names;o.neuron_names],...
    'column',[repmat({'Spikes'},o.N,1); repmat({'Voltage'},o.N,1)],'subset',all(isfinite(y),2));
g.stat_summary('setylim',1,'type','quartile');
g.axe_property('XScale','log');
g.set_names('x','Frequency','y','Power','color','Cell type');


figure('Position',[10,10,1200,800])
g.draw;
o.saveCurrentFigure('Periodogram')
