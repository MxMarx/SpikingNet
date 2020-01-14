function raster = ExtractRaster()
%{
raster = ExtractRaster()
Returns a 1x4 struct with the extracted spikes from figures 4 and 6

raster(1) = Fig 4 - Area X: Directed
raster(2) = Fig 4 - Area X: Undirected
raster(3) = Fig 6 - Area X: Directed
raster(4) = Fig 6 - Area X: Undirected

raster.DLM is a cell aarray with the calculated thalamic spikes for each
    row in the Area X raster
raster.rasterSpikes is a cell array with the time (ms) of each Area X spike
    for each row in the raster
raster.spikes is raster.rasterSpikes except in a matrix instead of a cell
%}

Fig{1} = imread('ExtractRaster\gr4_lrg.jpg');
Fig{2} = imread('ExtractRaster\gr6_lrg.jpg');


% Pixel -> Millisecond
msPerPixel = 100 / 311;

% figure
% h = axes
% imshow(im(2250:2750, 100:2300), 'parent', h)
% hold(h,'on')



raster(1).left = 300; % Coordinates of left edge
raster(1).right = 2300; % Coordinates of right edge
raster(1).top = 393; % Coordinates of top edge
raster(1).bottom = 1100; % Coordinates of bottom edge
raster(1).numberOfLines = 25; % Number of rows
raster(1).title = 'Area X: Directed';
raster(1).imageIndex = 1;

raster(2).left = 300;
raster(2).right = 2300;
raster(2).top = 1170;
raster(2).bottom = 1877;
raster(2).numberOfLines = 25;
raster(2).title = 'Area X: Undirected';
raster(2).imageIndex = 1;


raster(3).left = 270;
raster(3).right = 2300;
raster(3).top = 784;
raster(3).bottom = 1456;
raster(3).numberOfLines = 25;
raster(3).title = 'Area X: Directed';
raster(3).imageIndex = 2;

raster(4).left = 270;
raster(4).right = 2300;
raster(4).top = 1515;
raster(4).bottom = 2200;
raster(4).numberOfLines = 25;
raster(4).title = 'Area X: Undirected';
raster(4).imageIndex = 2;


for j = 1:length(raster)
    im = Fig{raster(j).imageIndex};
    y = round(linspace(raster(j).top, raster(j).bottom, raster(j).numberOfLines));
    
    spikes = [];
    rasterSpikes = {};
    for i = 1:raster(j).numberOfLines
        rasterRow = im(y(i), raster(j).left:raster(j).right);
        rasterRow = 1 - double(rasterRow)/255;
        [~, loc] = findpeaks(rasterRow, 'MinPeakHeight',.5,'MinPeakProminence',.2,'MinPeakDistance',2);
        spikes = [spikes,loc * msPerPixel];
        rasterSpikes =  [rasterSpikes,{loc * msPerPixel}];
    end
    [fDirected,xi] = ksdensity(spikes, (0:2000) * msPerPixel,'Bandwidth',1.8);
    
    
    %     plot(h,185 + 1.015*xi/msPerPixel,405-(405-50)/600*(fDirected * 1000 * numel(spikes)/coords(j).numberOfLines),  'LineWidth',3)
    %     h.Children(1).Color(4) = .7;
    
    %     figure('Position',[10,10,1500,650])
    %     g = gramm('x',fliplr(rasterSpikes))
    %     g.geom_raster
    %     g.set_color_options('lightness',25,'chroma',0)
    %     g.set_names('x','Time (ms)', 'y', 'Trial #')
    %     g.set_title(coords(j).title)
    %     g.draw
    
    %% Calculate the thalamaic spikes
    DLM = {};
    T_pt = 5;
    T_tt = 2;
    for i = 1:raster(j).numberOfLines
        ISI = diff(rasterSpikes{i});
        thalamicSpikes = [];
        for k = 1:length(ISI)
            thalamicSpikes = [thalamicSpikes,...
                rasterSpikes{i}(k) + (T_pt:T_tt:ISI(k))];
        end
        DLM{i} = thalamicSpikes;
    end
    
    
    
    raster(j).DLM = DLM;
    raster(j).rasterSpikes = rasterSpikes;
    raster(j).spikes = spikes;
    
    
end


%
% pISI = diff(spikes);
% histogram(pISI(pISI > 0))
% spikesPerISI = 1 + (pISI - 4) / 2;
% spikesPerISI = ceil(max(spikesPerISI,0));
% histogram(spikesPerISI)
% spikesPerISI =


%%
%
% for j = coords(1)
%     y = round(linspace(j.top, j.bottom, j.numberOfLines));
%     spikes = [];
%     rasterSpikes = {};
%     for i = 1:j.numberOfLines
%         raster = im(y(i), j.left:j.right);
%         raster = 1 - double(raster)/255;
%         [~, loc] = findpeaks(raster, 'MinPeakHeight',.5,'MinPeakProminence',.2,'MinPeakDistance',2);
%         spikes = [spikes,loc * msPerPixel];
%         rasterSpikes =  [rasterSpikes,{loc * msPerPixel}];
%     end
%     [fDirected,xi] = ksdensity(spikes, (0:2000) * msPerPixel,'Bandwidth',1.8);
%     figure
%     g = gramm('x',fliplr(rasterSpikes))
%     g.geom_raster
%     g.set_color_options('lightness',25,'chroma',0)
%     g.draw
% end



%
% figure
% g = gramm('x',fliplr(DLM))
% g.geom_raster
% g.set_color_options('lightness',25,'chroma',0)
% g.draw
%
%
%
% stimulusTrain = repmat(-1,25,630 / o.dt);
% for i = 1:25
%     y = [0; DLM{i}] / o.dt;
%     y(diff(y)==0) = [];
%     stimulusTrain(i,y(2:end)) = diff(y) - 1;
% end
% stimulusTrain = cumsum(-stimulusTrain, 2)+1;
% stimulusTrain = min(stimulusTrain, length(epsp));
% stimulusTrain = epsp(stimulusTrain);
%
%
%
