function plot_correlation(o)
% Plot the correlation between neurons

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


D = corr(binned_spikes');
% Make the diagonal zero
D(1:(o.N+1):o.N^2) = 0;

% If a neuron never fires, the correlation is NaN, so get rid of it
% D(isnan(D))=0;



% figure('Position',[10,10,900,800],'Color','w')
% im = imagesc(D,'AlphaData',~isnan(D),'AlphaDataMapping','none')
% % im = imagesc(D)
% colormap(redblue(255))
% h = colorbar
% % h.Color = 'w'
% ylabel(h,'Pearsons R','Color','w');
% caxis([-1,1])
% pbaspect([1 1 1])
% ylabel('Presynaptic Index','Color','k')
% xlabel('Postsynaptic Index','Color','k')
% title('Correlation')
% % im.Parent.Color = [0 0 0 0]
% % im.Parent.XColor = 'w'
% % im.Parent.YColor = 'w'
% o.saveCurrentFigure('correlationMatrix')


figure('Position',[10,10,620,420],'Color','w')
diagonal = eye(o.N) | (rand(o.N) > .1);
g = gramm('x',D(:),'color',sign(o.W(:)), 'subset', ~diagonal(:));
g.stat_density()
% g.stat_bin('normalization','pdf','nbins',100,'fill','transparent','geom','stairs')
g.set_names('x','Correlation','color','Sign of connection','y','pdf');
g.axe_property('XLim',[-1,1])
g.draw
o.saveCurrentFigure('correlationHistogram-Sign')


% figure('Position',[10,10,900,800],'Color','w')
% g = gramm('x',D(~eye(o.N)));
% g.stat_bin('normalization','pdf','nbins',200,'fill','face','geom','stairs')
% g.set_names('x','Correlation','y','Correlation pdf');
% g.axe_property('XLim',[-1,1])
% g.draw
% o.saveCurrentFigure('correlationHistogram-All')



% 
% 
% 
% 
% % 
% figure
% [row, col] = find(y > .9)
% g = gramm('x',o.spikes(row))
% g.geom_raster
% g.draw
% % 

cmap = [0 0.7375 0.8344
     1 0.3673 0.4132];
 
dist = pdist2(o.neuronCoordinates, o.neuronCoordinates);
y = D(o.excitatory_idx, o.excitatory_idx);

c = sign(o.W(o.excitatory_idx, o.excitatory_idx));
c = full(c(:));
% 
% subset = find(c);
% subset = [subset; randsample(find(~c), length(subset), false)];

subset = randi(length(c),1e4,1);
x = dist(subset);
y = y(subset);
color = cmap(c(subset) + 1, :);



figure('Position',[10,10,900,800],'Color','w')
g = gramm('y',y, 'x', x, 'color', c(subset))
% g.stat_bin2d('geom','contour','nbins',[20,20])
g.geom_point()
g.set_names('x','Distance','y','Correlation','color','Sign of connection');
g.set_point_options('base_size',2)
g.draw

% 
% figure('Position',[10,10,540,480],'Color','w')
% hold on; h = []
% for i = 0:1
%     h(i+1) = scatter(NaN,NaN,8,cmap(i+1,:),'filled')
% end
% for i = 1:-1:0
%     scatter(x(c(subset) == i),y(c(subset)==i),6,cmap(i+1,:),'filled', 'MarkerFaceAlpha', .25)
% end
% legend(h, {'Unconnected', 'Connected'}, 'Box', 'off','FontSize',12)
% hold off
% xlabel('Distance')
% ylabel('Correlation')
o.saveCurrentFigure('correlationByDistance')


% figure
% g = gramm('x',x,'y',y)
% g.stat_bin2d('geom','contour','nbins',[3,3])
% g.draw

%% Degree
dg = digraph(o.W)
dg = subgraph(dg,o.excitatory_idx);
dg = graph(adjacency(dg)+transpose(adjacency(dg)))

x = distances(dg,'Method','unweighted');
y = D(o.excitatory_idx, o.excitatory_idx);

x = x(:);
y = y(:);

figure
g = gramm('x',x,'y',y,'subset',x~=0);
g.stat_summary('setylim',0,'type','quartile','geom','black_errorbar')
% g.geom_point
% g.stat_bin2d('nbins',[40,40])
g.stat_violin('width',.8,'normalization','width', 'fill','transparent')
g.set_point_options('base_size',1);
g.set_names('x','Path length','y','Correlation');
g.draw
o.saveCurrentFigure('correlationByDegree')




