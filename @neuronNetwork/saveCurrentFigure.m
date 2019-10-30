function saveCurrentFigure(o,figName)

if o.saveFigures
    fname = sprintf(['%s ',...
        'N_%g ',...
        'clusters_%g',...
        'pEE_%.2g pEI_%.2g pIE_%.2g pII_%.2g.png'],...
        figName,...
        o.N,...
        o.clusters,...
        o.p_ee,o.p_ei,o.p_ie,o.p_ii);
    export_fig(fullfile(o.saveDirectory, fname),'-m3')
end
