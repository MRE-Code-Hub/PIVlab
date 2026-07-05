function delete_all_Callback(~,~,~)
handles=gui.gethand;
filepath=gui.retr('filepath');
masks_in_frame=gui.retr('masks_in_frame');
ismean=gui.retr('ismean');
if isempty(ismean)
	num_frames=floor(numel(filepath)/2);
else
	num_frames=max(find(ismean==0)); %#ok<MXFND> %last non-mean frame
end
[frames_rows,~,ok]=misc.parse_frame_selection(get(handles.mask_clear_frames,'string'),num_frames);
frames=unique([frames_rows{:}]);
frames=frames(frames>=1 & frames<=num_frames); %clamp to valid range
if ok==0 || isempty(frames)
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error in frame selection syntax. Use e.g. 1:end, 1,4,7 or 10:15.','modal');
	return
end
for i=frames
	if i<=numel(masks_in_frame)
		masks_in_frame{i}=cell(0); %clear that frame's ROIs
	end
end
gui.put('masks_in_frame',masks_in_frame);
gui.sliderdisp(gui.retr('pivlab_axis')); %redraw_masks removes stale ROI graphics for current frame
