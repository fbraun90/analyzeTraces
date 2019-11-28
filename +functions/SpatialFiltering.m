function SpatialFiltering(figure)

handles = guidata(figure);
traces = getappdata(gcf, 'traces');

if isfield(handles.functions.SpatialFiltering, 'panel')
    return;
end

% main panel
handles.functions.SpatialFiltering.panel = uipanel(...
    'Parent', gcf, ...
    'Units', 'normalized', ...
    'Position', [.32, .01, .33, .44], ...
    'Title', 'Spatial Filtering',...
    'Visible', 'off');

uicontrol(... 
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'text', ...
    'HorizontalAlignment', 'left',...
    'Units', 'normalized', ...
    'Position', [.02 .85 .4 .1], ...
    'String', 'Path to mask/image file', ...
    'BusyAction', 'cancel');

handles.functions.SpatialFiltering.maskFilepath = uicontrol( ...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'edit', ...
    'HorizontalAlignment', 'left',...
    'Units', 'normalized', ...
    'Position', [.02 .85 .8 .05], ...
    'String', '', ...
    'UserData', '', ...
    'BusyAction', 'queue');
    
uicontrol( ...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'Pushbutton', ...
    'Units', 'normalized', ...
    'Position',[.02 .7 .2 .1], ...
    'String', 'Load calibration', ...
    'Callback', @loadCalibration);

uicontrol( ...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'Pushbutton', ...
    'Units', 'normalized', ...
    'Position',[.22 .7 .2 .1], ...
    'String', 'Create mask', ...
    'Callback', @createcellMask);
    
uicontrol(...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'Pushbutton', ...
    'Units', 'normalized', ...
    'Position',[.42 .7 .2 .1], ...
    'String', 'Load mask', ...
    'Callback', @loadMask);

handles.functions.SpatialFiltering.saveMask = uicontrol(...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'Pushbutton', ...
    'Units', 'normalized', ...
    'Position',[.62 .7 .2 .1], ...
    'String', 'Save mask', ...
    'Enable', 'off', ...
    'Callback', @saveMask);

uicontrol(...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'text', ...
    'HorizontalAlignment', 'left',...
    'Units', 'normalized', ...
    'Position', [.02 .45 .4 .1], ...
    'String', 'Category base name', ...
    'BusyAction', 'cancel');

handles.functions.SpatialFiltering.catbase = uicontrol(...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'edit', ...
    'HorizontalAlignment', 'left',...
    'Units', 'normalized', ...
    'Position', [.02 .45 .8 .05], ...
    'String', 'cell_', ...
    'UserData', '', ...
    'BusyAction', 'queue');

handles.functions.SpatialFiltering.createCategories = uicontrol(...
    'Parent', handles.functions.SpatialFiltering.panel, ...
    'Style', 'Pushbutton', ...
    'Units', 'normalized', ...
    'Position',[.02 .25 .6 .1], ...
    'String', 'Create categories from mask', ...
    'Enable', 'off', ...
    'Callback', @createCategories);

guidata(gcf, handles);

end


function handles = loadCalibration(hObject, eventdata)
% select a calibration file and load it
    
    [FileName,PathName] = uigetfile('.mat', 'Select a Calibration File');
    
    if not(isempty(FileName))
        handles = guidata(hObject);
        
        handles.SFmaskCalibFilePath = fullfile(PathName,FileName);
        temp = load(fullfile(PathName,FileName));     
        handles.SFmaskCalibCrop = temp.posRect;
        
    end
    
    guidata(gcf, handles);


end

function handles = createcellMask(hObject, eventdata, varargin)

handles = guidata(hObject);

[FileName,PathName] = uigetfile('*.tif','Select .tif file to draw mask');

if not(isempty(FileName))
    filePath = fullfile(PathName,FileName);
    handles.SFmaskFilepath = filePath;
end

if isfield(handles,'SFmaskCalibCrop')
    [avg avg_gray] = utils.tiffavg(filePath,3,handles.SFmaskCalibCrop);
else
    [avg avg_gray] = utils.tiffavg(filePath,3);
end

fig = figure();
imshow(avg_gray)
poly = impoly();
mask = createMask(poly);

mask_export = struct;
mask_export.gray = avg_gray;
mask_export.poly = getPosition(poly);
mask_export.mask = mask;
mask_export.maskfpath = filePath;

temp = [];
for i=1:length(mask_export.poly)
    temp = [mask_export.poly(i,:) temp];
end

mask_export.poly = temp;

axes(handles.overview)
imshow(insertShape(avg_gray,'polygon',mask_export.poly,'LineWidth',5));

set(handles.functions.SpatialFiltering.saveMask,'Enable', 'on');
set(handles.functions.SpatialFiltering.createCategories,'Enable','on');
set(handles.functions.SpatialFiltering.maskFilepath,'String', handles.SFmaskFilepath);
handles.functions.SpatialFiltering.mask = mask_export;

uiAnalyzeTraces('updateTrace')
guidata(gcf, handles);

end

function loadMask(hObject, eventdata, handles)

[FileName,PathName] = uigetfile('*.mat','Select .mat mask file');

if not(isempty(FileName))
    filePath = fullfile(PathName,FileName);
    handles.SFmaskFilepath = filePath;
end

handles = guidata(hObject);
mask_temp = load(filePath);

if not(isempty(mask_temp.mask_export.mask))
    handles.functions.SpatialFiltering.mask = mask_temp.mask_export;
    set(handles.functions.SpatialFiltering.maskFilepath,'String', filePath);
    set(handles.functions.SpatialFiltering.saveMask,'Enable', 'on');
    set(handles.functions.SpatialFiltering.createCategories,'Enable','on');
    axes(handles.overview)
    imshow(insertShape(handles.functions.SpatialFiltering.mask.gray,'polygon',handles.functions.SpatialFiltering.mask.poly,'LineWidth',5));
    else
    error('Inavlied .mat file.');
end

uiAnalyzeTraces('updateTrace')
guidata(gcf, handles);
end

function saveMask(hObject, eventdata, varargin)

handles = guidata(hObject);
mask_export = handles.functions.SpatialFiltering.mask;
uisave({'mask_export'},'mask.mat')

end

function createCategories(hObject, eventdata, varargin)

handles = guidata(gcbf);
traces = getappdata(gcbf, 'traces');

catbase = handles.functions.SpatialFiltering.catbase.String;
if not(isvarname(catbase))
    errordlg('Invalid output category name. Use only letters, digits and underscores. Start with a letter.')
    return;
end

if isempty(traces)
    errordlg('No traces, no categories!');
    return;
end

newcatName = sprintf('%s_inside',catbase);
maskDescr = sprintf('Trace position is inside/outside of %s ROI',catbase);

% create new category for every trace. check if position of trace is
% inside/outside roi to determine if category is t/f.
for t=1:length(traces)
    traces(t).cat_descr.(newcatName) = maskDescr;
    % check if trace position is inside mask
    if handles.functions.SpatialFiltering.mask.mask(traces(t).position(2),traces(t).position(1))
        traces(t).category.(newcatName) = true;
    else
        traces(t).category.(newcatName) = false;
    end
end

% save new category to the traces object
setappdata(gcbf, 'traces', traces);

% Update Filter dropdown and set to "all"
set(handles.traceListFilter, 'String', ['all'; fieldnames([traces.cat_descr])],...
    'Value', 1);

uiAnalyzeTraces('updateTraceList');

end