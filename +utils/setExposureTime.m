function setExposureTime(varargin)

    handles = guidata(gcf);
    
    prompt = {'Exposure Time [ms] (enter 0 for disable)'};
    dlg_title = 'Exposure Time';
    num_lines = 1;
    defaultans = {'50'};
    
    answer = str2double(inputdlg(prompt, dlg_title, num_lines,defaultans));
    if isempty(answer); return; end
    if answer == 0
        handles.exposureTime = 1;
        handles.trace.XLabel.String = 'Frame';
    else
        handles.exposureTime = 0.001*answer;
        handles.trace.XLabel.String = 'Time [s]';
    end
    
    % update handles
    guidata(gcf, handles);
    
    uiAnalyzeTraces('updateTrace');

end