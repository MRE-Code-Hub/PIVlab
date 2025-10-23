function remove_images_from_list (~,~,~)
handles=gui.gethand;
if gui.retr('video_selection_done') ~= 1
	filepath=gui.retr ('filepath'); %full path and filename for analyses
	framenum=gui.retr ('framenum'); %important layer information for multi tiffs.
	framepart=gui.retr ('framepart'); %Only needed for pco panda multi-frame tiffs.
	multitiff=gui.retr('multitiff');
	box_select=get(handles.filenamebox,'value')';
	masks_in_frame=gui.retr('masks_in_frame');
	if ~isempty(masks_in_frame)
		masks_in_frame_doubled=cell(1,size(masks_in_frame,2)*2);
		for i = 1:2:size(masks_in_frame,2)*2
			masks_in_frame_doubled(i)=masks_in_frame((i+1)/2);
			masks_in_frame_doubled(i+1)=masks_in_frame((i+1)/2);
		end
	end
	if ~isempty(box_select) && numel(box_select)<=(numel(filepath)-2)
		for i=numel(box_select):-1:1
			filepath(box_select(i))=[];
			framenum(box_select(i))=[];
			framepart(box_select(i),:)=[];
			if ~isempty(masks_in_frame)
				masks_in_frame_doubled(box_select(i))=[];
			end
		end
		if ~isempty(masks_in_frame)
			masks_in_frame=cell(0);
			cntr=1;
			for i = 1:2:size(masks_in_frame_doubled,2)
				masks_in_frame(cntr)=masks_in_frame_doubled(i);
				cntr=cntr+1;
			end
			gui.put('masks_in_frame',masks_in_frame);
		end
		filename=cell(1);
		for i=1:size(filepath,1)
			if ispc==1
				zeichen=strfind(filepath{i,1},'\');
			else
				zeichen=strfind(filepath{i,1},'/');
			end
			currentpath=filepath{i,1};
			if ~multitiff
				if mod(i,2) == 1
					filename{i,1}=['A: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
				else
					filename{i,1}=['B: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
				end
			else
				if mod(i,2) == 1
					filename{i,1}=['A: ' currentpath(zeichen(1,size(zeichen,2))+1:end) ', layer: ' num2str(framenum(i))];
				else
					filename{i,1}=['B: ' currentpath(zeichen(1,size(zeichen,2))+1:end) ', layer: ' num2str(framenum(i))];
				end
			end
		end

		gui.put ('filename',filename); %only for displaying
		gui.put ('filepath',filepath); %full path and filename for analyses
		gui.put ('framenum',framenum); %important layer information for multi tiffs.
		gui.put ('framepart',framepart); %Only needed for pco panda multi-frame tiffs.
		gui.sliderrange(1)
		set (handles.filenamebox, 'string', filename);
		gui.put ('resultslist', []); %clears old results
		gui.put ('derived',[]);
		gui.put('displaywhat',1);%vectors
		gui.put('ismean',[]);
		gui.put('framemanualdeletion',[]);
		gui.put('manualdeletion',[]);
		%gui.put('streamlinesX',[]);
		%gui.put('streamlinesY',[]);
		%gui.put('bg_img_A',[]);
		%gui.put('bg_img_B',[]);
		%set(handles.bg_subtract,'Value',0);
		set(handles.fileselector, 'value',1);
		%set(handles.minintens, 'string', 0);
		%set(handles.maxintens, 'string', 1);
		set(handles.filenamebox,'value',1);
		if mod(size(filepath,1),2)==1
			set(handles.filenamebox,'BackgroundColor','r')
			gui.toolsavailable(0)
			set(handles.remove_imgs,'Enable','on');
			set(handles.filenamebox,'Enable','on');
			gui.custom_msgbox('warn',getappdata(0,'hgui'),'Warning: Uneven amount of images!',['One image could not be assigned to a pair. Number of images in the list must be even.' newline newline 'Please remove another image from the list to continue.'],'modal');
		else
			standard_bg_color=gui.retr('standard_bg_color');
			if isempty(standard_bg_color)
				standard_bg_color='w';
			end
			set(handles.filenamebox,'BackgroundColor',standard_bg_color);
			gui.toolsavailable(1)
		end
	else
		gui.custom_msgbox('error',getappdata(0,'hgui'),'Error: Not possible.','At least two images (one pair) must remain in the list.','modal');
	end
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error: Not possible for video files','This is only possible for image files.','modal');
end