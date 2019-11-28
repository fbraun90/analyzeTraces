function copyTracePlot(varargin)
    
    handles = guidata(gcbf);
    
    % creates new figure from axes plot and copys to clipboard
    currAxes = handles.trace;
    newFig = figure('visible','on');
    newHandle = copyobj(currAxes,newFig);
    newHandle.OuterPosition = [0 0 1 1];
    print(newFig,'-dmeta');
    delete(newFig);
    
end