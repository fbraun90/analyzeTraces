%% Main Figure // User Interface
function uiAnalyzeTraces(varargin)

    if nargin>0
        switch varargin{1}
            case 'updateTrace'
                updateTrace();
                return
            case 'updateTraceList'
                updateTraceList();
                return
        end
    end

    % create and open the main trace analysis ui
    fig = figure( ...
        'Units', 'normalized', ...
        'Position', [0, .05, 1, .87], ...
        'Name', 'Trace Analysis alpha', ...
        'MenuBar', 'none', ...
        'Toolbar', 'figure', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'WindowKeyPressFcn', @KeyControl,...
        'WindowKeyReleaseFcn', @KeyRelease,...
        'Resize', 'on', ...
        'Tag', 'mainfig',...
        'Visible', 'off');
    
    % save all gui object handles as guidata so they can be accessed later
    handles = guidata(fig);
    
    % Main menu toolbar
    handles.menu.file = uimenu('Label','File');
    uimenu( ...
        'Parent', handles.menu.file, ...
        'Label','Open', ...
        'Callback',@openTracesCallback);
    uimenu( ...
        'Parent', handles.menu.file, ...
        'Label','Save', ...
        'Callback',@saveTracesCallback);
    uimenu( ...
        'Parent', handles.menu.file, ...
        'Label','Import csv', ...
        'Callback',@importTracesCallback);
    uimenu( ...
        'Parent', handles.menu.file, ...
        'Label','Export', ...
        'Callback',@exportCallback, ...
        'Enable', 'off');
    
    
    
    handles.menu.options = uimenu('Label','Options');
    handles.menu.keyboard = uimenu('Parent', handles.menu.options,...
        'Label', 'Keyboard',...
        'Separator', 'off');
    handles.keyControl = 'Disable';
    handles.keyDisable = uimenu('Parent', handles.menu.keyboard,...
        'Label', 'Disabled',...
        'Checked', 'on',...
        'Callback', {@KeyToggle, 'Disable'});
    handles.keyCategorization = uimenu('Parent', handles.menu.keyboard,...
        'Label', 'Categorization',...
        'Separator', 'on',...
        'Checked', 'off',...
        'Callback', {@KeyToggle, 'Categorization'});
    handles.keyManEvLayers = uimenu('Parent', handles.menu.keyboard,...
        'Label', 'Manual Events',...
        'Checked', 'off',...
        'Callback', {@KeyToggle, 'ManualEvents'});
    
    handles.menu.categories = uimenu('Label','Categories');
    uimenu('Parent', handles.menu.categories,...
        'Label', 'Create Category',...
        'Callback', @createCategory);
    uimenu('Parent', handles.menu.categories,...
        'Label', 'Delete Category...',...
        'Callback', @deleteCategory);
    uimenu('Parent', handles.menu.categories,...
        'Label', 'Rename Category...',...
        'Callback', @renameCategoryDialog);
    
    handles.menu.traces = uimenu('Label','Traces');
    uimenu('Parent', handles.menu.traces,...
        'Label', 'Delete current traces',...
        'Callback', @createCategory,...
        'Enable', 'off');
    uimenu('Parent', handles.menu.traces,...
        'Label', 'Delete traces...',...
        'Callback', @deleteTraces);
    uimenu('Parent', handles.menu.traces,...
        'Label', 'Set Layer Style...',...
        'Callback', @utils.layerStylePopup);
    uimenu('Parent', handles.menu.traces,...
        'Label', 'Set Exposure Time...',...
        'Callback', @utils.setExposureTime);
        
    % slice the display up into separate panels to organize the controls
    panelPlot = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .62, .3, .37], ...
        'Title', 'Plot');
    panelTraces = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .3, .60], ...
        'Title', 'Traces');
    panelTrace = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.32, .51, .67, .48], ...
        'Title', 'Trace');
    panelInfo = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.66, .01, .33, .49], ...
        'Title', 'Info');
   
    % Controls for the trace plot
    % Checkboxes for the display of the trace layers
    handles.layers = uitable(...
        'Parent', panelPlot, ...
        'Units', 'normalized', ...
        'Position', [.02, .02, .46, .96], ...
        'CellEditCallback', @selectLayerCallback, ...
        'ColumnFormat', {'logical' 'char' 'char'},...
        'ColumnEditable', [true false false],...
        'ColumnWidth', {15 150 25}, ...
        'ColumnName', [], ...
        'RowName', [],...
        'Data', '');
    
    % Controls for the limits of the trace plot
    handles.xMin.Type = uibuttongroup( ...
        'Parent', panelPlot, ...
        'Visible', 'off', ...
        'Units', 'normalized', ...
        'Position', [.52 .75 .47 .25], ...
        'Title', 'x Min', ...
        'SelectionChangedFcn', @updateTrace);
    uicontrol(handles.xMin.Type, ...
        'Style', 'radiobutton',...
        'String', 'Trace',...
        'Units', 'normalized', ...
        'Position',[0 .5 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.xMin.Type, ...
        'Style', 'radiobutton',...
        'String', 'Global',...
        'Units', 'normalized', ...
        'Position',[0 0 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.xMin.Type, ...
        'Style', 'radiobutton',...
        'String', 'Fixed',...
        'Units', 'normalized', ...
        'Position',[.5 .5 .5 .5],...
        'HandleVisibility','off');
    handles.xMin.fixValue = uicontrol(handles.xMin.Type, ...
        'Style', 'Edit', ...
        'Units', 'normalized', ...
        'Position',[.5 0.05 .4 .4], ...
        'String', '', ...
        'Callback', @updateTrace, ...
        'Enable', 'off');
    handles.xMin.Type.Visible = 'on';
    
    handles.xMax.Type = uibuttongroup( ...
        'Parent', panelPlot, ...
        'Visible', 'off', ...
        'Units', 'normalized', ...
        'Position', [.52 .5 .47 .25], ...
        'Title', 'xMax', ...
        'SelectionChangedFcn', @updateTrace);
    uicontrol(handles.xMax.Type, ...
        'Style', 'radiobutton',...
        'String', 'Trace',...
        'Units', 'normalized', ...
        'Position',[0 .5 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.xMax.Type, ...
        'Style', 'radiobutton',...
        'String', 'Global',...
        'Units', 'normalized', ...
        'Position',[0 0 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.xMax.Type, ...
        'Style', 'radiobutton',...
        'String', 'Fixed',...
        'Units', 'normalized', ...
        'Position',[.5 .5 .5 .5],...
        'HandleVisibility','off');
    handles.xMax.fixValue = uicontrol(handles.xMax.Type, ...
        'Style', 'Edit', ...
        'Units', 'normalized', ...
        'Position',[.5 0.05 .4 .4], ...
        'String', '', ...
        'Callback', @updateTrace, ...
        'Enable', 'off');
    handles.xMax.Type.Visible = 'on';
    
    handles.yMin.Type = uibuttongroup( ...
        'Parent', panelPlot, ...
        'Visible', 'off', ...
        'Units', 'normalized', ...
        'Position', [.52 .25 .47 .25], ...
        'Title', 'y Min', ...
        'SelectionChangedFcn', @updateTrace);
    uicontrol(handles.yMin.Type, ...
        'Style', 'radiobutton',...
        'String', 'Trace',...
        'Units', 'normalized', ...
        'Position',[0 .5 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.yMin.Type, ...
        'Style', 'radiobutton',...
        'String', 'Global',...
        'Units', 'normalized', ...
        'Position',[0 0 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.yMin.Type, ...
        'Style', 'radiobutton',...
        'String', 'Fixed',...
        'Units', 'normalized', ...
        'Position',[.5 .5 .5 .5],...
        'HandleVisibility','off');
    handles.yMin.fixValue = uicontrol(handles.yMin.Type, ...
        'Style', 'Edit', ...
        'Units', 'normalized', ...
        'Position',[.5 0.05 .4 .4], ...
        'String', '', ...
        'Callback', @updateTrace, ...
        'Enable', 'off');
    handles.yMin.Type.Visible = 'on';
    
    handles.yMax.Type = uibuttongroup( ...
        'Parent', panelPlot, ...
        'Visible', 'off', ...
        'Units', 'normalized', ...
        'Position', [.52 .01 .47 .24], ...
        'Title', 'y Max', ...
        'SelectionChangedFcn', @updateTrace);
    uicontrol(handles.yMax.Type, ...
        'Style', 'radiobutton',...
        'String', 'Trace',...
        'Units', 'normalized', ...
        'Position',[0 .5 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.yMax.Type, ...
        'Style', 'radiobutton',...
        'String', 'Global',...
        'Units', 'normalized', ...
        'Position',[0 0 .5 .5],...
        'HandleVisibility','off');
    uicontrol(handles.yMax.Type, ...
        'Style', 'radiobutton',...
        'String', 'Fixed',...
        'Units', 'normalized', ...
        'Position',[.5 .5 .5 .5],...
        'HandleVisibility','off');
    handles.yMax.fixValue = uicontrol(handles.yMax.Type, ...
        'Style', 'Edit', ...
        'Units', 'normalized', ...
        'Position',[.5 0.05 .4 .4], ...
        'String', '', ...
        'Callback', @updateTrace, ...
        'Enable', 'off');
    handles.yMax.Type.Visible = 'on';
    
    % traces panel: list of available traces
        
    uicontrol(panelTraces, 'Style', 'text', 'String', 'show',...
        'HorizontalAlignment', 'right', 'Units', 'normalized',...
        'Position', [.04 .94 .10 .05 ]);        
    handles.traceListFilter = uicontrol(...
        'Parent', panelTraces,...
        'Units', 'normalized',...
        'Position', [.15 .93 .35 .06 ],...
        'Style', 'popupmenu',...
        'String', 'all',...
        'Value', 1,...
        'Enable', 'off');
    handles.TraceListNumber = uicontrol(...
        'Parent', panelTraces,...
        'Style', 'text',...
        'HorizontalAlignment', 'left',...
        'String', 'Showing 0 traces',...
        'Units', 'normalized',...
        'Position', [.54 .94 .42 .05]);
    handles.traces = uitable(...
        'Parent', panelTraces, ...
        'Units','normalized',...
        'Position', [.04, .02, .92, .90], ...
        'CellSelectionCallback', @selectTraceCallback, ...
        'CellEditCallback', @checkTraceCategoryCallback, ...
        'ColumnFormat', {} ,...
        'ColumnEditable', false,...
        'ColumnWidth', {200}, ...
        'ColumnName', [], ...
        'RowName', [], ...
        'Data', '' );
    
    % trace panel: plot of the selected trace
    
    handles.trace = axes( ...
        'Parent', panelTrace, ...
        'Units', 'normalized', ...
        'OuterPosition', [0.05, .02, 0.95, 0.96], ...
        'Position', [.05, .10, .93, .85],...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren',...
        'YGrid', 'on',...
        'XGrid', 'on',...
        'GridAlpha', 0.3);
    handles.trace.XLabel.String = 'Frame';
    handles.trace.XLabel.HorizontalAlignment = 'right';
    handles.trace.XLabel.Units = 'normalized';
    handles.trace.XLabel.Position = [1 -0.05];
    handles.trace.YLabel.String = 'Intensity';

    % function panel
    
    handles.activeFunction = uicontrol(...
        'Parent', fig, ...
        'Style','popupmenu',...
        'Units', 'normalized', ...
        'String','',...
        'Position', [.32, .45, .33, .04],...
        'Value',1,...
        'Callback', @updateFunction);
    
    % Info panel
    handles.tracename = uicontrol(...
        'Parent', panelInfo, ...
        'Style', 'Text',...
        'HorizontalAlignment', 'right',...
        'Units', 'normalized', ...
        'Position', [.02, .85, .17, .1], ...
        'String', 'Selected trace:');
    handles.tracename = uicontrol(...
        'Parent', panelInfo, ...
        'Style', 'Text',...
        'HorizontalAlignment', 'left',...
        'FontWeight', 'bold',...
        'Units', 'normalized', ...
        'Position', [.2, .85, .78, .1], ...
        'String', '');
    
    handles.overview = axes(...
        'Parent', panelInfo, ...
        'Units', 'normalized', ...
        'Position', [0.1, 0.05, 0.8, 0.8]);        
    
%     handles.testpush = uicontrol(...
%         'Parent', panelInfo,...
%         'Style', 'pushbutton',...
%         'String', 'test',...
%         'Units', 'normalized',...
%         'Position', [.85 .05 .1 .1],...
%         'Callback', @testpush);
        

    % setting visibility to "on" only now speeds up the window creation
    set(fig, 'Visible', 'on');
    
    % Toolbar using standard toolbar and deleting all buttons except the
    % ones listed in keep
    set(zoom, 'ActionPostCallback', @updateLimits, 'Motion', 'horizontal');
    set(pan, 'ActionPostCallback', @updateLimits, 'Motion', 'horizontal');
    tbh = findall(fig,'Type','uitoolbar');
    ih = findall(tbh);
    
    keep = {'FigureToolBar';...
        'Exploration.Pan';...
        'Exploration.ZoomOut';...
        'Exploration.ZoomIn'};
    
    delete(ih(not(ismember(get(ih, 'Tag'), keep))))
    
    guidata(gcf, handles);
    
    % run through the functions to create the function dropdown list
    createFunction(handles.activeFunction, []);

end

%% Development Tools
function testpush(varargin)
    
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces'); %#ok<*NASGU>
    
end

%% Keyboard control
function KeyToggle(hObject, eventdata, keyboardFunction)

    handles = guidata(gcf);
    
    switch keyboardFunction
        case 'Disable'
            set(handles.keyCategorization, 'Checked', 'off');
            set(handles.keyManEvLayers, 'Checked','off');
            set(handles.keyDisable, 'Checked','on');
        case 'Categorization'
            set(handles.keyCategorization, 'Checked', 'on');
            set(handles.keyManEvLayers, 'Checked','off');
            set(handles.keyDisable, 'Checked','off');
        case 'ManualEvents'
            set(handles.keyCategorization, 'Checked', 'off');
            set(handles.keyManEvLayers, 'Checked','on');
            set(handles.keyDisable, 'Checked','off');
    end
    
    handles.keyControl = keyboardFunction;
    guidata(gcf, handles);
    

end

%% Keyboard control

function KeyControl(hObject, eventdata)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces'); 
    Character = eventdata.Character;
    Source = eventdata.Source;
    Key = eventdata.Key;
    Modifier = eventdata.Modifier;        
%     strcmp(Modifier,'control')
%     not(isempty(Modifier))

    switch Character
        % select next trace by pressing 'ctrl' and '<'
        case '<' % {'n', 'N'}
            if not(isempty(traces)) && not(isempty(Modifier)) && strcmp(Modifier,'control')
                selectNextTrace();
            end
        % select previous trace by pressing 'ctrl' and 'shift' and '<'
        case '>' % {'b', 'B'}
            if not(isempty(traces)) && not(isempty(Modifier)) && all(ismember({'control' 'shift'},Modifier))
                selectPreviousTrace();
            end
        % pressing numbers initiates key categorisation
        case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
            % if key categorisation is activated in menu traces are
            % assigned to categories by their number
            switch handles.keyControl
                case 'Categorization'
                if strcmp(handles.keyCategorization.Checked, 'on')
                    if strcmp(Character,'0')
                        keyCategorize('10')
                    else
                        keyCategorize(Character);
                    end
                end
                case 'ManualEvents'
                    functions.ManualEvents(gcf, 'keySelect',Character)
            end
    end

end

function KeyRelease(varargin)

    uiresume

end

function selectNextTrace(varargin)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
        
    if not(isfield(handles, 'jtable'))
        handles.jtable = utils.findjobj(handles.traces);
        guidata(gcf, handles)
    end
    
    jtable = handles.jtable.getViewport.getComponent(0);
    row = handles.selection.Value(1,1);
    if row == size(handles.traces.Data,1); return; end
    jtable.changeSelection(row,0,false,false)  % Java indices start at 0
        
%     if isfield(handles, 'selection') && isfield(handles.selection, 'Value')...
%             && not(isempty(handles.selection.Value))
%         t = handles.selection.Value(1,1); 
%     else
%         handles.selection.Value = 0;
%         t = handles.selection.Value;
%     end
%         
%     if t==size(handles.traces.Data,1); return; end
%     handles.selection.Value = [t+1 1];
%     guidata(gcf, handles);
%     updateTrace();

end

function selectPreviousTrace(varargin)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    
    if not(isfield(handles, 'jtable'))
        handles.jtable = utils.findjobj(handles.traces);
        guidata(gcf, handles)
    end
    
    jtable = handles.jtable.getViewport.getComponent(0);
    row = handles.selection.Value(1,1);  
    if row == 1; return; end
    col = jtable.getSelectedColumn ;
    jtable.changeSelection(row-2,0,false,false); % Java indexes start at 0
    
%     if isfield(handles, 'selection') && isfield(handles.selection, 'Value')...
%             && not(isempty(handles.selection.Value))
%         t = handles.selection.Value(1,1); 
%     else
%         handles.selection.Value = 0;
%         t = handles.selection.Value;
%     end
%     
%     if t==1; return; end
%     handles.selection.Value = [t-1 1];
%     guidata(gcf, handles);
%     updateTrace();

end

function keyCategorize(key)

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    
    if strcmp(handles.keyCategorization.Checked, 'off')
        return;
    end
        
    % find trace from trace name in traces list at selection index
    traceName = handles.traces.Data(handles.selection.Value(1,1),1);
    t = find(strcmp({traces.name}, traceName));
    
    cats = fieldnames(traces(t).category);
    
    jscroll = utils.findjobj(handles.traces);
    jtable = jscroll.getViewport.getComponent(0);
    row = handles.selection.Value(1,1);
    
    if str2num(key) > length(cats); return; end
    catIndex = str2num(key);
    catName = cats{catIndex};
    
    oldVal = traces(t).category.(catName);
    traces(t).category.(catName) = not(oldVal);
    
    if oldVal
        string = 'false';
    else
        string = 'true';
    end
    
%     set(handles.traces, 'CellEditCallback', '');
    jtable.setValueAt(string,row-1,str2num(key));
%     set(handles.traces, 'CellEditCallback', @checkTraceCategoryCallback)
    
%     t = handles.selection.Value(1,1);
%         
%     cats = fieldnames(traces(t).category);
%     if str2num(key) > length(cats); return; end
%     catIndex = str2num(key);
%     catName = cats{catIndex};
%     
%     traces(t).category.(catName) = not(traces(t).category.(catName));
%     updateTraceList();

end

%% Categorisation
function createCategory(varargin)

    handles = guidata(gcf);
    traces = getappdata(gcbf, 'traces');
    if isempty(traces)
        errordlg('No traces, no categories!');
        return;
    end

    % open dialog to enter the name and description of the new category
    prompt = {'Enter category name:', 'Enter category description'};
    dlg_title = 'New Category';
    num_lines = 1;
    defaultans = {'',''};  % TODO: suggest nonexisting category
    
    answer = inputdlg(prompt, dlg_title, num_lines,defaultans);
    % abort if dialog is closed or cancel button is pressed
    if isempty(answer); return; end
    
    newcatName = answer{1};
    
    % check if category name already exists
    if any(ismember(fieldnames([traces.category]),newcatName))
        errordlg('Category with that name already exists');
        return;
    end
    
    % check if input is valid variable name
    if not(isvarname(newcatName))
        errordlg('Invalid category name. Use only letters, digits and underscores. Start with a letter.')
        return;
    end
        
    newcatDescr = answer{2};

    % create field in category property with category name and assign false
    % to every trace, create field with fieldname of category name and
    % assign description string to every trace
    for t=1:length(traces)
        traces(t).cat_descr.(newcatName) = newcatDescr;
        traces(t).category.(newcatName) = false;
    end
    
    % save new category to the traces object
    setappdata(gcbf, 'traces', traces);
    
    % Update Filter dropdown and set to "all"
    set(handles.traceListFilter, 'String', ['all'; fieldnames([traces.cat_descr])],...
            'Value', 1);
    updateTraceList();
    
end

function deleteCategory(varargin)

    handles = guidata(gcbf);
    traces = getappdata(gcbf, 'traces');
    mainfig = gcbf;
    
    
    if isempty(traces); errordlg('No traces, no categories!'); return; end
    if isempty(fieldnames([traces.category]))
        errordlg('There are no categories');
        return;
    end

    handles.delCat = figure(...
        'Position', [0, 0, 450, 350], ...
        'Name', 'Delete Category...', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Visible', 'on');
    movegui(handles.delCat, 'center');
    
    cat_descr = [traces.cat_descr];
    
    nums = num2cell([1:9 0])';
    if length(fieldnames(cat_descr))>10
        hotkey = cell(length(fieldnames(cat_descr)),1);
        [hotkey{:}] = deal('-');
        hotkey(1:10) = nums(1:10);
    else
        hotkey = nums(1:length(fieldnames(cat_descr)));
    end
   
    Data = [num2cell(false(length(fieldnames(cat_descr)),1)) ...
        hotkey...
        fieldnames(cat_descr) struct2cell(cat_descr(1))];
    
    handles.CatTable = uitable(...
        'Parent', handles.delCat, ...
        'Units','normalized',...
        'Position', [.05, .15, .9, .8], ...
        'CellSelectionCallback', '', ...
        'CellEditCallback', '', ...
        'ColumnFormat', {'logical' 'char' 'char' 'char'} ,...
        'ColumnEditable', [true false false false],...
        'ColumnWidth', {45 45 80 220}, ...
        'ColumnName', {'Delete?' 'Hotkey' 'Name' 'Description'}, ...
        'RowName', [], ...
        'Data', Data );
    uicontrol('Parent', handles.delCat, ...
        'Units','normalized',...
        'Position', [.05, .05, .3, .1], ...
        'Style', 'pushbutton',...
        'String', 'Delete Selected',...
        'Callback', {@deleteSelectedCategory, [handles.CatTable.Data{:,1}]});
    uicontrol('Parent', handles.delCat, ...
        'Units','normalized',...
        'Position', [.35, .05, .3, .1], ...
        'Style', 'pushbutton',...
        'String', 'Delete All',...
        'Callback', {@deleteSelectedCategory, 'all'})
    uicontrol('Parent', handles.delCat, ...
        'Units','normalized',...
        'Position', [.65, .05, .3, .1], ...
        'Style', 'pushbutton',...
        'String', 'Cancel',...
        'Callback', @close);
    
    function close(varargin)
        delete(handles.delCat)
    end

    function deleteSelectedCategory(varargin)
        
        button = questdlg(['Are you sure about deleting selected categories?'...
            'This will remove the category and all trace assignements.'...
            'It cannot be undone']);        
        if not(strcmp(button, 'Yes'))
            return;
        end
        
        if strcmp(varargin{3}, 'all')
            index = true(length(fieldnames(cat_descr)),1);
        else
            index = [handles.CatTable.Data{:,1}];
        end
        delCat = handles.CatTable.Data(index,3);
        for i=1:length(traces)
            traces(i).category = rmfield(traces(i).category, delCat);
            traces(i).cat_descr = rmfield(traces(i).cat_descr, delCat);
        end
        
        setappdata(mainfig, 'traces', traces);
        delete(gcf);
        set(handles.traceListFilter, 'String', ['all'; fieldnames(cat_descr)],...
            'Value', 1);
        updateTraceList();
    end
    
end

function renameCategoryDialog(varargin)

    handles = guidata(gcbf);
    traces = getappdata(gcbf, 'traces');
    mainfig = gcbf;
    
    if isempty(traces); errordlg('No traces, no categories!'); return; end
    if isempty(fieldnames([traces.category]))
        errordlg('There are no categories'); return; end
    
    renameCatFig = figure(...
        'Position', [0, 0, 200, 110], ...
        'Name', 'Rename Category...', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Visible', 'on');
    movegui(renameCatFig, 'center');
    
    uicontrol(renameCatFig, 'Style', 'text', 'String', 'Old Name',...
        'Position', [5 75 60 25]);
    catIndex = uicontrol(renameCatFig, 'Style', 'popupmenu', 'String', fieldnames([traces.category]),...
        'Position', [70 80 125 25]);
    uicontrol(renameCatFig, 'Style', 'text', 'String', 'New Name',...
        'Position', [5 40 60 25]);
    newCatName = uicontrol(renameCatFig, 'Style', 'edit', 'String', '',...
        'Position', [70 45 125 25]);
    uicontrol(renameCatFig, 'Style', 'pushbutton', 'String', 'Rename',...
        'Position', [5 5 190 30],...
        'Callback', {@fixAndRename, mainfig, catIndex.Value, newCatName.String});
    
    function fixAndRename(hObject, actiondata, mainfig, catIndex, f2)

        uicontrol(newCatName)  %Set it back
        
        renameCategory(hObject, actiondata, mainfig, catIndex, newCatName.String)
        
        delete(renameCatFig);
        updateTraceList();
    end

end

function renameCategory(hObject, actiondata, mainfig, catIndex, newCatName)

    handles = guidata(mainfig);
    traces = getappdata(mainfig, 'traces');
    
    catNames = fieldnames([traces.category]);
    
    f1 = catNames{catIndex};
    f2 = newCatName;
    
    for i=1:length(traces)
        traces(i).category = utils.rnfield(traces(i).category, f1, f2);
        traces(i).cat_descr = utils.rnfield(traces(i).cat_descr, f1, f2);
    end
    
    setappdata(gcf, 'traces', traces);

end

function checkTraceCategoryCallback(hObject, callbackdata)
    
    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    
    % Store selected trace index to handles.selection
    handles.selection = struct('Value', callbackdata.Indices);
    
    % find trace from trace name in traces list at selection index
    traceName = handles.traces.Data(handles.selection.Value(1,1),1);
    t = find(strcmp({traces.name}, traceName));
        
    catIndex = callbackdata.Indices(2);
    catName = handles.traces.ColumnName{catIndex};
    
    traces(t).category.(catName) = callbackdata.NewData;
    
end

function toggleKeyCategorization(varargin)

    handles = guidata(gcf);
    
    onoff = {'on' 'off'};
    
    set(handles.keyCategorization, 'Checked',...
        onoff{not(strcmp(onoff, handles.keyCategorization.Checked))});

end

%% Trace Selection and Trace Plot
function updateTraceList(varargin)

    traces = getappdata(gcf, 'traces');
    handles = guidata(gcf);
    
    if isempty(traces)
        set(handles.traces, 'Data', []);
        set(handles.traces, 'ColumnName', []);
        return;
    end
    
    if isempty(fieldnames([traces.category]))
        Data = {traces.name}';
        ColumnName = {'Trace name'};
        ColumnWidth = {150};
        ColumnEditable = false;
        ColumnFormat = {'char'};
    else
        catName = fieldnames([traces.category]);
        catNum = length(catName);

        ColumnName = ['Trace name'; catName];

        cat = cell(length(traces),catNum);
        for i=1:length(catName)
            for j=1:length(traces)
                if not(isfield(traces(j).category, catName{i})) ||...
                        isempty(traces(j).category.(catName{i}))
                    cat(j,i) = 0;
                else
                    cat{j,i} = traces(j).category.(catName{i});
                end
            end
        end

        Data = [{traces.name}' cat];

        ColumnWidth = zeros(1,catNum + 1);
        ColumnWidth(:) = 35;
        ColumnWidth(1) = 150;
        ColumnWidth = num2cell(ColumnWidth);

        ColumnEditable = true(1,catNum + 1);
            ColumnEditable(1) = false;
        ColumnFormat = num2cell(zeros(1,catNum + 1));
            [ColumnFormat{:}] = deal('logical');
            ColumnFormat{1} = 'char';
    end
    
    if nargin > 1
       index = varargin{2};
       Data = Data(index,:);
    end

    set(handles.traces, 'Data', Data);
    set(handles.traces, 'ColumnName', ColumnName);
    set(handles.traces, 'ColumnWidth', ColumnWidth);
    set(handles.traces, 'ColumnEditable', ColumnEditable);
    set(handles.traces, 'ColumnFormat',  ColumnFormat);
    
    if not(isempty(fieldnames([traces.category])))
        set(handles.traceListFilter, 'Enable', 'on',...
            'String', ['all'; catName], 'Callback', @TraceListFilter)
    else
        set(handles.traceListFilter, 'Enable', 'off',...
            'String', 'all', 'Callback', '')
    end
    
end

function TraceListFilter(hObject, actiondata)
% Callback that is called when dropdown menu for filtering the trace list
% by categories is used

    handles = guidata(gcf);
    traces = getappdata(gcf, 'traces');
    
    if handles.traceListFilter.Value == 1
        index = true(length(traces),1);
    else
        catIndex = handles.traceListFilter.Value - 1;
        catName = fieldnames([traces.category]);
        ShowCat = catName{catIndex};

        index = false(length(traces),1);
        for i=1:length(traces)
           index(i) = traces(i).category.(ShowCat);
        end
    end
    
    filterTraces = traces(index);
    
    num = num2str(length(filterTraces));
    
    set(handles.TraceListNumber, 'String', ['Showing ' num ' traces'])
    
    updateTraceList(hObject, index);
    
    
end

function updateLayers(varargin)
% Updates the trace layer table in the plot panel
% When layers table is created the first time all checkboxes are set to
% true (=all layers will be displayed in the trace plot).
% Status of the checkboxes is stored in handles.layerSelection

    handles = guidata(gcf);
    
    % find layers of selected trace
    traces = getappdata(gcf, 'traces');
    if isempty(handles.selection.Value); return; end;
    t = handles.selection.Value(1,1);
    traceLayerFields = fieldnames(traces(t).layers);
    notemptyindex = not(structfun(@isempty,traces(t).layers));
    traceLayers = traceLayerFields(notemptyindex);
    
    % Checkbox column for selecting display of layers
    check = num2cell(true(length(traceLayers),1));
        
    % Column displaying the color of the layer in the trace plot stored in
    % handles.layerStyle
    color = cell(length(check),1);
    layer_color = cell(length(check),1);
        for i=1:length(check)
            layer_color{i} = handles.layerStyle.(traceLayers{i}).Color;
            clr = ['rgb(' num2str(round(layer_color{i}*255)) ')'];
            color{i,1} = ['<html><body bgcolor="' clr ...
                'width="100px"''><font color="' clr ...
                '">spacer</font></body></html>'];
        end
        
    % Layer names of all layers of all traces
    allLayers = fieldnames(handles.layerStyle);
    
    % create handles.layerSelection and set layer display to true for all
    % layers of all traces
    if isempty(handles.layers.Data)
        handles.layerSelection = struct();
        for i=1:length(allLayers)
            handles.layerSelection.(allLayers{i}) = true;
        end
    end
    
    % Set layer display to true for new layers
    if isfield(handles, 'layerSelection')
        layerSelection = fieldnames(handles.layerSelection);
    else
        layerSelection = {};
    end
    newLayers = ismember(traceLayers,layerSelection);
    for i=1:length(traceLayers)
        if not(newLayers(i))
            handles.layerSelection.(traceLayers{i}) = true;
        end
    end
    
    % Read layer checkbox status from handles.layerSelection
    for i=1:length(check)
        check{i} = handles.layerSelection.(traceLayers{i});
    end
    
    % Update layers table with checkbox values, layer names and color
    set(handles.layers, 'Data', [check traceLayers color]);
    
    guidata(gcf, handles);

end

function selectTraceCallback(hObject, callbackdata)
% Callback that is called when a trace is selected from the trace list

    handles = guidata(gcf);
    if isempty(callbackdata.Indices)
        return
    end
    % Store selected trace index to handles.selection
    handles.selection = struct('Value', callbackdata.Indices);
    
    % update handles
    guidata(gcbf, handles);
        
    % plot the selected trace
    updateTrace(hObject, callbackdata);
    
end

function updateTrace(varargin)

    mainfig = findobj('Tag', 'mainfig');
    handles = guidata(mainfig);
    traces = getappdata(mainfig, 'traces');
        
    % Plot is only updated if traces are available and a trace is selected
    if isempty(traces); return; end
    if not(isfield(handles, 'selection')); return; end
    if isempty(handles.selection); return; end
    
    % plot only first trace when multiple traces are selected
    traceName = handles.traces.Data(handles.selection.Value(1,1),1);
    t = find(strcmp({traces.name}, traceName));
    
    % available layers
    traceLayers = fieldnames(traces(t).layers);
    
    % Layer style (color, line style, line width are defined using
    % utils.setLayerStyle. It is only called if the selected trace contains
    % layers that have not been defined yet
    if isfield(handles, 'layerStyle')
        setStyles = fieldnames(handles.layerStyle);
        if any(not(ismember(traceLayers,setStyles)))
            utils.setLayerStyle();
            handles = guidata(mainfig);
        end
    else
        utils.setLayerStyle();
        handles = guidata(mainfig);
    end
    
    % Update the layer table in the plot panel
    updateLayers();
    handles = guidata(mainfig);
    
    % remove manual Events from layer list because it is plotted in
    % ManEvPlot
    if any(not(cellfun('isempty', strfind(traceLayers, 'manEv_'))))
        traceLayers(not(cellfun('isempty', strfind(traceLayers, 'manEv_')))) = [];
    end
    
    % delete traceplot handles and clear axes
    handles.traceplot = [];
    axes(handles.trace)
    cla
    
    % Calculate time points from trace frame indices if an exposure time
    % has been set
    if isfield(handles, 'exposureTime')
        exposureTime = handles.exposureTime;
    else
        exposureTime = 1;
    end
        
    % plot all checked layers of selected trace
    for i=1:length(traceLayers)
        if handles.layers.Data{i,1} == 1
            X = exposureTime*(1:length(traces(t).layers.(traceLayers{i})));
            hold on
            fieldname = traceLayers{i};                        
            handles.traceplot.(fieldname) = ...
                plot(X, traces(t).layers.(traceLayers{i}),...
                'Color', handles.layerStyle.(fieldname).Color,...
                'LineStyle', handles.layerStyle.(fieldname).LineStyle,...
                'LineWidth', handles.layerStyle.(fieldname).LineWidth);
        end
    end
        
    % Clicks on the plotted lines are passed to the axes object for
    % callback action
    lines = get(handles.trace, 'Children');
    set(lines, 'HitTest', 'off');
        
    % limits of trace plot can be set automatically to the min/max of the
    % selected trace ('Trace'), to the min/max of all loaded traces
    % ('Global') or to fixed values ('Value'). At point Trace and Global
    % refer only to raw intensities
    % TO DO: extend auto limits to other trace layers (e.g. corrected) or
    % to maximum/minimum of all layers
    
    % Read limit type and values for xMin, xMax, yMin, yMax
    limType = {handles.xMin.Type.SelectedObject.String,...
        handles.xMax.Type.SelectedObject.String,...
        handles.yMin.Type.SelectedObject.String,...
        handles.yMax.Type.SelectedObject.String};
    lim = cellfun(@str2double,{handles.xMin.fixValue.String ...
        handles.xMax.fixValue.String ...
        handles.yMin.fixValue.String ...
        handles.yMax.fixValue.String});
    
    % Set limits depending on limit Type. For 'Fixed' the entry field is
    % enabled.
    % TO DO: make code more compact
    for i=1:4
        switch limType{i}
            case 'Trace'
                lim(i) = (-1)^i*inf;
                switch i
                    case 1
                        set(handles.xMin.fixValue, 'Enable', 'off')
                    case 2
                        set(handles.xMax.fixValue, 'Enable', 'off')
                    case 3
                        set(handles.yMin.fixValue, 'Enable', 'off')
                    case 4
                        set(handles.yMax.fixValue, 'Enable', 'off')
                end
            case 'Global'
                switch i
                    case 1
                        lim(i) = 1;
                        set(handles.xMin.fixValue, 'Enable', 'off')
                    case 2
                        lim(i) = max(size([traces.raw],1));
                        set(handles.xMax.fixValue, 'Enable', 'off')
                    case 3
                        lim(i) = min(min([traces.raw])); % extend to values of other layers
                        set(handles.yMin.fixValue, 'Enable', 'off')
                    case 4
                        lim(i) = max(max([traces.raw]));
                        set(handles.yMax.fixValue, 'Enable', 'off')
                end
            case 'Fixed'
                switch i
                    case 1
                        set(handles.xMin.fixValue, 'Enable', 'on')
                    case 2
                        set(handles.xMax.fixValue, 'Enable', 'on')
                    case 3
                        set(handles.yMin.fixValue, 'Enable', 'on')
                    case 4
                        set(handles.yMax.fixValue, 'Enable', 'on')
                end
        end
    end
    
    axes(handles.trace);
    axis(lim);
    
    % read actual limits of the plot and print values in the gui
    updateLimits();
    
    % Print the name of the currently plotted trace in the info panel
    set(handles.tracename, 'String', traces(t).name);
    
    guidata(gcf, handles);
    
    % Call plot funtion of ManualEvents
    functions.ManualEvents(gcf, 'plot');
    
    
    guidata(mainfig,handles);
    
% Update overview image in Info field
if not(isempty(handles.overview))
    axes(handles.overview)
    if isfield(handles.functions.SpatialFiltering,'mask')
        ov = insertShape(handles.functions.SpatialFiltering.mask.gray,'polygon',handles.functions.SpatialFiltering.mask.poly,'LineWidth',5);
        pos = [traces(t).position(1) traces(t).position(2) 5];
        ov = insertShape(ov,'circle',pos,'LineWidth',4,'Color','green');
        imshow(ov);
    end
end

% Execute the currently selected function
updateFunction(mainfig, [])
    
end

function selectLayerCallback(hObject, eventdata)
% Callback that is called when trace layer table is edited e.g. layer
% checkboxes are checked or unchecked

    handles = guidata(gcf);
    Indices = eventdata.Indices;
    Data = handles.layers.Data;
    if Indices(2) == 1
        handles.layerSelection.(Data{Indices(1),2}) = eventdata.NewData;
        guidata(gcbf, handles);
    end

    if ~isempty(eventdata.Indices)
       updateTrace(); 
    end

end

function deleteTraces(varargin)

    mainfig = gcbf;
    handles = guidata(mainfig);
    traces = getappdata(mainfig, 'traces');
        
    if isempty(traces);
        errordlg(['Can''t delete traces if there aren''t any...' ...
            'Load some and come back.']); return; 
    end
    
    handles.delTraces = figure(...
        'Position', [0, 0, 400, 100], ...
        'Name', 'Delete Traces...', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'on', ...
        'Visible', 'on');
    movegui(handles.delTraces, 'center');
    
    h.except = uicontrol('Parent', handles.delTraces,...
        'Style', 'checkbox',...
        'Units', 'normalized',...
        'Position', [.05 .5 .2 .45],...
        'String', 'all except');
    h.selection = uicontrol('Parent', handles.delTraces,...
        'Style', 'popupmenu',...
        'Units', 'normalized',...
        'Position', [.25 .5 .7 .35],...
        'String', {'all'},...
        'Value', 1);
    uicontrol('Parent', handles.delTraces,...
        'Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [.05 .05 .9 .45],...
        'String', 'Delete',...
        'Callback', @delTr);
    
    cat_descr_struct = [traces.cat_descr];
    cat_name = fieldnames([traces.cat_descr]);
    cat_descr = struct2cell(cat_descr_struct(1));
    
    cat_drop = strcat({'Category: '}, cat_name, {'('}, cat_descr, {')'});
        
    set(h.selection, 'String', ['all'; cat_drop]);
    
    
    function delTr(varargin)
        
        button = questdlg(['Are you sure about deleting selected traces?'...
            'This will remove the traces from the workspace including all'...
            ' category assignements and analysis. It cannot be undone']);        
        if not(strcmp(button, 'Yes'))
            return;
        end
                
        if h.selection.Value == 1
            indices = true(length(traces),1);
        else
            cat_index = h.selection.Value - 1;
            indices = cell2mat(handles.traces.Data(:,cat_index + 1));
        end
        
        if h.except.Value == 1
            ind = indices;
        else
            ind = not(indices);
        end
        
        traces = traces(ind);
        
        setappdata(mainfig, 'traces', traces);
        delete(gcf);
        updateTraceList();
        
    end
end

function updateLimits(varargin)

    % updating the trace plot limit values after using the zoom tool

    handles = guidata(gcbf);
    
    yd = get(get(handles.trace,'children'),'YData');
    if iscell(yd); yd = [yd{:}];end
    ydminmax = [min(yd) max(yd)];
    yresult = ylim;
    ind = isinf(yresult);
    yresult(ind) = ydminmax(ind); %// replace infinite values by computed values 
    
    xd = get(get(handles.trace,'children'),'XData');
    if iscell(xd); xd = [xd{:}];end
    xdminmax = [min(xd) max(xd)];
    xresult = xlim;
    ind = isinf(xresult);
    xresult(ind) = xdminmax(ind); %// replace infinite values by computed values    
    
    lim = [xresult yresult];
        
    % print limits to the limit field in the gui
    set(handles.xMin.fixValue, 'String', lim(1));
    set(handles.xMax.fixValue, 'String', lim(2));
    set(handles.yMin.fixValue, 'String', lim(3));
    set(handles.yMax.fixValue, 'String', lim(4));
    
end

%% Analysis Functions
function createFunction(hObject, callbackdata)

    handles = guidata(gcf);
    
    % generate functions with respective callbacks
    if not(isfield(handles, 'functions'))
        handles.functions.SlidingAvg = struct('name', 'Sliding Average',...
            'callback', @functions.SlidingAvg);
        handles.functions.SavitzkyGoley = struct('name', 'Savitzky-Goley-Filtering',...
            'callback', @functions.SavitzkyGoley);
        handles.functions.ManualEvents = struct('name', 'ManualEvents',...
            'callback', @functions.ManualEvents);
        handles.functions.SpatialFiltering = struct('name', 'SpatialFiltering',...
            'callback', @functions.SpatialFiltering);
        handles.functions.Thresholding = struct('name', 'Thresholding',...
            'callback', @functions.Thresholding);
    end

    % write function names to dropdown menu
    fcn = fieldnames(handles.functions);
    for i=1:length(fcn)
        list{i} = handles.functions.(fcn{i}).name;
        set(handles.activeFunction, 'String', list)
    end

    % store function handles and execute all function callbacks
    guidata(hObject, handles);
    for i=1:length(fcn)
    handles.functions.(fcn{i}).callback(hObject);
    handles = guidata(hObject);
    end
    
    updateFunction(hObject, [])

end

function updateFunction(hObject, ~)

    handles = guidata(gcf);
    fcn = fieldnames(handles.functions);
    active = fcn{handles.activeFunction.Value};
    
    for i=1:length(fcn)
        set(handles.functions.(fcn{i}).panel, 'Visible', 'off');
    end
    set(handles.functions.(active).panel, 'Visible', 'on');
    handles.functions.(active).callback(hObject)
    
end

%% Data handling (Open, Import, Save Traces etc)
function importTracesCallback(hObject, eventdata)

    handles = guidata(hObject);
    
    % Ask user for data format.
    % Supported options
    %   ALEX: Searches for 
    %   3Color: Searches for 
    dataformat = questdlg( ...
        'Please specify data format', ...
        'Import csv...', ...
        'One Color from AlexOneforAll', 'Three Color from AlexOneforAll', 'One Color from AlexOneforAll');
    
    % open ui-window to open csv-files    
    [FileName,PathName,FilterIndex] = uigetfile('*.csv');
    
    if FileName==0; return; end;
    filePath = strcat(PathName, FileName);
    
    wh = waitbar(0, 'reading csv files...');
    
    % if csv-filename is compatible with filename from Alex-Software
    % export ('*-raw.csv') the other files are searched (*-background.csv,
    % -header.csv) and background and positions are extracted. Else 
    % background and positions are set to zero
   switch dataformat

       case 'Three Color from AlexOneforAll'
           colorindex = [{'blue'},{'green'},{'red'}];
           raw = [];
           backgrounds = [];
           if strcmpi(FileName(end-11:end), 'greenRaw.csv')        
               name = FileName(1:end-12);
           elseif strcmpi(FileName(end-9:end), 'redRaw.csv')
               name = FileName(1:end-10);
           elseif strcmpi(FileName(end-10:end), 'blueRaw.csv')
               name = FileName(1:end-11);              
           else
               h = errordlg('Could not import .csv files: Unrecognized file name','Error while importing traces');
           end
                      
           for ct = 1:length(colorindex)
               if exist(fullfile(PathName, [name colorindex{1,ct} 'Raw.csv']), 'file') == 2
                   fullpath = fullfile(PathName, [name colorindex{1,ct} 'Raw.csv']);
                   csv = utils.csv2cell(fullpath, 'fromfile');
                   raw_temp = cellfun(@str2num,csv(:,2:end));
                   raw = [raw, raw_temp];
               else
                   h = errordlg('Could not import .csv files: Could not find raw .csv file.','Error while importing traces');
               end
               
               if exist(fullfile(PathName, [name colorindex{1,ct} 'Background.csv']), 'file') == 2
                   fullpath_bg = fullfile(PathName, [name colorindex{1,ct} 'Background.csv']);
                   csv_bg = utils.csv2cell(fullpath_bg, 'fromfile');
                   backgrounds_temp = cellfun(@str2num,csv_bg(:,2:end));
                   backgrounds = [backgrounds, backgrounds_temp];
               else
                   backgrounds = zeros(size(raw,1), size(raw, 2));
               end
           end
           
           if exist(fullfile(PathName, [name '-header.csv']), 'file') == 2
               filepath_h = fullfile(PathName, [name '-header.csv']);
               csv_h = utils.csv2cell(filepath_h, 'fromfile');
           else
               peakPositions = zeros(2, size(raw, 2));
           end
    
       case 'One Color from AlexOneforAll'
           % convert csv-file to cell array
           csv = utils.csv2cell(filePath, 'fromfile');
           % write csv file to raw, omit first column (=frame index)
           raw = cellfun(@str2num,csv(:,2:end));
           
           if strcmpi(FileName(end-7:end), '-raw.csv')
                name = FileName(1:end-8);
                    waitbar(.33);
                if exist(fullfile(PathName, [name '-background.csv']), 'file') == 2
                    filepath_b = fullfile(PathName, [name '-background.csv']);
                    csv_b = utils.csv2cell(filepath_b, 'fromfile');
                    backgrounds = cellfun(@str2num,csv_b(:,2:end));
                else
                    backgrounds = zeros(size(raw,1), size(raw, 2));
                end
                    waitbar(.66);
                if exist(fullfile(PathName, [name '-header.csv']), 'file') == 2
                    filepath_h = fullfile(PathName, [name '-header.csv']);
                    csv_h = utils.csv2cell(filepath_h, 'fromfile');
                    peakPositions = cellfun(@str2num,(csv_h(8:end,2:3))');
                else
                    peakPositions = zeros(2, size(raw, 2));
                end
           else
            peakPositions = zeros(2, size(raw, 2));
            backgrounds = zeros(size(raw,1), size(raw, 2));
           end          
   end
    close(wh)
        
    mapping = [];
    
    wh = waitbar(0, 'importing traces...');
    % write csv data to traces object
    for p=1:size(raw, 2)
        traces(p) = alex.traces.Trace(p,...
            peakPositions(:, p), raw(:, p), backgrounds(:, p), mapping);
        waitbar(p/size(raw, 2));
    end
    close(wh);
        
    % send data with temporal information to the layers property
    a = {'raw' 'background' 'corrected' 'fretEfficiency' 'stoichiometry'...
        'leakageCoefficient' 'directExcitationCoefficient'};
    
    wh = waitbar(0, 'setting trace layers...');
    for i=1:length(a)   % loop over layers defined in a
        if not(isempty([traces.(a{i})]))
            for j=1:length(traces)  % loop over all elements of the trace object
                traces(j).layers.(a{i}) = traces(j).(a{i});
            end
        end
        waitbar(i/length(a));
    end
    close(wh);
    
    % send created layers to the layer control table of the ui
    layers = fieldnames(traces(1).layers);
    Data = [num2cell(true(length(layers),1)) layers];
    set(handles.layers, 'Data', Data);
    
    setappdata(gcbf, 'traces', traces);
    
    % Update window title
    set(gcbf, 'Name', ['Trace Analysis Alpha - ' filePath]);
    
    % write imported traces to the traces list
    updateTraceList();
    % Clear the trace plot
    axes(handles.trace)
    cla
    
end

function openTracesCallback(hObject, eventdata)

    handles = guidata(hObject);

    [FileName,PathName,FilterIndex] = uigetfile('*.mat');
    if FileName==0; return; end;
    
    filepath = strcat(PathName, FileName);

    object = open(filepath);
    
    % write field 'traces' of opened .mat-file to the trace-object
    traces = object.traces;
    
    datatype = class(traces(1,1).mapping);
    
    switch datatype
        case 'alex.movie.MappingThreeColors'
            
            for j=1:length(traces)  % loop over all elements of the trace object
                photonstreams = traces(j).mapping.photonStreamNames;
                for k=1:length(photonstreams)
                    raw_layer = strcat(photonstreams{k},'_raw');
                    traces(j).layers.(raw_layer) = traces(j).rawByName(photonstreams{k});
                    bg_layer =  strcat(photonstreams{k},'_background');
                    traces(j).layers.(bg_layer) = traces(j).backgroundByName(photonstreams{k});
                    corr_layer =  strcat(photonstreams{k},'_corrected');
                    traces(j).layers.(corr_layer) = traces(j).correctedByName(photonstreams{k});
                end
            end
            
        otherwise

            % send data with temporal information to the layers property
            a = {'raw' 'background' 'corrected' 'fretEfficiency' 'stoichiometry' 'leakageCoefficient' 'directExcitationCoefficient'};
            
            for i=1:length(a)   % loop over layers defined in a
                if not(isempty([traces.(a{i})]))
                    for j=1:length(traces)  % loop over all elements of the trace object
                        traces(j).layers.(a{i}) = traces(j).(a{i});
                    end
                end
            end
    end
                    
    setappdata(gcbf, 'traces', traces);
    
    % Update window title
    set(gcbf, 'Name', ['Trace Analysis Alpha - ' filepath]);
    
    % write opened traces to the traces list
    updateTraceList(gcf);
    % Clear the trace plot
    axes(handles.trace)
    cla
        
end

function saveTracesCallback(varargin)

    traces = getappdata(gcbf, 'traces');
       
%     uisave('traces');

    % Retrieve the filename and path of the opened file from the window
    % title. Watch out! This could be error-prone.
    fig = gcf;
    DefaultName = [fig.Name(24:end-3) 'mat'];
  
    [FileName,PathName,FilterIndex] =...
        uiputfile('*.mat','Save traces to mat-file',DefaultName);
    
    if FileName == 0; return; end
    
    save(fullfile(PathName,FileName), 'traces');
    
end