function Statistics(figure)

    handles = guidata(figure);
    traces = getappdata(gcf, 'traces');
                    
    if not(isfield(handles.functions.Statistics, 'panel'))
%         handles.functions.Statistics = struct();
%         handles.functions.Statistics = struct('name', 'Statistics',...
%             'callback', @functions.Statistics);
        handles.functions.Statistics.panel = uipanel(...
            'Parent', gcf, ...
            'Units', 'normalized', ...
            'Position', [.32, .01, .33, .44], ...
            'Title', 'Statistics',...
            'Visible', 'off');
        
        % controls
        uicontrol('Parent', handles.functions.Statistics.panel, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'right',...
            'Units', 'normalized', ...
            'Position', [.02 .85 .17 .1], ...
            'String', 'Input', ...
            'BusyAction', 'cancel');
        handles.functions.Statistics.input = uicontrol(...
            'Parent', handles.functions.Statistics.panel,...
            'Style', 'popupmenu',...
            'Units', 'normalized',...
            'Position', [.2 .85 .3 .1],...
            'String', '-',...
            'Value', 1);
%         uicontrol('Parent', handles.functions.Statistics.panel, ...
%             'Style', 'text', ...
%             'HorizontalAlignment', 'right',...
%             'Units', 'normalized', ...
%             'Position', [.02 .75 .17 .1], ...
%             'String', 'Average Width', ...
%             'BusyAction', 'cancel');
%         handles.functions.Statistics.avgWidth = uicontrol(...
%             'Parent', handles.functions.Statistics.panel, ...
%             'Style', 'Edit', ...
%             'Units', 'normalized', ...
%             'Position',[.2 .78 .3 .07],...
%             'String', 5);
%         uicontrol( 'Parent', handles.functions.Statistics.panel, ...
%             'Style', 'text', ...
%             'HorizontalAlignment', 'right',...
%             'Units', 'normalized', ...
%             'Position', [.02 .65 .17 .1], ...
%             'String', 'Output', ...
%             'BusyAction', 'cancel'); 
%         handles.functions.Statistics.output = uicontrol(...
%             'Parent', handles.functions.Statistics.panel, ...
%             'Style', 'Edit', ...
%             'Units', 'normalized', ...
%             'Position',[.2 .68 .3 .07], ...
%             'String', 'Statistics');
        uicontrol('Parent', handles.functions.Statistics.panel, ...
            'Style', 'Pushbutton', ...
            'Units', 'normalized', ...
            'Position',[.02 .01 .2 .1], ...
            'String', 'Histogram over all traces', ...
            'Callback', @makeHistogram);
        uicontrol('Parent', handles.functions.Statistics.panel, ...
            'Style', 'Pushbutton', ...
            'Units', 'normalized', ...
            'Position',[.22 .01 .2 .1], ...
            'String', 'Categorize traces with less than 5 frames over 10000', ...
            'Callback', @threshold);
        uicontrol('Parent', handles.functions.Statistics.panel, ...
            'Style', 'Pushbutton', ...
            'Units', 'normalized', ...
            'Position',[.42 .01 .2 .1], ...
            'String', 'Reset', ...
            'Callback', @reset);

    guidata(gcf, handles);
    
    end
        
    if not(isempty(traces))
        if not(isfield(handles, 'selection'))
        error('No trace selected'); end
        % retrieve layers that are not empty
        t = handles.selection.Value(1,1);

        set(handles.functions.Statistics.input, 'String', fieldnames([traces(t).layers]))

        if handles.functions.Statistics.input.Value>length(fieldnames([traces(t).layers]))
            set(handles.functions.Statistics.input, 'Value', 1)
        end
    end
    
    guidata(gcf, handles);
   
end

function reset(varargin)

    handles = guidata(gcf);

    set(handles.functions.Statistics.input, 'Value', 1);
    set(handles.functions.Statistics.avgWidth, 'String', 5);
    set(handles.functions.Statistics.output, 'String', 'SldidingAvg');

    guidata(gcf, handles);

end

function threshold(varargin)

    handles = guidata(gcbf);
    traces = getappdata(gcbf, 'traces');
    
    input = handles.functions.Statistics.input.String{handles.functions.Statistics.input.Value};
    
    if isempty(traces); return; end;
    if not(isfield(handles, 'selection'))
        error('No trace selected'); end
    
    all = [traces.(input)];
    
    testset = all(:,1:end);
    bla = testset > 10000;   % frame intensities above background noise level
    thresholded = sum(bla,1);
    
    lower = find(thresholded < 20);
    
    for i=1:length(traces)
        traces(i).category.thresholded = false;
        traces(i).cat_descr.thresholded = 'less than 5 frames over 10000';
    end
    
    for i = 1:length(lower)
        traces(lower(i)).category.thresholded = true;    
    end
    
    uiAnalyzeTraces('updateTraceList')
    
end

function makeHistogram(varargin)

    handles = guidata(gcbf);
    traces = getappdata(gcbf, 'traces');
    
    input = handles.functions.Statistics.input.String{handles.functions.Statistics.input.Value};
    
    traces.layers
    
    layers = [traces.layers];
    intensities = [layers.(input)];
    
    figure
    histogram(intensities)
    
end

function abort(varargin)

    varargin

end