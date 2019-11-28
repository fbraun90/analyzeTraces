
function setLayerStyle(varargin)

    handles = guidata(gcbf);
    traces = getappdata(gcbf, 'traces');
    
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
        0 0 0] / 255;
    
    layers = cell(length(traces),1);

    for i=1:length(traces)
       layers{i} = [fieldnames(traces(i).layers)];
    end

    for i=1:length(traces)
        layer_length(i) = length(layers{i});
    end
    max_layer_length = max(layer_length);

    layerArray = cell(length(traces), max_layer_length);
    for i=1:length(traces)
        layerArray(i,1:layer_length(i)) = layers{i};
    end
    uniqueLayers = unique(layerArray(~cellfun(@isempty, layerArray)));
    
    if not(isfield(handles, 'layerStyle'))
        
        layerStyle = struct();

        for i=1:length(uniqueLayers)
            if not(isfield(layerStyle, uniqueLayers{i}))
                colorIndex = i;
                if colorIndex >= length(colors)
                    layerStyle.(uniqueLayers{i}).Color = [0 0 0];
                    layerStyle.(uniqueLayers{i}).ColorIndex = length(colors);
                else
                    layerStyle.(uniqueLayers{i}).Color = colors(i,:);
                    layerStyle.(uniqueLayers{i}).ColorIndex = i;
                end
                layerStyle.(uniqueLayers{i}).LineStyle = '-';
                layerStyle.(uniqueLayers{i}).LineWidth = 1;
            end
        end
        
    else
       
        layerStyle = handles.layerStyle;
        
        setStyles = fieldnames(handles.layerStyle);
        newLayers = uniqueLayers(not(ismember(uniqueLayers,setStyles)));
        if not(isempty(newLayers))
            for i=1:length(newLayers)
                colorIndex = length(setStyles)+i;
                if colorIndex >= length(colors)
                    layerStyle.(newLayers{i}).Color = [0 0 0];
                    layerStyle.(newLayers{i}).ColorIndex = length(colors);
                else
                    layerStyle.(newLayers{i}).Color = colors(colorIndex,:);
                    layerStyle.(newLayers{i}).ColorIndex = colorIndex;
                end
                layerStyle.(newLayers{i}).LineStyle = '-';
                layerStyle.(newLayers{i}).LineWidth = 1;
            end
        end
    end
    
    handles.layerStyle = layerStyle;
    guidata(gcbf, handles);

end