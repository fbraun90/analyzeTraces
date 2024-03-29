
function layerStylePopup(varargin)

    handles = guidata(gcbf);
    traces = getappdata(gcbf, 'traces');
    mainfig = gcbf;
    
    if isempty(traces); errordlg('No traces loaded.'); return; end
    
    handles.layerStylePopup = figure(...
        'Position', [0, 0, 450, 550], ...
        'Name', 'Layer Style', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Visible', 'on');
    movegui(handles.layerStylePopup, 'center');
    
    layerStyle = handles.layerStyle;    
  
% Overview over available colors and line styles

    uicontrol(handles.layerStylePopup, 'Style', 'text', 'String', 'Available Colors:',...
        'HorizontalAlignment', 'left',...
        'Position', [5 530 450 15 ]);      
   
    colors = ...
       [0 144 229
        203 23 0
        98 191 0
        62 0 220
        160 0 216
        212 0 170
        199 113 0
        189 195 0
        120 160 255
        255 240 120
        180 180 180
        120 120 120
        60 60 60
        0 0 0];
    
    for i=1:length(colors)
        layer_color{i} = colors(i,:);
        clr = ['rgb(' num2str(round(layer_color{i})) ')'];
        color{i,1} = strcat(['<html><body bgcolor="' clr 'width="5px"''><font color="'...
            clr '">sp</font><font color="rgb(255,255,255)">' num2str(i)...
            '</font><font color="' clr '">sp</font></body></html>']);
    end
   
    uitable(...
        'Parent', handles.layerStylePopup, ...
        'Position', [5, 490, 450, 35], ...
        'CellSelectionCallback', '', ...
        'CellEditCallback', '', ...
        'ColumnFormat', {'char'} ,...
        'ColumnEditable', false,...
        'ColumnWidth', {31}, ...
        'ColumnName', [], ...
        'RowName', [], ...
        'Data', color');
    
    uicontrol(handles.layerStylePopup, 'Style', 'text', 'String', 'Available Line Styles:',...
        'HorizontalAlignment', 'left',...
        'Position', [5 473 450 15]);
    
    style = {'solid' 'dashed' 'dotted' 'dash-dotted'
            '-' '--' ':' '-.'};
    
    uitable(...
        'Parent', handles.layerStylePopup, ...
        'Position', [5, 425, 450, 45], ...
        'CellSelectionCallback', '', ...
        'CellEditCallback', '', ...
        'ColumnFormat', {'char'} ,...
        'ColumnEditable', false,...
        'ColumnWidth', {108}, ...
        'ColumnName', [], ...
        'RowName', [], ...
        'RowStriping', 'off',...
        'Data', style);
        
    handles.layerTable = uitable(...
        'Parent', handles.layerStylePopup, ...
        'Position', [5, 50, 450, 370], ...
        'CellSelectionCallback', '', ...
        'CellEditCallback', '', ...
        'ColumnFormat', {'char'} ,...
        'ColumnEditable', [false true false true true],...
        'ColumnWidth', {40 40 288 30 40}, ...
        'ColumnName', {'Color' 'Index' 'Name' 'Style' 'Width'}, ...
        'RowName', [], ...
        'Data', [] );
    fillTable();
    
% Table listing all layers

    function fillTable(varargin)
    
        names = fieldnames(handles.layerStyle);
        Data = [];
        for i=1:length(names)
            info = struct2cell(handles.layerStyle.(names{i}));
            info{1} = num2str(info{1});
            row = [info(2); names{i}; info(3:4)];
            Data = [Data row];
        end

        color = [];
        for i=1:length(names)
            layer_color{i} = handles.layerStyle.(names{i}).Color;
            clr = ['rgb(' num2str(round(layer_color{i}*255)) ')'];
            color{i,1} = strcat(['<html><body bgcolor="' clr ...
                'width="10px"''><font color="' clr '">spacer</font></body></html>']);
        end

        tableData = [color Data'];
        set(handles.layerTable, 'Data', tableData);
    
    end
    
 % Pushbuttons
    
    uicontrol('Parent', handles.layerStylePopup, ...
        'Position', [5, 5, 140, 40], ...
        'Style', 'pushbutton',...
        'String', 'Refresh',...
        'Callback', @refresh);
    uicontrol('Parent', handles.layerStylePopup, ...
        'Position', [155, 5, 140, 40], ...
        'Style', 'pushbutton',...
        'String', 'OK',...
        'Callback', @apply)
    uicontrol('Parent', handles.layerStylePopup, ...
        'Position', [305, 5, 140, 40], ...
        'Style', 'pushbutton',...
        'String', 'Cancel',...
        'Callback', @close);
    
    function refresh(varargin)
        tableData = handles.layerTable.Data;
        for i=1:size(tableData,1)
            layerStyle.(tableData{i,3}).LineStyle = tableData{i,4};
            layerStyle.(tableData{i,3}).LineWidth = tableData{i,5};
            colorIndex = tableData{i,2};
            layerStyle.(tableData{i,3}).ColorIndex = colorIndex;
            layerStyle.(tableData{i,3}).Color = colors(colorIndex,:) / 255;
        end
    
        handles.layerStyle = layerStyle;
        guidata(mainfig, handles);
        setappdata(mainfig, 'traces', traces);
    
        fillTable();
        figure(mainfig);
        uiAnalyzeTraces('updateTrace');
        figure(handles.layerStylePopup);
        
    end
    
    function close(varargin)
        delete(handles.layerStylePopup)
    end

    function apply(varargin)
        refresh();
        delete(handles.layerStylePopup)
    end
        
end