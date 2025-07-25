function [OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_synced_start(nr_of_images,ROI_OPTRONIS,frame_rate,bitmode)
fix_Optronis_skipped_frame=0;
hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
OutputError=0;

%% Prepare camera
delete(imaqfind); %clears all previous videoinputs
try
	hwinf = imaqhwinfo;
	%imaqreset
catch
	errordlg('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','Error!','modal')
	disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
end

found_correct_adaptor=0;
for adaptorID=1:numel(hwinf.InstalledAdaptors)
    info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
    if strcmp(info.AdaptorName,'gentl')
        disp(['gentl adaptor found with ID: ' num2str(adaptorID)])
        found_correct_adaptor=1;
        break
    end
end

if found_correct_adaptor~=1
	disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
	disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
    errordlg({'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'Error, support package missing','modal')
end

try
    %Getting camera device ID when multiple cameras are connected
    for CamID = 1: size(info.DeviceInfo,2)
        camName=info.DeviceInfo(CamID).DeviceName;
        if contains(camName,'Cyclone')
            break
        end
    end
    OPTRONIS_name = info.DeviceInfo(CamID).DeviceName;
catch
    errordlg('Error: Camera not found! Is it connected?','Error!','modal')
end

OPTRONIS_supported_formats = info.DeviceInfo(CamID).SupportedFormats;

% select bitmode (some support 8, 10, 12 bits)
if isempty(bitmode) || ~isnumeric(bitmode)
    bitmode=8;
end
if verLessThan('matlab','25') %if not 2025a and beyond: force to be 8 bit, because not supported by matlab.
    bitmode =8; %10 bit would make sense, but in Matlab, all data that is returned from OPTRONIS is 8 bit...
end
OPTRONIS_vid = videoinput(info.AdaptorName,info.DeviceInfo(CamID).DeviceID,['Mono' sprintf('%0.0d',bitmode)]);

OPTRONIS_settings = get(OPTRONIS_vid);
OPTRONIS_settings.PreviewFullBitDepth='On';
OPTRONIS_vid.PreviewFullBitDepth='On';

OPTRONIS_gain = gui.retr('OPTRONIS_gain');
if isempty(OPTRONIS_gain)
    OPTRONIS_gain=1;
end

OPTRONIS_counter = gui.retr('OPTRONIS_counter');
if isempty(OPTRONIS_counter)
    OPTRONIS_counter=0;
end
if OPTRONIS_counter==0
    OPTRONIS_settings.Source.CounterInformation = 'Off';
elseif OPTRONIS_counter ==1
    OPTRONIS_settings.Source.CounterInformation = 'On';
end

if ~verLessThan('matlab','25')
    OPTRONIS_settings.Source.AGain = num2str(OPTRONIS_gain);
end

ROI_OPTRONIS=[ROI_OPTRONIS(1)-1,ROI_OPTRONIS(2)-1,ROI_OPTRONIS(3),ROI_OPTRONIS(4)];
OPTRONIS_vid.ROIPosition=ROI_OPTRONIS;

%% prepare axes
PIVlab_axis = findobj(hgui,'Type','Axes');
OPTRONIS_climits=2^bitmode;
image_handle_OPTRONIS=imagesc(zeros(ROI_OPTRONIS(4),ROI_OPTRONIS(3)),'Parent',PIVlab_axis,[0 OPTRONIS_climits]);
setappdata(hgui,'image_handle_OPTRONIS',image_handle_OPTRONIS);

frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);
colormap default %reset colormap steps
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
colorbar

%% set camera parameters for triggered acquisition
%OPTRONIS trigger source cannot be set in Matlab. Therefore always set to
%external. Synchronizer must always run.
triggerconfig(OPTRONIS_vid, 'hardware','DeviceSpecific','DeviceSpecific');
OPTRONIS_settings.TriggerSource = 'SingleFrame';
%OPTRONIS_settings.Source.ExposureMode = 'Timed';
OPTRONIS_settings.TriggerMode ='On';
OPTRONIS_src=getselectedsource(OPTRONIS_vid);

%set extended framerate calculation
if ~verLessThan('matlab','25')
    OPTRONIS_settings.Source.MaxFrameRateExtended = 'Extended';
end
if contains(OPTRONIS_name,'Cyclone-2-2000-M')
	disp(['Found camera: ' 'Cyclone-2-2000-M'])
    %framerate=floor(1/((expotime+3)/1000^2)) %muss man auch setzen damit exposure time akzeptiert wird...
    exposure_time=ceil(1/frame_rate*1000^2-3); %minimum ist 459 bei 2166 fps
    minexpo=2;
    warning('off','imaq:gentl:hardwareTriggerTriggerModeOff'); %trigger property of OPTRONIS cannot be set in Matlab.
    warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning
elseif contains (OPTRONIS_name,'Cyclone-1HS-3500-M')
	disp(['Found camera: ' 'Cyclone-1HS-3500-M'])
	%framerate=floor(1/((expotime+3)/1000^2)) %muss man auch setzen damit exposure time akzeptiert wird...
    exposure_time=ceil(1/frame_rate*1000^2-3); %3178 ist maximum
    minexpo=2;
    warning('off','imaq:gentl:hardwareTriggerTriggerModeOff'); %trigger property of OPTRONIS cannot be set in Matlab.
    warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning
elseif contains (OPTRONIS_name,'Cyclone-25-150-M')
	disp(['Found camera: ' 'Cyclone-25-150-M'])
	%framerate=floor(1/((expotime+3)/1000^2)) %muss man auch setzen damit exposure time akzeptiert wird...
    exposure_time=ceil(1/frame_rate*1000^2-24); %149 ist maximum
    minexpo=12;
    warning('off','imaq:gentl:hardwareTriggerTriggerModeOff'); %trigger property of OPTRONIS cannot be set in Matlab.
    warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning
else
    disp('camera type unknown!')
end

fps_too_high=0;
OPTRONIS_src.ExposureTime = minexpo;
try
    OPTRONIS_src.AcquisitionFrameRate = frame_rate;
catch ME
    try
        msg=strsplit (ME.message,'value must be less than or equal to ');msg{2}(end)=[];msg=msg{2};
    catch
        msg = '(can not determine max. frame rate)';
    end
    uiwait(errordlg(['The frame rate is too high for the selected FOV. With the current settings, the frame rate must not be higher than ' msg ' fps.'],'Frame rate error'))
    fps_too_high=1;
end

if fps_too_high==0
    %% start acqusition (waiting for trigger)
    OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
    OPTRONIS_vid.FramesPerTrigger = OPTRONIS_frames_to_capture+2;
    triggerconfig(OPTRONIS_vid, 'manual');

    %OPTRONIS_vid.TriggerType = 'manual'; %requires trigger(OPTRONIS_vid) to start
    if ~isinf(nr_of_images) %only start capturing if save box is ticked.
    	flushdata(OPTRONIS_vid);
        % disp('pause added to avoid flushing of recorded frames...')
        pause(0.01)
    	OPTRONIS_vid.ErrorFcn = @CustomIMAQErrorFcn;
    	warning('off','imaq:gentl:hardwareTriggerTriggerModeOff'); %trigger property of OPTRONIS cannot be set in Matlab.
    	warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning
        start(OPTRONIS_vid);
    end
    warning('off','imaq:gentl:hardwareTriggerTriggerModeOff'); %trigger property of OPTRONIS cannot be set in Matlab.
    warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning
    preview(OPTRONIS_vid,image_handle_OPTRONIS);
    %der befehl oben führt wohl zu einem reset, denn acquisition mode wird auf defaults zurückgesetzt
    tmp=get(image_handle_OPTRONIS,'CData');
    tmp=size(tmp(:,:,1));
    set(image_handle_OPTRONIS,'CData',ones(tmp)*35);
    delete(frame_nr_display);
    frame_nr_display=text(100,100,'Ready!','Color',[1 1 0]);
    OPTRONIS_src.AcquisitionFrameRate = frame_rate; %muss man auch setzen damit exposure time akzeptiert wird...
    OPTRONIS_src.ExposureTime=exposure_time;
    pause(0.01)
    if ~isinf(nr_of_images)
        OPTRONIS_settings.Source.EnableFan='Off';
        %aufnahmes tartet erst nachdem letztes mal die settings geändert
        %wurden.
        trigger(OPTRONIS_vid)
    end
    caxis([0 2^bitmode]); %seems to be a workaround to force preview to show full data range...
    drawnow;
end
function CustomIMAQErrorFcn(obj, event, varargin)
stop(obj)
hgui=getappdata(0,'hgui');
setappdata(hgui,'cancel_capture',1)

% Define error identifiers.
errID = 'imaq:imaqcallback:invalidSyntax';
errID2 = 'imaq:imaqcallback:zeroInputs';

switch nargin
	case 0
		error(message(errID2));
	case 1
		error(message(errID));
	case 2
		if ~isa(obj, 'imaqdevice') || ~isa(event, 'struct')
			error(message(errID));
		end
		if ~(isfield(event, 'Type') && isfield(event, 'Data'))
			error(message(errID));
		end
end

% Determine the type of event.
EventType = event.Type;

% Determine the time of the error event.
EventData = event.Data;
EventDataTime = EventData.AbsTime;

% Create a display indicating the type of event, the time of the event and
% the name of the object.
name = get(obj, 'Name');
fprintf('%s event occurred at %s for video input object: %s.\n', ...
	EventType, datestr(datetime(EventDataTime),13), name);

% Display the error string.
if strcmpi(EventType, 'error')
	fprintf('%s\n', EventData.Message);
end


if strcmpi(event.Data.MessageID,'imaq:imaqmex:outofmemory')
	msgbox('Out of memory. RAM is full, most likely, you need to lower the amount of frames to capture to fix this error.','modal');
else
	msgbox('Image capture timeout. Most likely, memory is full and you need to lower the amount of frames to capture to fix this error. It is also possible that the synchronization cable is not plugged in correctly.','modal');
end
