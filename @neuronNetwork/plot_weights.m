function plot_weights(o)

figure('Position',[10,10,900,800],'Color','w')
imagesc(o.W)
colormap(redblue)
colorbar
caxis([-prctile(o.W(o.W~=0),95), prctile(o.W(o.W~=0),95)])
pbaspect([1 1 1])
ylabel('Presynaptic Index')
xlabel('Postsynaptic Index')
title('Weights')

o.saveCurrentFigure('weights')