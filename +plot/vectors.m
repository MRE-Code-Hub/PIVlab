function [q, q2] = vectors(target_axis,handles, vecskip, x, typevector, y, u, vecscale, v, vectorcolor)

hold(target_axis,'on');
colors_cell = gui.vec_preset_colors();
vectorcolorintp    = colors_cell{get(handles.interp_color,    'Value'), 2};
vectorcolor2ndpeak = colors_cell{get(handles.secondpeak_color,'Value'), 2};

% gui.sliderdisp signals "color vectors by magnitude" by passing a char
% vector instead of an RGB triple. The colors must represent the TRUE
% velocity, so the magnitude is captured here, before the length-altering
% display transforms below (uniform / power scaling) touch u and v.
% This ordering is what makes "uniform vector length + magnitude color" work.
magnitude_mode = ~isnumeric(vectorcolor);
if magnitude_mode
    magnitude_true = sqrt( (u*gui.retr('calu') - gui.retr('subtr_u')).^2 + ...
                           (v*gui.retr('calv') - gui.retr('subtr_v')).^2 );
else
    magnitude_true = [];
end

%normalize vector lengths so we can better see flow directions of small velocities:
if (get (handles.uniform_vector_scale,'Value'))==1
    % The magnitude must be captured before u is overwritten: reusing the
    % expression after assigning u would normalize v by sqrt(u_norm^2+v^2),
    % which distorts both the length and the direction.
    mag_uniform = sqrt(u(:,:,1).^2 + v(:,:,1).^2);
    mag_uniform(mag_uniform==0) = 1;             % avoid 0/0 -> NaN at zero vectors
    u = u(:,:,1)./mag_uniform;                   % normalized u
    v = v(:,:,1)./mag_uniform;                   % normalized v
end
if (get (handles.power_vector_scale,'Value'))==1
    exponent_1=str2double(get(handles.power_vector_scale_factor,'String'));
    mag_old = sqrt(u.^2 + v.^2);                 % original vector lengths
    mag_new = mag_old.^exponent_1;               % compressed lengths
    % preserve the overall mean length so the plot scale stays comparable
    scale = mean(mag_old(:),'omitnan') / mean(mag_new(:),'omitnan');
    mag_new = mag_new * scale;
    ratio = mag_new ./ mag_old;                  % per-vector length change
    ratio(mag_old==0) = 0;                       % avoid 0/0 -> NaN at zero vectors
    u = u .* ratio;                              % keep direction, change length only
    v = v .* ratio;
end

% Decimate once, so the flat and magnitude paths below share one set of arrays.
if vecskip==1
    typevector_reduced = typevector;
    x_reduced = x;
    y_reduced = y;
    u_reduced = u;
    v_reduced = v;
    magnitude_reduced = magnitude_true;
else
    typevector_reduced=typevector(1:vecskip:end,1:vecskip:end);
    x_reduced=x(1:vecskip:end,1:vecskip:end);
    y_reduced=y(1:vecskip:end,1:vecskip:end);
    u_reduced=u(1:vecskip:end,1:vecskip:end);
    v_reduced=v(1:vecskip:end,1:vecskip:end);
    if magnitude_mode
        magnitude_reduced = magnitude_true(1:vecskip:end,1:vecskip:end);
    else
        magnitude_reduced = [];
    end
end

subtr_u_px = gui.retr('subtr_u')/gui.retr('calu');
subtr_v_px = gui.retr('subtr_v')/gui.retr('calv');
vecwidth   = str2double(get(handles.vecwidth,'string'));

if magnitude_mode
    % All displayed vectors (valid, 2nd peak and interpolated) are colored by
    % magnitude, so they are drawn in a single pass: one sort/bin over the
    % whole field and one set of line objects, which is cheaper than three.
    show = typevector_reduced>0;
    cmap  = plot.vector_colormap(handles, 64, nnz(show));
    clims = magnitude_limits(magnitude_reduced(show));
    q = plot.quiverc(target_axis, ...
        x_reduced(show), y_reduced(show), ...
        (u_reduced(show)-subtr_u_px)*vecscale, ...
        (v_reduced(show)-subtr_v_px)*vecscale, ...
        magnitude_reduced(show), cmap, clims, vecwidth);
    % gui.sliderdisp attaches the same callback to both outputs; SET is
    % vectorized over handle arrays and a no-op on an empty one.
    q2 = gobjects(0);
    update_magnitude_colorbar(target_axis, handles, cmap, clims);
else
    delete(findobj(ancestor(target_axis,'figure'),'Tag','magnitude_colorbar'));
    q=quiver(x_reduced(typevector_reduced==1),y_reduced(typevector_reduced==1),...
        (u_reduced(typevector_reduced==1)-subtr_u_px)*vecscale,...
        (v_reduced(typevector_reduced==1)-subtr_v_px)*vecscale,...
        'Color', vectorcolor,'autoscale', 'off','linewidth',vecwidth,'parent',target_axis,'Clipping','on');%,'Alignment','center');
    q2=quiver(x_reduced(typevector_reduced==2),y_reduced(typevector_reduced==2),...
        (u_reduced(typevector_reduced==2)-subtr_u_px)*vecscale,...
        (v_reduced(typevector_reduced==2)-subtr_v_px)*vecscale,...
        'Color', vectorcolorintp,'autoscale', 'off','linewidth',vecwidth,'parent',target_axis,'Clipping','on');%,'Alignment','center');
    quiver(x_reduced(typevector_reduced==3),y_reduced(typevector_reduced==3),...
        (u_reduced(typevector_reduced==3)-subtr_u_px)*vecscale,...
        (v_reduced(typevector_reduced==3)-subtr_v_px)*vecscale,...
        'Color', vectorcolor2ndpeak,'autoscale', 'off','linewidth',vecwidth,'parent',target_axis,'Clipping','on');
end
if str2num(get(handles.masktransp,'String')) < 100
    scatter(x_reduced(typevector_reduced==0),y_reduced(typevector_reduced==0),'rx','parent',target_axis) %masked
end

% reference vector display
ref_choices=get(handles.ref_vect_pos,'String');
ref_choice=get(handles.ref_vect_pos,'Value');

if ref_choice ~=1
    ref_position = ref_choices(ref_choice);
    plot.reference_vector(x,y,vecscale,target_axis,ref_position);
end
hold(target_axis,'off');
target_axis.Clipping = "on";
end

% -------------------------------------------------------------------------
function clims = magnitude_limits(mag)
%MAGNITUDE_LIMITS Color limits for the magnitude scale, robust to empty/flat data.
mag = mag(isfinite(mag));
if isempty(mag)
    clims = [0 1];
    return
end
clims = [min(mag) max(mag)];
if clims(2) <= clims(1)
    clims = clims(1) + [0 max(abs(clims(1))*0.01, eps)];
end
end

% -------------------------------------------------------------------------
function update_magnitude_colorbar(target_axis, handles, cmap, clims)
%UPDATE_MAGNITUDE_COLORBAR Colorbar describing the vector magnitude scale.
%
%   Magnitude coloring is only reachable when no derived scalar is displayed
%   (gui.sliderdisp picks deriv_color in that case), so nothing else is using
%   the axes colormap here: the particle image and the mask are both drawn as
%   truecolor RGB and ignore it. That makes it safe to point the axes
%   colormap and CLim at the vector scale and let a normal colorbar read it.
parentfig = ancestor(target_axis,'figure');
delete(findobj(parentfig,'Tag','magnitude_colorbar'));
if get(handles.colorbarpos,'value')==1 % "None"
    return
end

colormap(target_axis, cmap);
set(target_axis,'CLim',clims); % property assignment, not clim(): works on old releases too

posichoice = get(handles.colorbarpos,'String');
position   = posichoice{get(handles.colorbarpos,'Value')};
coloobj = colorbar(position,'Fontsize',12,'HitTest','off','parent',parentfig,'Tag','magnitude_colorbar');

if (gui.retr('calu')==1 || gui.retr('calu')==-1) && gui.retr('calxy')==1 % not calibrated
    label = 'Velocity magnitude in px/frame';
else
    displacement_only = gui.retr('displacement_only');
    if ~isempty(displacement_only) && displacement_only == 1
        label = 'Velocity magnitude in m/frame';
    else
        label = 'Velocity magnitude in m/s';
    end
end
if strcmp(position,'EastOutside') || strcmp(position,'WestOutside')
    ylabel(coloobj,label,'fontsize',12,'fontweight','bold');
else
    xlabel(coloobj,label,'fontsize',12,'fontweight','bold');
end

% Match the tick formatting of the scalar colorbar.
switch get(handles.colorbarnumberformat,'Value')
    case 2
        fmt = '%0.3e';
    case 3
        fmt = '%0.3f';
    otherwise
        fmt = '%0.3g';
end
ticks = linspace(clims(1), clims(2), min(size(cmap,1),8)+1);
coloobj.Ticks      = ticks;
coloobj.TickLabels = num2str(ticks(:), fmt);
end
