function [errorCode,glvar] = pco_camera_open_close(glvar)
%open and close the camera SDK
%
%   [errorCode,glvar] = pco_camera_open_close(glvar)
%
% * Input parameters :
%    glvar                   structure to hold status info
%
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%    glvar                   structure to hold status info
%
%open and close the camera SDK 
%
%structure glvar is used to set different modes for
%load/unload library
%open/close camera SDK
%
%glvar.do_libunload: 1 unload lib at end
%glvar.do_close:     1 close camera SDK at end
%glvar.camera_open:  open status of camera SDK
%glvar.out_ptr:      libpointer to camera SDK handle
%
%if glvar does not exist,
%the library is loaded at begin and unloaded at end
%the SDK is opened at begin and closed at end
%
%function workflow
%camera SDK is opened
%camera SDK is closed
%errorCode and if available glvar is returned
%

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
	% make sure the dll and h file specified below resides in your current
	% folder
	if(strcmp(computer('arch'),'win64'))
		if ~exist('sc2_cam_mfile.m','file') %if prototype file not exists
			loadlibrary('sc2_cam', 'sc2_cammatlab.h','addheader','sc2_common.h','addheader','sc2_camexport.h','alias','PCO_CAM_SDK', 'mfilename', 'sc2_cam_mfile');
			disp('Making prototype file')
		end
		loadlibrary('sc2_cam', @sc2_cam_mfile,'alias','PCO_CAM_SDK') %loadlibrary with prototype file --> required for compiled apps. Does it work for non-compiled apps...?
		%loadlibrary( 'sc2_cam','sc2_cammatlab.h','addheader','sc2_common.h'  ,'addheader','sc2_camexport.h'  ,'alias','PCO_CAM_SDK');
	else
		error('This platform is not supported.');
	end
end

if((exist('glvar','var'))&& ...
   (isfield(glvar,'do_libunload'))&& ...
   (isfield(glvar,'do_close'))&& ...
   (isfield(glvar,'camera_open'))&& ...
   (isfield(glvar,'out_ptr')))
 unload=glvar.do_libunload;    
 cam_open=glvar.camera_open;
 do_close=glvar.do_close;
else
 unload=1;   
 cam_open=0;
 do_close=1;
end

%Declaration of variable CameraHandle 
%out_ptr is the CameraHandle, which must be used in all other libcalls
ph_ptr = libpointer('voidPtrPtr');

%libfunctionsview('PCO_CAM_SDK');

%libcall PCO_OpenCamera
if(cam_open==0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_OpenCamera', ph_ptr, 0);
 if(errorCode == 0)
  cam_open=1;
  if((exist('glvar','var'))&& ...
     (isfield(glvar,'camera_open'))&& ...
     (isfield(glvar,'out_ptr')))
   glvar.camera_open=1;
   glvar.out_ptr=out_ptr;
  end 
 else
  pco_errdisp('PCO_OpenCamera',errorCode);   
  if(unload) 
    [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CleanupLib');
    unloadlibrary('PCO_CAM_SDK');
  end 

  return ;   
 end
else
 if(isfield(glvar,'out_ptr'))
  out_ptr=glvar.out_ptr;   
 end
end


if((do_close==1)&&(cam_open==1))
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
 if(errorCode)
  pco_errdisp('PCO_CloseCamera',errorCode);   
 else
  cam_open=0;
  if((exist('glvar','var'))&& ...
     (isfield(glvar,'out_ptr')))
   glvar.out_ptr=[];
  end
 end    
end

if((unload==1)&&(cam_open==0))
  [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CleanupLib');
  if(errorCode)
    pco_errdisp('PCO_CleanupLib',errorCode);   
  else
  end

  if(libisloaded('GRABFUNC'))
    unloadlibrary('GRABFUNC');
  end
  unloadlibrary('PCO_CAM_SDK');
end 

if((exist('glvar','var'))&& ...
   (isfield(glvar,'camera_open')))
 glvar.camera_open=cam_open;
end


end


