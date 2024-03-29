function SlidingAvg(figure)

    handles = guidata(figure);
    traces = getappdata(gcf, 'traces');
                    
    if not(isfield(handles.functions.SavitzkyGoley, 'panel'))
        handles.functions.SlidingAvg.panel = uipanel(...
            'Parent', gcf, ...
            'Units', 'normalized', ...
            'Position', [.32, .01, .33, .44], ...
            'Title', 'Sliding Average',...
            'Visible', 'off');
        
        % controls
        uicontrol('Parent', handles.functions.SlidingAvg.panel, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'right',...
            'Units', 'normalized', ...
            'Position', [.02 .85 .17 .1], ...
            'String', 'Input', ...
            'BusyAction', 'cancel');
        handles.functions.SlidingAvg.input = uicontrol(...
            'Parent', handles.functions.SlidingAvg.panel,...
            'Style', 'popupmenu',...
            'Units', 'normalized',...
            'Position', [.2 .85 .3 .1],...
            'String', '-',...
            'Value', 1);
        uicontrol('Parent', handles.functions.SlidingAvg.panel, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'right',...
            'Units', 'normalized', ...
            'Position', [.02 .75 .17 .1], ...
            'String', 'Average Width', ...
            'BusyAction', 'cancel');
        handles.functions.SlidingAvg.avgWidth = uicontrol(...
            'Parent', handles.functions.SlidingAvg.panel, ...
            'Style', 'Edit', ...
            'Units', 'normalized', ...
            'Position',[.2 .78 .3 .07],...
            'String', 5);
        uicontrol( 'Parent', handles.functions.SlidingAvg.panel, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'right',...
            'Units', 'normalized', ...
            'Position', [.02 .65 .17 .1], ...
            'String', 'Output', ...
            'BusyAction', 'cancel'); 
        handles.functions.SlidingAvg.output = uicontrol(...
            'Parent', handles.functions.SlidingAvg.panel, ...
            'Style', 'Edit', ...
            'Units', 'normalized', ...
            'Position',[.2 .68 .3 .07], ...
            'String', 'SlidingAvg');
        uicontrol('Parent', handles.functions.SlidingAvg.panel, ...
            'Style', 'Pushbutton', ...
            'Units', 'normalized', ...
            'Position',[.02 .01 .2 .1], ...
            'String', 'Run on selected', ...
            'Callback', {@calcSlidingAvg, 'active'});
        uicontrol('Parent', handles.functions.SlidingAvg.panel, ...
            'Style', 'Pushbutton', ...
            'Units', 'normalized', ...
            'Position',[.22 .01 .2 .1], ...
            'String', 'Run on all Traces', ...
            'Callback', {@calcSlidingAvg, 'all'});
        uicontrol('Parent', handles.functions.SlidingAvg.panel, ...
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

        set(handles.functions.SlidingAvg.input, 'String', fieldnames([traces(t).layers]))

        if handles.functions.SlidingAvg.input.Value>length(fieldnames([traces(t).layers]))
            set(handles.functions.SlidingAvg.input, 'Value', 1)
        end
    end
    
    guidata(gcf, handles);
   
end

function reset(varargin)

    handles = guidata(gcf);

    set(handles.functions.SlidingAvg.input, 'Value', 1);
    set(handles.functions.SlidingAvg.avgWidth, 'String', 5);
    set(handles.functions.SlidingAvg.output, 'String', 'SlidingAvg');

    guidata(gcf, handles);

end

function calcSlidingAvg(hObject, eventdata, range)

    handles = guidata(gcbf);
    traces = getappdata(gcbf, 'traces');
    avgWidth = str2num(handles.functions.SlidingAvg.avgWidth.String);
    input = handles.functions.SlidingAvg.input.String{handles.functions.SlidingAvg.input.Value};
    output = handles.functions.SlidingAvg.output.String;
        % check if input is valid variable name
        if not(isvarname(output))
            errordlg('Invalid output layer name. Use only letters, digits and underscores. Start with a letter.')
            return;
        end
    
    if isempty(traces); return; end;
    if not(isfield(handles, 'selection'))
        error('No trace selected'); end
    
    switch range
        case 'active'
            % selected trace index
            t = handles.selection.Value(1,1);            
            trace = traces(t).layers.(input);
            slidingTrace = utils.slidingavg(trace, avgWidth);
            traces(t).layers.(output) = slidingTrace;
        case 'all'
            h = waitbar(0,'Calculating...');
            for i=1:length(traces)
                waitbar(i/length(traces),h);
                trace = traces(i).layers.(input);
                slidingTrace = utils.slidingavg(trace, avgWidth);
                traces(i).layers.(output) = slidingTrace;
            end
            delete(h);
    end
    
    % send created layers to the layer control table of the ui
%     layers = [fieldnames([traces.layers])];
%     Data = [num2cell(true(length(layers),1)) layers];
%     set(handles.layers, 'Data', Data);
                
    setappdata(gcbf, 'traces', traces);
    
    uiAnalyzeTraces('updateTrace');
    
end

function abort(varargin)

    varargin

end