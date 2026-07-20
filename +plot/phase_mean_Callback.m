function phase_mean_Callback(~,~,~)
% clc
fprintf('Calculating the phase average\n')

% Borrowed from temporal_operation_Callback -->
handles=gui.gethand;
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
n_phases=str2double(n);
% fprintf('%s %d %s\n',"Let's do it", n_phases, "times.") % DEBUG

% comm_str=strcat('[1:',num2str(n_phases),':',num2str(n_fields));
% by default, there are no brackets
comm_str=strcat('1:',num2str(n_phases),':',num2str(n_fields));
for i=2:n_phases
    comm_str=strcat(comm_str,';',num2str(i),':',num2str(n_phases),':',num2str(n_fields));
end
% comm_str=strcat(comm_str,']');

set(handles.selectedFramesMean,'String', comm_str);
plot.temporal_operation_Callback([],[],1)

set(handles.selectedFramesMean,'String', strcat('1:',num2str(n_fields)));
