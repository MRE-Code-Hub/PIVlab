function phase_mean_Callback(~,~,~)
% clc
fprintf('Calculating the phase average\n')

% Borrowed from temporal_operation_Callback -->
handles=gui.gethand;
% filepath=gui.retr('filepath');
% filename=gui.retr('filename');
% framenum=gui.retr('framenum');
% framepart=gui.retr('framepart');
resultslist=gui.retr('resultslist');
ismean=gui.retr('ismean');
if isempty(ismean)
	ismean=zeros(size(resultslist,2),1);
end
str = strrep(get(handles.selectedFramesMean,'string'),'-',':');
endinside=strfind(str, 'end');
if ~isempty(endinside)
	str = strrep(get(handles.selectedFramesMean,'string'),'end',num2str(max(find(ismean==0))));
end
strnum=str2num(str);
% <--

if ismean(max(strnum))
    errordlg("Do not include mean fields in the selection","Selection error")
    return
else
    n_fields=max(strnum);
end

n=get(handles.frames_per_period,'string');
n_phases=eval(n);
% fprintf('%s %d %s\n',"Let's do it", n_phases, "times.") % DEBUG

for i=1:n_phases
    set(handles.selectedFramesMean,'String', strcat(num2str(i),':',num2str(n_phases),':',num2str(n_fields)));
    plot.temporal_operation_Callback([],[],1)
end

set(handles.selectedFramesMean,'String', strcat('1:',num2str(n_fields)));
