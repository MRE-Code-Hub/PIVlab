function MainWindow_CloseRequestFcn(hObject, ~, ~)
handles=gui.gethand;
batchModeActive=gui.retr('batchModeActive');
if batchModeActive == 0
	button = questdlg('Do you want to quit PIVlab?','Quit?','Yes','Cancel','Cancel');
else
	button = 'Yes';
end
try
	gui.toolsavailable(1)
catch
end
if strcmp(button,'Yes')==1
	try
		homedir=gui.retr('homedir');
		pathname=gui.retr('pathname');
		save('PIVlab_settings_default.mat','homedir','pathname','-append');
		%save last settings in acquisition menu
		last_selected_device = get(handles.ac_config, 'value');
		last_selected_fps = get(handles.ac_fps,'Value');
		last_selected_pulsedist = get(handles.ac_interpuls,'String');
		last_selected_energy =get(handles.ac_power,'String');
		save('PIVlab_settings_default.mat','last_selected_device','last_selected_fps','last_selected_pulsedist','last_selected_energy','-append');
		selected_com_port = gui.retr('selected_com_port');
		if ~isempty(selected_com_port)
			save('PIVlab_settings_default.mat','selected_com_port','-append');
		end
	catch
	end
	try
		PIVlab_capture_lensctrl (1400,1400,0) %lens needs to be set to neutral otherwise re-enabling power might cause issues
	catch
	end

	try
		
		hgui = getappdata(0,'hgui');
		serpo=getappdata(hgui,'serpo');
		string3='WarningSignDisable!';
		pause(1)
		writeline(serpo,string3); %disable the lighting of the laser warning sign
		pause(0.5)
	catch
	end
	try
		delete(hObject);
	catch
		close(gcf,'force');
	end
end

