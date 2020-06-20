function saveCurrentFigure(o,figName)

if o.saveFigures
    if ~isdir(o.saveDirectory)
        mkdir(o.saveDirectory)
    end
    fname = sprintf('%s.png',...
        figName)
    export_fig(fullfile(o.saveDirectory, fname),'-m3')
end
