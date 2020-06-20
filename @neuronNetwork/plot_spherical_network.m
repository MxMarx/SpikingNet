function plot_spherical_network(o)

%% Plot some neurons to see if it worked!
figure('Color', 'w', 'Position', [10,10,1000,800])
h = plot3(o.neuronCoordinates(:,1),o.neuronCoordinates(:,2),o.neuronCoordinates(:,3),'.','MarkerSize',6)
axis equal
hold on
for i = randi(o.Ne,1,8)
    neighbors = o.W(i, o.excitatory_idx) > 0;
    plot3(...
        [o.neuronCoordinates(neighbors,1) repmat(o.neuronCoordinates(i,1), sum(neighbors),1)]',...
        [o.neuronCoordinates(neighbors,2) repmat(o.neuronCoordinates(i,2), sum(neighbors),1)]',...
        [o.neuronCoordinates(neighbors,3) repmat(o.neuronCoordinates(i,3), sum(neighbors),1)]',...
        'Color',hsv2rgb([rand(1),.8,.8]),'LineWidth',1.8)
end
title('Network Visualization')
% export_fig NetworkGraph.png -m3
% Drag the figure to rotate!

%% plot the centroid
figure('Color', 'w', 'Position', [10,10,640,600])
xyz = o.neuronCoordinates' * o.syn_out_history(o.excitatory_idx, :) ./   sum(o.syn_out_history(o.excitatory_idx, :));
% plot3(xyz(1,:),xyz(2,:),xyz(3,:))
surface([xyz(1,:);xyz(1,:)],[xyz(2,:);xyz(2,:)],[xyz(3,:);xyz(3,:)],[1:length(xyz);1:length(xyz)],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',2,...
        'EdgeAlpha',1);
    
axis equal
title('Trajectory of the centroid over time')
% comet3(xyz(1,:),xyz(2,:),xyz(3,:))



% Plot the activity in 3D
i=1
figure('Color', 'w', 'Position', [10,10,640,600])
h = scatter3(o.neuronCoordinates(:,1),o.neuronCoordinates(:,2),o.neuronCoordinates(:,3),16,'filled')
h.Parent.Position = [0,0,1,1]
view(0,90)
h.CData = o.neuronCoordinates(:,3)
cmap = gramm.pa_LCH2RGB([linspace(65,65,100)', linspace(100,100,100)', linspace(280,430,100)'])
% cmap = cmap(ceil(rescale(o.neuronCoordinates(:,2), 1, 100)), :)
% azimuth = acos( o.neuronCoordinates(:,2)' ./  vecnorm(o.neuronCoordinates'));
azimuth =    o.neuronCoordinates(:,3) ./ sqrt(25 - (o.neuronCoordinates(:,1).^2 + o.neuronCoordinates(:,2).^2))
% azimuth = o.neuronCoordinates(:,3);

cmap = cmap(ceil(rescale(azimuth, 1, 100)), :);
h.CData = cmap;

axis equal
box off
axis off
camproj('perspective')
for i = 1:10:length(o.voltageHistory)
    h.CData = (.98 - (o.syn_out_history(o.excitatory_idx, i) .* 4)) + (o.syn_out_history(o.excitatory_idx, i) .* cmap .* 4);
    drawnow
    pause(.05)
end
 
 
 
 
 
 
%% Plot the activity in 3D along with PCs
[eigValues, eigVectors, momentOfInertia, centroid] = calculatePCA(o);
figure; plot(momentOfInertia)

i=1
figure('Color', 'w', 'Position', [10,10,640,600])
h = scatter3(o.neuronCoordinates(:,1),o.neuronCoordinates(:,2),o.neuronCoordinates(:,3),12, o.voltageHistory(o.excitatory_idx, i),'filled')
h.Parent.Position = [0,0,1,1]
axis equal
box off
caxis([-.015,.2])
axis off
camproj('perspective')
view(0,90)

hold on
h2 = scatter3(0,0,0,200,'r','filled')
colormap(flipud(magma))
colormap(flipud(bone))

h3 = gobjects();
for j = 1:size(o.neuronCoordinates,2)
    h3(j) = plot3(0,0,0,'color','r');
end
hold off

% myVideo = VideoWriter('C:\Users\Russell\Desktop\network','MPEG-4'); %open video file
% myVideo.FrameRate = 30;  %can adjust this, 5 - 10 works well for me
% open(myVideo)

for i = 1:10:length(o.voltageHistory)
    for j = 1:length(h3)
        h3(j).XData = [eigVectors(1,j,i), -eigVectors(1,j,i)] .* sqrt(eigValues(j,i)) + centroid(1,i);
        h3(j).YData = [eigVectors(2,j,i), -eigVectors(2,j,i)] .* sqrt(eigValues(j,i)) + centroid(2,i);
        h3(j).ZData = [eigVectors(3,j,i), -eigVectors(3,j,i)] .* sqrt(eigValues(j,i)) + centroid(3,i);
    end
    h2.XData = centroid(1,i);
    h2.YData = centroid(2,i);
    h2.ZData = centroid(3,i);
    h2.SizeData = momentOfInertia(i).^2 * 100 + 1;
    
    h.CData = o.syn_out_history(o.excitatory_idx, i);
    drawnow
%     camorbit(.2,0)
    pause(.03)
%     frame = getframe(gcf); %get frame
%     writeVideo(myVideo, frame);
end

% close(myVideo)

% %% Initialize video
% myVideo = VideoWriter('C:\Users\Russell\Desktop\network','MPEG-4'); %open video file
% myVideo.FrameRate = 30;  %can adjust this, 5 - 10 works well for me
% open(myVideo)
% 
% figure('Color', 'k', 'Position', [10,10,600,500])
% h = scatter(o.neuronCoordinates(:,1),o.neuronCoordinates(:,2),10,'filled')
% h.Parent.Position = [0,0,1,1]
% axis equal
% box off
% caxis([0,.25])
% axis off
% camproj('perspective')
% for i = 1:10:length(o.voltageHistory) / 2
%     h.CData = o.syn_out_history(o.excitatory_idx, i)
%     drawnow
% %     camorbit(.5,.5)
% %     pause(.03)
%     
%     frame = getframe(gcf); %get frame
%     writeVideo(myVideo, frame);
% end
% 
% 
% close(myVideo)




