function check_sync_firmware(firmware_version)
%% get latest sync firmware version from server
filename_update = fullfile(userpath ,'latest_version_oltsync.txt');
current_url = 'http://william.thielicke.org/PIVlab/latest_version_oltsync.txt';
if exist('websave','builtin')||exist('websave','file')
		outfilename=websave(filename_update,current_url,weboptions('Timeout',2));
		try
			outfilename2=websave(filename_starred,starred_feature_url,weboptions('Timeout',2));
		catch
		end
	else
		outfilename=urlwrite(current_url,filename_update); %#ok<*URLWR>
		try
			outfilename2=urlwrite(starred_feature_url,filename_starred); %#ok<*URLWR>
		catch
		end
	end
	%version number
	fileID_update = fopen(filename_update);
	web_version = textscan(fileID_update,'%s');
	latest_firmware=cell2mat(web_version{1});
	trash_upd = fclose(fileID_update);
	if ispc %Matlab seems to have issues with deleting files on unix systems
		recycle('on');
		delete(filename_update)
	end
%% compare 
firmware_version_num=str2double(firmware_version);
latest_firmware_num=str2double(latest_firmware);
if ~isnan(latest_firmware_num) && ~isnan(firmware_version_num)
	if str2double(firmware_version) < str2double(latest_firmware)
		gui.custom_msgbox('success',getappdata(0,'hgui'),'New firmware found',{'A new firmware for your synchronizer has been published.' 'Please contact OPTOLUTION to get the file:' 'info@optolution.com'},'modal');
	end
else
	disp('Could not check for synchronizer updates.')
end
%pivlab_axis=gui.retr('pivlab_axis');
%text (1025,800,['   ' sprintf('\n') gui.retr('update_msg')], 'fontsize', 10,'fontangle','italic','horizontalalignment','right','Color',gui.retr('update_msg_color'),'verticalalignment','top','Parent',pivlab_axis);