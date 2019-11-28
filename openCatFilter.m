function multiCategoryFilter(varargin)

    mainfig = findobj('Tag', 'mainfig');
    handles = guidata(mainfig);
    traces = getappdata(mainfig, 'traces');
    
    if isempty(traces); errordlg('No traces, no categories!'); return; end
    if isempty(fieldnames([traces.category]))
        errordlg('There are no categories'); return; end
    
    catFieldnames = cellfun(@fieldnames,{traces.category},'UniformOutput',false);
    cats = unique([catFieldnames{:}]);
        
    Data = [cats num2cell(true(length(cats),1)) num2cell(false(length(cats),1))];
    figLength = 100 + (length(cats)-3) * 15;
    
    handles.catFilterFig = figure(...
        'Position', [0, 0, 250, figLength], ...
        'Name', 'Filter by category...', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Visible', 'on');
    movegui(catFilterFig, 'center');
    
    handles.catFilterTable = uitable(...
        'Parent', catFilterFig, ...
        'Units','normalized',...
        'Position', [.025, .05, .95, .9], ...
        'CellSelectionCallback', '', ...
        'CellEditCallback', @filterByCategory, ...
        'ColumnFormat', {'char' 'logical' 'logical'} ,...
        'ColumnEditable', [false true true],...
        'ColumnWidth', {140 45 45}, ...
        'ColumnName', {'Category name' 'necessary' 'exclude'}, ...
        'RowName', [], ...
        'Data', Data);
    handles.catTable.Data = Data;
    
    
    guidata(mainfig, handles);
    

end

function multiCategoryFilter(hObject, callbackdata)

    mainfig = findobj('Tag', 'mainfig');
    handles = guidata(mainfig);
    traces = getappdata(mainfig, 'traces');
    
    catIndex = callbackdata.Indices(1);
    catName = handles.catFilterTable.Data{catIndex};
    
    % when activating necessary/excluded for a category the other is
    % deactivated
    if callbackdata.NewData
        switch callbackdata.Indices(2)
        case 2
            handles.catFilterTable.Data{catIndex,3} = false;
        case 3
            handles.catFilterTable.Data{catIndex,2} = false;
        end
    end
    
    necFilter = [handles.catTable.Data{:,2}]';
    excFilter = [handles.catTable.Data{:,3}]';
    
    index = false(length(traces),1);
    
        for i=1:length(traces)
            thisIndex = cell2mat(struct2cell(traces(i).category));
            % category may not be excluded AND no cat is necessary OR any
            % necessary category is assigned
            index(i) =  ~any(excFilter & thisIndex) & (all(~necFilter) | any(necFilter & thisIndex));
        end
    
    updateTraceList(mainfig, index);

end