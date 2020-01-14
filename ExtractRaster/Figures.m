raster = ExtractRaster()

%% Raster Plots
for j = 3:4
figure('Position',[10,10,1500,650])
g = gramm('x',fliplr(raster(j).DLM))
g.geom_raster
g.set_color_options('lightness',95,'chroma',0)
g.set_names('x','Time (ms)', 'y', 'Trial #')
% g.set_title(raster(j).title)
% g.set_title('DLM: Directed')
g.set_title('DLM: Undirected')
g.set_limit_extra([0.01,0],[0,0])
g.set_text_options('base_size',16)
g.draw
g.facet_axes_handles.Color = [0,0,0,0]
for i = findall(gcf,'Type','text')'
    i.Color = 'w';
end
for i = findall(gcf,'Type','axes')'
    i.Color = [0,0,0,0];
    i.XColor = 'w'
    i.YColor = 'w'
end
set(gcf,'color','k')
end
export_fig('Area X - Directed.png', '-m3','-trans')
export_fig('Area X - Undirected.png', '-m3','-trans')
export_fig('DLM - Directed.png', '-m3','-trans')
export_fig('DLM - Undirected.png', '-m3','-trans')




figure
x = [diff(raster(1).spikes) diff(raster(2).spikes)];
c = [repmat({'Directed'},1,numel(raster(1).spikes)-1),...
    repmat({'Undirected'},1,numel(raster(2).spikes)-1)];
g = gramm('x',x,'color',c,'subset',x>5);
% g.stat_bin('edges',0:.5:30,'geom','stairs','fill','transparent')
g.stat_density('bandwidth',.3,'npoints',500)
g.axe_property('XLim',[0,20])
g.set_names('x','Area X ISI (ms)','y','Probability Density','color','Song type')
g.draw
export_fig('Area X - ISI Density - 2.png','-m3')



figure
x = [diff(raster(1).spikes) diff(raster(2).spikes)];
c = [repmat({'Directed'},1,numel(raster(1).spikes)-1),...
    repmat({'Undirected'},1,numel(raster(2).spikes)-1)];
g = gramm('x',x,'color',c,'subset',x>0);
g.stat_bin('edges',5:2:26,'geom','stairs','fill','transparent','normalization','cumcount')
% g.stat_density('bandwidth',.3,'npoints',500)
g.axe_property('XLim',[0,26])
g.set_names('x','Area X ISI (ms)','y','ISI','color','Song type')
g.draw
export_fig('Area X - ISI Density - Right Tail.png','-m3')



x = 1:.1:20
plot(x, cumsum(mod(x-5,2)==0  & x >= 5));


DLM = {};
song = {};
T_pt = 5;
T_tt = 2;
for j = 1:2
    for i = 1:25
    ISI = diff(raster(j).rasterSpikes{i});
    thalamicSpikes = [];
    for k = 1:length(ISI)
        thalamicSpikes(k) = length((T_pt:T_tt:ISI(k)));
    end
    DLM{i} = thalamicSpikes;
    end
song{j} = DLM;   
end

for j = 1:2
    x = cell2mat(song{j});
    sum(x>=4)
    song2{j} = cumsum(fliplr(histcounts(x,1:1:12)));
end
c = [repmat({'Directed'},1,25),...
    repmat({'Undirected'},1,25)];
figure
g = gramm('x',11:-1:1,'y',[song2(1), song2(2)],'color', {'Directed','Undirected'})
% g.stat_bin('edges',1:.5:10,'normalization','count','geom','stairs','fill','transparent')
g.geom_line
g.geom_point
g.set_names('x','DLM spikes per burst','y','sum(count >= x)','color','Song type')
g.draw
export_fig('DLM spikes per burst','-m3')



y = [log10(histcounts(cell2mat(song{1}),0:15,'Normalization','pdf')),...
log10(histcounts(cell2mat(song{2}),0:15,'Normalization','pdf'))];
x = [0:14, 0:14];
c = [repmat({'Directed'},1,15),...
    repmat({'Undirected'},1,15)];
figure
g = gramm('x',x,'y',y,'color',c,'subset',~isinf(y))
g.geom_jitter
g.set_point_options('base_size',8)
g.set_names('x','# thalamic spikes in a pallidal ISI','y','Log probability density','color','Song type')
g.draw
export_fig('thalamic spikes in a pallidal ISI.png','-m3')




    
    
