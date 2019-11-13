function plot_correlation(o)

bin_size = 10 % bin size in ms


edges = round(linspace(0, o.t_span, o.t_span/bin_size));
binned_spikes = zeros(o.N, length(edges)-1);

for i = 1:length(o.W)
    if isempty(o.spikes{i})
            continue
    end
    binned_spikes(i,:)=histcounts(o.spikes{i}, edges);
end

% figure
% imagesc(binned_spikes)


D = corr(binned_spikes');
% Make the diagonal zero
D(1:(o.N+1):o.N^2) = 0;

% If a neuron never fires, the correlation is NaN, so get rid of it
D(isnan(D))=0;



figure('Position',[10,10,900,800],'Color','w')
imagesc(D)
colormap(redblue)
ylabel(colorbar,'Pearsons R');
caxis([-.5,.5])
pbaspect([1 1 1])
ylabel('Presynaptic Index')
xlabel('Postsynaptic Index')
title('Correlation')
% prctile(D,95,'all')
o.saveCurrentFigure('correlationMatrix')



figure('Position',[10,10,900,800],'Color','w')
g = gramm('x',D(~eye(o.N)),'color',sign(o.W(~eye(o.N))));
g.stat_density()
% g.stat_bin('normalization','pdf','nbins',100,'fill','transparent','geom','stairs')
g.set_names('x','Correlation','color','Sign of connection');
g.axe_property('XLim',[-1,1])
g.draw
o.saveCurrentFigure('correlationHistogram-Sign')


figure('Position',[10,10,900,800],'Color','w')
g = gramm('x',D(~eye(o.N)));
g.stat_bin('normalization','pdf','nbins',200,'fill','face','geom','stairs')
g.set_names('x','Correlation','y','Correlation pdf');
g.axe_property('XLim',[-1,1])
g.draw
o.saveCurrentFigure('correlationHistogram-All')

% 
% 
% dg = digraph(o.W)
% dg = subgraph(dg,o.excitatory_idx);
% d1 = distances(dg,'Method','mixed');
% d2 = D(o.excitatory_idx,o.excitatory_idx);
% d1 = o.W(o.excitatory_idx,o.excitatory_idx);
% 
% figure
% g = gramm('x',d1(:),'y',d2(:),'subset',d1(:)~=0);
% % g.stat_summary('setylim',1,'type','sem')
% g.geom_point
% % g.stat_bin2d('nbins',[40,40])
% g.set_point_options('base_size',1);
% g.set_names('x','Time (ms)','y','Cell Index','color','Cell type');
% g.draw
% 
% 
% 

