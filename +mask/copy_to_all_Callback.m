function copy_to_all_Callback(~,~,~)
handles=gui.gethand;
currentframe=floor(get(handles.fileselector, 'value'));
masks_in_frame=gui.retr('masks_in_frame');
if isempty(masks_in_frame)
	%masks_in_frame=cell(currentframe,1);
	masks_in_frame=cell(1,currentframe);
end

if numel(masks_in_frame)<currentframe
	mask_positions=cell(0);
else
	mask_positions=masks_in_frame{currentframe};
end

if ~isempty (mask_positions)
	filepath=gui.retr('filepath');
	ismean=gui.retr('ismean');
	if isempty(ismean)
		num_frames=floor(numel(filepath)/2);
	else
		num_frames=max(find(ismean==0)); %#ok<MXFND> %last non-mean frame
	end
	[frames_rows,~,ok]=misc.parse_frame_selection(get(handles.mask_copy_frames,'string'),num_frames);
	frames=unique([frames_rows{:}]);
	frames=frames(frames>=1 & frames<=num_frames); %clamp to valid range
	if ok==0 || isempty(frames)
		gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error in frame selection syntax. Use e.g. 1:end, 1,4,7 or 10:15.','modal');
		return
	end
	for i=frames
		masks_in_frame{i} = mask_positions;
	end
end
gui.put('masks_in_frame',masks_in_frame);

