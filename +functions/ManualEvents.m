function ManualEvents(figure, varargin)

    handles = guidata(figure);
    traces = getappdata(gcf, 'traces');
    
    % External acces to internal functions of ManualEvents by calling
    % ManualEvents with additional arguments. Call ManualEvents('plot') fot
    % plotting the manual events on the trace axes. Call
    % ManualEvents('keySelect') for manually selecting the active output
    % layer for new manual events on click
    if nargin>1
    command = varargin{1};
        switch command
            case 'plot'
                ManEvPlot();
                return
            case 'keySelect'
                keySelect(varargin{2});
                return
        end
    % for adding a new manual event by clicking on the trace axes
    % ManualEvents is called. First argument is the active object, second
    % is 'click'
        if varargin{2} == 'click'
            ClickCallback(figure, varargin{1})
        end
    end
    
    if isfield(handles.functions.ManualEvents, 'panel')
        return;
    end
    
    % main panel
    handles.functions.ManualEvents.panel = uipanel(...
        'Parent', gcf, ...
        'Units', 'normalized', ...
        'Position', [.32, .01, .33, .44], ...
        'Title', 'ManualEvents',...
        'Visible', 'off');
    
%     guidata(gcf, handles);
    
    
    % 'Output' text
    uicontrol('Parent', handles.functions.ManualEvents.panel, ...
        'Style', 'text', ...
        'HorizontalAlignment', 'right',...
        'Units', 'normalized', ...
        'Position', [.02 .84 .45 .07], ...
        'String', 'Output Layer', ...
        'BusyAction', 'cancel');
    % new layer output name edit fiels
    handles.functions.ManualEvents.newLayerName = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'edit',...
        'String', 'layer1',...
        'Units', 'normalized',...
        'Position', [.5 .85 .2 .07]);
    % new layer ok button
    handles.functions.ManualEvents.okButton  = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'pushbutton',...
        'String', 'OK',...
        'Units', 'normalized',...
        'Position', [.71 .85 .1 .07],...
        'Callback',@ok);
    % layer output drowpdown menu
    handles.functions.ManualEvents.output = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'popupmenu',...
        'Units', 'normalized',...
        'Position', [.5 .85 .2 .07],...
        'Callback', @eventList,...
        'String', {},...
        'Value', 1,...
        'Visible', 'off');
    % add new layer button
    handles.functions.ManualEvents.addLayer  = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'pushbutton',...
        'String', 'new',...
        'Units', 'normalized',...
        'Position', [.71 .85 .1 .07],...
        'Callback',@addLayer,...
        'Visible', 'off');
    
    
    % delete event dropdown list
    handles.functions.ManualEvents.dropMark = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'listbox',...
        'String', {},...
        'Value', 1,...
        'Units', 'normalized',...
        'Position', [.5 .1 .3 .72]);
    
    % Toggle button for adding/deleting/moving Manual Events on trace plot
    handles.functions.ManualEvents.ManEvToggleGInput = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel, ...
        'Style', 'togglebutton',...
        'String', 'Mouse Control',...
        'Units', 'normalized',...
        'Position', [.15 .75 .32 .07],...
        'Callback', @ToggleGInputCallback);
    
    % add event location edit field
    handles.functions.ManualEvents.setMark = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'edit',...
        'String', '',...
        'Units', 'normalized',...
        'Position', [.15 .65 .1 .07]);
    % add event confirm button
    handles.functions.ManualEvents.addMark  = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'pushbutton',...
        'String', 'Add',...
        'Units', 'normalized',...
        'Position', [.26 .65 .21 .07],...
        'Callback',@AddCallback);
    % delete event confirm button
    handles.functions.ManualEvents.delMark  = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'pushbutton',...
        'String', 'Delete Selected',...
        'Units', 'normalized',...
        'Position', [.15 .55 .32 .07],...
        'Callback', @DeleteCallback);
    % delete all events
    handles.functions.ManualEvents.delAllMark  = uicontrol(...
        'Parent', handles.functions.ManualEvents.panel,...
        'Style', 'pushbutton',...
        'String', 'Delete All',...
        'Units', 'normalized',...
        'Position', [.15 .45 .32 .07],...
        'Callback', @DeleteAllCallback);
    
    guidata(figure, handles);

end

function addLayer(varargin)

    handles = guidata(gcf);
    
    set(handles.functions.ManualEvents.addLayer, 'Visible', 'off');
    set(handles.functions.ManualEvents.output, 'Visible', 'off')
    
    set(handles.functions.ManualEvents.okButton, 'Visible', 'on');
    set(handles.functions.ManualEvents.newLayerName, 'Visible', 'on');
    
    
    guidata(gcbf, handles);

end

function ok(varargin)

    handles = guidata(gcf);
    
    newLayerName = handles.functions.ManualEvents.newLayerName.String;
    
    if isempty(newLayerName)
        set(handles.functions.ManualEvents.output, 'Visible', 'on')
        set(handles.functions.ManualEvents.addLayer, 'Visible', 'on');
        set(handles.functions.ManualEvents.okButton, 'Visible', 'off');
        set(handles.functions.ManualEvents.newLayerName, 'Visible', 'off');
        return
    end
        
    layers = fieldnames(handles.layerStyle);
    currentLayerList = handles.functions.ManualEvents.output.String;
    ManEvLayers = layers(not(cellfun('isempty', strfind(layers, 'manEv_'))));
    ManEvNames = cellfun(@(x) x(7:end), ManEvLayers, 'un', 0);
    oldLayerNames = unique([currentLayerList; ManEvNames]);
    
    if not(isvarname(['manEv_' newLayerName]))
        errordlg(['Invalid output layer name. Use only letters, '...
            'digits and underscores.'])
        return;
    end
    
    if isempty(oldLayerNames)
        output = {newLayerName};
    elseif any(strcmp(oldLayerNames, newLayerName))
        output = oldLayerNames;
    else
        output = [oldLayerNames; newLayerName];
    end
    
    newIndex = find(strcmp(output,newLayerName));
        
    set(handles.functions.ManualEvents.output, 'Visible', 'on')
    set(handles.functions.ManualEvents.output, 'String', output);
    set(handles.functions.ManualEvents.output, 'Value', newIndex);
    set(handles.functions.ManualEvents.addLayer, 'Visible', 'on');
    
    set(handles.functions.ManualEvents.okButton, 'Visible', 'off');
    set(handles.functions.ManualEvents.newLayerName, 'Visible', 'off');

end

function keySelect(key)

    handles = guidata(gcf);
    
    if str2num(key) == 0
        index = 10;
    else
        index = str2num(key);
    end
    
    output = handles.functions.ManualEvents.output.String;
    
    if index <= length(output)
        set(handles.functions.ManualEvents.output, 'Value', index);
    end
    
end

function AddCallback(varargin)
  
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    t = handles.selection.Value(1,1);
    
    % Calculate time points from trace frame indices if an exposure time
    % has been set
    if isfield(handles, 'exposureTime')
        exposureTime = handles.exposureTime;
    else
        exposureTime = 1;
    end
        
    if nargin>2
        xPos = round(varargin{3},0);
    else
        xPos = round(str2double(handles.functions.ManualEvents.setMark.String)...
            / exposureTime,0);
    end
    
    output = handles.functions.ManualEvents.output.String{handles.functions.ManualEvents.output.Value};
    outputLayerName = ['manEv_' output];
    
    if not(isfield(traces(t).layers, outputLayerName))
        traces(t).layers.(outputLayerName) = zeros(length(traces(t).raw),1);
    end
    
    if not(isfield(handles.layerStyle, outputLayerName))
        handles.layerStyle.(outputLayerName).Color = [0 0 0];
        handles.layerStyle.(outputLayerName).ColorIndex = 14;
        handles.layerStyle.(outputLayerName).LineStyle = ':';
        handles.layerStyle.(outputLayerName).LineWidth = 2;
    end
    
    traces(t).layers.(outputLayerName)(xPos) = 1;
    
    setappdata(gcf, 'traces', traces);
    guidata(gcf, handles);
    
    uiAnalyzeTraces('updateTrace');
    
end

function DeleteAllCallback(varargin)
  
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    t = handles.selection.Value(1);

    output = handles.functions.ManualEvents.output.String{handles.functions.ManualEvents.output.Value};
    outputLayer = ['manEv_' output];

    traces(t).layers.(outputLayer)(:) = 0;

    childs = get(handles.trace,'Children');
    activ = findobj(childs, 'Tag', outputLayer);
    delete(activ)
        
    setappdata(gcf, 'traces', traces);
    
    eventList();

end

function DeleteCallback(varargin)
  
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    t = handles.selection.Value(1);
    
    % Calculate time points from trace frame indices if an exposure time
    % has been set
    if isfield(handles, 'exposureTime')
        exposureTime = handles.exposureTime;
    else
        exposureTime = 1;
    end
    
    if nargin>2
%         index = round(varargin{3},0);
%         Tag = get(varargin{1}, 'Tag');
%         traces(t).layers.(Tag)(index) = 0;
%         delete(varargin{1});
    else
        output = handles.functions.ManualEvents.output.String{handles.functions.ManualEvents.output.Value};
        outputLayer = ['manEv_' output];
        sel = handles.functions.ManualEvents.dropMark.Value;
        
        if strcmp('-',handles.functions.ManualEvents.dropMark.String); return; end
        
        indices = str2num(handles.functions.ManualEvents.dropMark.String);
        index = indices(sel) / exposureTime;
        
        traces(t).layers.(outputLayer)(index) = 0;
        
        childs = get(handles.trace,'Children');
        activ = findobj(childs, 'Tag',outputLayer);
        delete(findobj(activ, 'XData', [index index]))
    end
        
    setappdata(gcf, 'traces', traces);
    
    eventList();
  
end

function ToggleGInputCallback(varargin)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    if isempty(traces); return; end %TODO: throw error (no traces)
    
    if varargin{1}.Value
        set(handles.trace, 'ButtonDownFcn', {@functions.ManualEvents, 'click'});
        layers = fieldnames(handles.traceplot);
        if any(not(cellfun('isempty', strfind(layers, 'manEv_'))))
            manEvLayers = layers(not(cellfun('isempty', strfind(layers, 'manEv_'))));
            for i=1:length(manEvLayers)
                set(handles.traceplot.(manEvLayers{i}), 'ButtonDownFcn', @ButtonDown);
            end
        end
    else
        set(handles.trace, 'ButtonDownFcn', '');
        layers = fieldnames(handles.traceplot);
        if any(not(cellfun('isempty', strfind(layers, 'manEv_'))))
            manEvLayers = layers(not(cellfun('isempty', strfind(layers, 'manEv_'))));
            for i=1:length(manEvLayers)
                if not(isempty(handles.traceplot.(manEvLayers{i})))
                    set(handles.traceplot.(manEvLayers{i}), 'ButtonDownFcn', '');
                end
            end
        end
    end

end

function ClickCallback(varargin)

    % Calculate time points from trace frame indices if an exposure time
    % has been set
    handles = guidata(gcf);
    if isfield(handles, 'exposureTime')
        exposureTime = handles.exposureTime;
    else
        exposureTime = 1;
    end

    xPos = varargin{2}.IntersectionPoint(1) / exposureTime;
    hObject = varargin{1};
    fig = gcf;
    
    switch fig.SelectionType
        case 'normal'
            AddCallback(hObject, [], xPos);
%         case 'alt'
%             ManEvDeleteCallback(hObject, [], xPos);
    end

end

function ManEvPlot(varargin)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    t = handles.selection.Value(1,1);
    
    layers = fieldnames(traces(t).layers);
    manEvLayers = layers(not(cellfun('isempty', strfind(layers, 'manEv_'))));
    
    if isempty(manEvLayers)
        eventList();
        return
    end
    
    for j=1:length(manEvLayers)
    
    % don't plot manual Events when layer table checkbox is unchecked
    Data = handles.layers.Data;
    if any(ismember(Data(:,2),manEvLayers{j}))
        index = ismember(Data(:,2),manEvLayers{j});
        if Data{index,1}

        lim = [str2double(handles.xMin.fixValue.String), ...
            str2double(handles.xMax.fixValue.String),...
            str2double(handles.yMin.fixValue.String),...
            str2double(handles.yMax.fixValue.String)];
    
        % Calculate time points from trace frame indices if an exposure time
        % has been set
        if isfield(handles, 'exposureTime')
            exposureTime = handles.exposureTime;
        else
            exposureTime = 1;
        end
        
        xPos = exposureTime * find(traces(t).layers.(manEvLayers{j}));

        handles.traceplot.(manEvLayers{j}) = [];
        Color = handles.layerStyle.(manEvLayers{j}).Color;
        LineStyle = handles.layerStyle.(manEvLayers{j}).LineStyle;
        LineWidth = handles.layerStyle.(manEvLayers{j}).LineWidth;

        for i=1:length(xPos)
            handles.traceplot.(manEvLayers{j})(i) = plot(...
                [xPos(i) xPos(i)],...
                lim(3:4),...
                'Color', Color,...
                'LineWidth', LineWidth,...
                'Parent', handles.trace,...
                'LineStyle', LineStyle,...
                'Tag', [manEvLayers{j}],...
                'ButtonDownFcn', '');
        end
        end
    end

    if handles.functions.ManualEvents.ManEvToggleGInput.Value == 1
        set(handles.traceplot.(manEvLayers{j}), 'ButtonDownFcn', @ButtonDown);
    end
    
    end
    
    eventList();
        
    guidata(gcf, handles);
    
end

function eventList(varargin)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    t = handles.selection.Value(1,1);
    
    % Calculate time points from trace frame indices if an exposure time
    % has been set
    if isfield(handles, 'exposureTime')
        exposureTime = handles.exposureTime;
    else
        exposureTime = 1;
    end
    
    layers_all = fieldnames(handles.layerStyle);
    manEvLayers_all = layers_all(not(cellfun('isempty', strfind(layers_all, 'manEv_'))));
    
    if isempty(manEvLayers_all)
        set(handles.functions.ManualEvents.dropMark, 'String', {});
        return
    end
      
    output = handles.functions.ManualEvents.output.String{handles.functions.ManualEvents.output.Value};
    outputLayer = ['manEv_' output];
    if not(isfield(traces(t).layers, outputLayer))
        set(handles.functions.ManualEvents.dropMark, 'String', {});
        return
    end
    
    events = exposureTime * find(traces(t).layers.(outputLayer));
    if not(isempty(events))
        set(handles.functions.ManualEvents.dropMark, 'String', events, 'Value', 1);
    else
        set(handles.functions.ManualEvents.dropMark, 'String', {});
    end

end

function ButtonDown(varargin)

    fig = gcf;
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    traceName = handles.traces.Data(handles.selection.Value(1,1),1);
    t = find(strcmp({traces.name}, traceName));
    
    % Calculate time points from trace frame indices if an exposure time
    % has been set
    if isfield(handles, 'exposureTime')
        exposureTime = handles.exposureTime;
    else
        exposureTime = 1;
    end
    
    oldXPos = round(varargin{1}.XData(1) / exposureTime,0);
    handles.functions.ManualEvents.manualEventOldXPos = oldXPos;
    handles.functions.ManualEvents.ButtonDownEvent = varargin{1};
    
    guidata(gcf, handles);
    
    if strcmp(fig.SelectionType, 'alt')
        t = handles.selection.Value(1);
        layer = handles.functions.ManualEvents.ButtonDownEvent.Tag;
        traces(t).layers.(layer)(oldXPos) = 0;
        delete(handles.functions.ManualEvents.ButtonDownEvent);
        eventList();
        return
    end
    
    set(fig,'WindowButtonMotionFcn',@ButtonMotion)
    set(fig,'WindowButtonUpFcn',@ButtonUp)
      
end

function ButtonUp(varargin)

    fig = gcf;
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    t = handles.selection.Value(1,1);
    
    % Calculate time points from trace frame indices if an exposure time
    % has been set
    if isfield(handles, 'exposureTime')
        exposureTime = handles.exposureTime;
    else
        exposureTime = 1;
    end

    curP = get(handles.trace,'CurrentPoint');
    xPos = round(curP(1,1) / exposureTime,0);
        
    % Update cursor position
    set(handles.functions.ManualEvents.ButtonDownEvent,...
        'XData', exposureTime * [xPos xPos]);
    
    set(fig,'WindowButtonMotionFcn','');
    set(fig,'WindowButtonUpFcn','');
    
    layer = handles.functions.ManualEvents.ButtonDownEvent.Tag;
    oldxPos = handles.functions.ManualEvents.manualEventOldXPos;
    traces(t).layers.(layer)(oldxPos) = 0;
    traces(t).layers.(layer)(xPos) = 1;
    
    eventList();

end

function ButtonMotion(varargin)

    fig = gcf;
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    t = handles.selection.Value(1);
    
    lim = [str2double(handles.xMin.fixValue.String), ...
        str2double(handles.xMax.fixValue.String),...
        str2double(handles.yMin.fixValue.String),...
        str2double(handles.yMax.fixValue.String)];
    
    % Get current point
    curP = get(handles.trace,'CurrentPoint');
    
    % Update cursor position
    set(handles.functions.ManualEvents.ButtonDownEvent,...
        'XData',[curP(1,1) curP(1,1)]);
    
    set(fig,'WindowButtonUpFcn',@ButtonUp)
    
end

function AndiExport(varargin)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    
    markers = cell(length(traces),1);
    for i=1:length(traces)
        if isfield(traces(i).layers, 'manualEvent')
            markers{i} = traces(i).layers.manualEvent;
        else
            markers{i} = zeros(length(traces(i).raw),1);
        end
    end
    
    markerpositions = cellfun(@find, markers, 'UniformOutput', false);
    
    % if there are odd numbers of markers a list is given with the trace
    % names
    markernumbers = cellfun(@length, markerpositions);
    markeroddity = mod(markernumbers,2);
    help = logical(markeroddity);
    oddTraces = {traces(help).name};
    
    if not(isempty(oddTraces));
        errorfig = figure(...
        'Position', [0, 0, 200, 400], ...
        'Name', 'Odd number of markers', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Visible', 'on');
        movegui(errorfig, 'center');
        uicontrol('Parent', errorfig,...
            'Position', [5 335 190 60],...
            'Style', 'Text',...
            'String', ['There are traces with odd numbers of markers.' ...
            'These traces were excluded for the export.' ...
            'Review these traces, remove or add a marker and rerun.']);
        uitable('Parent', errorfig,...
            'Position', [5 5 190 330],...
            'RowName', [], 'ColumnName', [],...
            'ColumnWidth', {188},...
            'Data', oddTraces');
    end
    
    % calculate the periods between the markers for every trace. traces
    % with odd numbers of markers are omitted
    periods = cellfun(@calculateDifference, markerpositions, 'UniformOutput', false);
    
    % put all periods to a vector for the histogram
    allPeriods = cell2mat(periods);
    
    % create new figure with the histogram
%     figure
%     [h, bins] = hist(allPeriods,1)
    [N, edges] = histcounts(allPeriods, 'BinWidth', 1);
    histo = [edges(2:end); N]';
    
    [FileName,PathName,FilterIndex] = uiputfile('*.csv',...
        'save histogram to csv-file');
    if not(eq(PathName,0))
        csvwrite(fullfile(PathName,FileName),histo);
    end
    
    function periods = calculateDifference(markerpositions)
        
        if not(mod(length(markerpositions),2))
            % calculate difference between adjacent marker positions
            difference = diff(markerpositions);
            % select differecens with odd indices
            periods = difference(1:2:length(difference));
        else
            periods = [];
        end
        
    end

end