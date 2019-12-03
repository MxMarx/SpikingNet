time_padding = 250;
time_padding = 10;



clustRep = (630+time_padding) ;

c = [];
r = [];
x = {};
for i = o.excitatory_idx
     tmp = floor(o.spikes{i} / clustRep)+1;
    for j =  1:ceil(o.t_span / (630+time_padding))
        x = [x; {mod(o.spikes{i}(tmp == j), clustRep)}];
            c = [c; j];
            r = [r; ceil(i*o.clusters/o.Ne)];
    end
end


figure('Position',[10,10,1900,1000])
g = gramm('x',x, 'color',c)
g.facet_wrap(r,'ncols',4,'column_labels',1)
g.geom_raster('geom','point')
g.set_point_options('base_size',1)
g.set_continuous_color('active',0)
g.set_names('color','Trial #','column','Cluster','x','Time (ms)','y','')
g.axe_property('XLim',[-20,650])
g.draw

for i = 1:8
g.facet_axes_handles(i).Color = [0,0,0,0]
g.facet_axes_handles(i).XColor = 'w'
g.facet_axes_handles(i).YColor = 'w'
% g.facet_axes_handles(i).Children(1).Color = 'w'
end

for i = findall(gcf,'Type','text')'
    i.Color = 'w';
end
export_fig('Gramm-DLM-Directed.png', '-m3','-trans')

figure
g = gramm('x',x, 'color',c,'subset',~cellfun(@isempty,x))
g.facet_wrap(r,'ncols',4,'scale','free_y')
g.stat_density('bandwidth',2,'npoints',500)
g.set_continuous_color('active',0)
g.draw






c = [];
r = [];
x = {};
for i = o.excitatory_idx
     tmp = floor(o.stimulusTrain{i} / clustRep)+1;
    for j =  1:ceil(o.t_span / (630+time_padding))
        x = [x; {mod(o.stimulusTrain{i}(tmp == j), clustRep)}];
            c = [c; j];
            r = [r; ceil(i*o.clusters/o.Ne)];
    end
end

