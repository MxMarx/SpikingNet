function plot_weights(o)

figure('Position',[10,10,900,800],'Color','w')
imagesc(o.W)
colormap(redblue)
colorbar
caxis([-.5,.5])
pbaspect([1 1 1])
ylabel('Presynaptic Index')
xlabel('Postsynaptic Index')
title('Weights')

o.saveCurrentFigure('weights')