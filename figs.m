%% Assorted figures

time_padding = 100;



clustRep = (630+time_padding) ;


x = {};
for i = 1:o.Ne
     tmp = floor(o.spikes{i} / clustRep)+1;
    for j =  1:ceil(o.t_span / clustRep)
        x = [x; {mod(o.spikes{i}(tmp == j), clustRep)}];
    end
end

cluster = ceil(repelem(1:o.Ne, 1, ceil(o.t_span / clustRep)) * o.clusters/o.Ne)';
trial = repmat(1:ceil(o.t_span / clustRep), 1, o.Ne)';
neuron = repelem(1:o.Ne, 1, ceil(o.t_span / clustRep))';



figure('Position',[10,10,1900,1000])
g = gramm('x',x, 'color',trial)
% g.set_limit_extra(0,0,0)
g.facet_wrap(cluster,'ncols',4,'column_labels',1)
g.geom_raster('geom','line')
% g.stat_density('bandwidth',1.5,'npoints',600)
g.set_point_options('base_size',1.5)
g.set_continuous_color('active',0)
g.set_names('color','Trial #','column','Cluster','x','Time (ms)','y','')
g.axe_property('XLim',[-20,740])
g.draw


DLMOutputCluster = floor(linspace(1,9,o.Ne+1));
y = j*i/o.clusters

for i = 1:8
    x = [o.stimulusTrain{DLMOutputCluster==i}];
    x = mod(x(DLMOutputCluster==1),clustRep);
    x = unique(x);
    line(g.facet_axes_handles(i),[x;x], repmat([y;y+50],size(x)), 'Color', 'w');
    g.facet_axes_handles(i).Clipping = 'off';
%     g.facet_axes_handles(i).XRuler.TickLength = [0,0];
end



for i = findall(gcf,'Type','text')'
    i.Color = 'w';
end
for i = findall(gcf,'Type','axes')'
    i.Color = [0,0,0,0];
    i.XColor = 'w'
    i.YColor = 'w'
end
export_fig('LMAN-Stacked-Undirected.png', '-m3','-trans')
export_fig('LMAN-Stacked-Directed.png', '-m3','-trans')

figure
g = gramm('x',x, 'color',trial,'subset',~cellfun(@isempty,x))
g.facet_wrap(cluster,'ncols',4,'scale','free_y')
g.stat_density('bandwidth',2,'npoints',500)
g.set_continuous_color('active',0)
g.draw






x = {};
for i = o.excitatory_idx
     tmp = floor(o.stimulusTrain{i} / clustRep)+1;
    for j =  1:ceil(o.t_span / (630+time_padding))
        x = [x; {mod(o.stimulusTrain{i}(tmp == j), clustRep)}];
    end
end



























trial = [];
cluster = [];
x = {};
for i = 1:8
        tmp2 = [o.spikes{DLMOutputCluster==i}];
    tmp = floor(tmp2 / clustRep)+1;

    for j =  1:ceil(o.t_span / clustRep)
%         x = [x; {mod([o.stimulusTrain{DLMOutputCluster==i}], clustRep)}];
        x = [x; {mod(tmp2(tmp == j), clustRep)}];
        trial = [trial; i];
        
        %     x = mod(x(DLMOutputCluster==1),clustRep);
        %     x = unique(x);
        %     line(g.facet_axes_handles(i),[x;x], repmat([y;y+50],size(x)), 'Color', 'k');
        %     g.facet_axes_handles(i).Clipping = 'off';
        % %     g.facet_axes_handles(i).XRuler.TickLength = [0,0];
    end
end



figure
f = []
for i = 1:14
[f(i,:),xi] = ksdensity(x{i+98},0:1:640,'Bandwidth',2);
f(i,:) = f(i,:) * numel(x{i});
end


g = gramm('x',xi,'y',f)
g.stat_summary
g.facet_wrap(trial,'ncols',4)
g.draw

figure
plot(var(f)./(mean(f)))
plot(mean(f))
plot(std(f))

