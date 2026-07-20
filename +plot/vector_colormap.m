function cmap = vector_colormap(handles, maxLevels, nVectors)
%VECTOR_COLORMAP Colormap for magnitude-colored vectors, as N-by-3 RGB.
%
%   CMAP = PLOT.VECTOR_COLORMAP(HANDLES, MAXLEVELS) returns the colormap
%   currently selected in handles.colormap_choice, resampled to the number of
%   steps selected in handles.colormap_steps but capped at MAXLEVELS rows.
%
%   CMAP = PLOT.VECTOR_COLORMAP(HANDLES, MAXLEVELS, NVECTORS) additionally
%   scales the level count down for small fields.
%
%   The cap matters for speed: plot.quiverc draws one line object per color
%   level and each level costs a roughly fixed amount of time, so the 256-step
%   setting would add about a quarter of a second per redraw. 64 levels is
%   visually indistinguishable from a continuous ramp and keeps the draw time
%   at parity with a plain QUIVER.
%
%   The NVECTORS taper exists because that per-level cost is fixed while the
%   render cost scales with the vector count: on a large field the levels
%   disappear into the render, but on a small one 64 line objects are pure
%   overhead. A field of a few thousand vectors cannot resolve 64 distinct
%   magnitude bands anyway, so fewer levels costs nothing visually.
%
%   Unlike the colormap block in plot.draw_pixel_background_overlay, this
%   function has no side effects: it does not set the figure or axes
%   colormap, because the magnitude colors are baked into the line objects.
%
%   See also PLOT.QUIVERC, PLOT.VECTORS.

if nargin < 2 || isempty(maxLevels)
	maxLevels = 64;
end

avail_maps     = get(handles.colormap_choice,'string');
selected_index = get(handles.colormap_choice,'value');
if selected_index < 1 || selected_index > numel(avail_maps)
	selected_index = 1;
end
map_name = lower(avail_maps{selected_index});

% The three custom maps ship as .mat files next to this function. Locate them
% relative to this file rather than the current folder, so the lookup does not
% depend on the working directory.
here = fileparts(mfilename('fullpath'));

cmap = [];
switch map_name
	case 'parula'
		cmap = load_parula(fullfile(here,'parula.mat'));
	case 'hsb'
		cmap = load_hsb(fullfile(here,'hsbmap.mat'));
	case 'plasma'
		cmap = load_plasma(fullfile(here,'plasma.mat'));
	case 'hsv'
		cmap = hsv(256);
	case 'jet'
		cmap = jet(256);
	case 'hot'
		cmap = hot(256);
	case 'cool'
		cmap = cool(256);
	case 'spring'
		cmap = spring(256);
	case 'summer'
		cmap = summer(256);
	case 'autumn'
		cmap = autumn(256);
	case 'winter'
		cmap = winter(256);
	case 'gray'
		cmap = gray(256);
	case 'bone'
		cmap = bone(256);
	case 'copper'
		cmap = copper(256);
	case 'pink'
		cmap = pink(256);
	case 'lines'
		cmap = lines(256);
end
if isempty(cmap)
	cmap = parula(256);
end

% Number of levels: the user's colormap_steps setting, capped for speed.
steps_list  = get(handles.colormap_steps,'String');
steps_value = get(handles.colormap_steps,'Value');
nLevels     = str2double(steps_list{steps_value});
if ~isfinite(nLevels) || nLevels < 2
	nLevels = 64;
end
nLevels = min(nLevels, maxLevels);
if nargin >= 3 && ~isempty(nVectors) && nVectors > 0
	nLevels = min(nLevels, max(16, round(nVectors/300)));
end

if size(cmap,1) ~= nLevels
	cmap = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), nLevels));
end
cmap = min(1, max(0, cmap));
end

% -------------------------------------------------------------------------
function cmap = load_parula(matfile)
cmap = [];
try
	s = load(matfile,'parula');
	cmap = s.parula;
catch
	disp(['parula.mat not found in ' matfile])
end
end

function cmap = load_hsb(matfile)
cmap = [];
try
	s = load(matfile,'hsb');
	cmap = s.hsb;
catch
	disp(['hsbmap.mat not found in ' matfile])
end
end

function cmap = load_plasma(matfile)
cmap = [];
try
	s = load(matfile,'plasma');
	cmap = s.plasma;
catch
	disp(['plasma.mat not found in ' matfile])
end
end
