function h = quiverc(target_axis, x, y, u, v, cdata, cmap, clims, linewidth)
%QUIVERC Draw arrows colored by a scalar, at close to plain QUIVER speed.
%
%   H = PLOT.QUIVERC(TARGET_AXIS, X, Y, U, V, CDATA, CMAP, CLIMS, LINEWIDTH)
%   draws one arrow per element of X/Y/U/V and colors it according to CDATA,
%   mapped through the CMAP rows over the range CLIMS = [lo hi].
%
%   X, Y, U, V and CDATA are column vectors of equal length. U and V must
%   already be scaled for display (this function never autoscales), exactly
%   like the 'autoscale','off' QUIVER calls elsewhere in PIVlab.
%
%   H is an array of LINE handles, one per occupied color level, each tagged
%   'pivlab_vector'. An array is returned rather than a single grouped object
%   so that SET(H,'ButtonDownFcn',...) in gui.sliderdisp keeps working.
%
%   Performance
%     Arrows are quantized into SIZE(CMAP,1) color levels and each level is
%     drawn as ONE line object holding all of its arrows as NaN-separated
%     segments. Cost is driven by the number of line objects, not the number
%     of vectors, so a 400x400 field costs roughly what a plain QUIVER costs.
%     Each additional color level adds about 1 ms, which is why the caller
%     caps the level count (see plot.vector_colormap).
%
%   Unlike a normal colored-quiver the axes CLim is deliberately NOT set
%   here: PIVlab's scalar overlay owns the figure/axes colormap and maps its
%   data by hand with 'cdatamapping','direct'. Colors are baked into the line
%   objects instead, and the caller is responsible for any colorbar.
%
%   See also PLOT.VECTORS, PLOT.VECTOR_COLORMAP, QUIVER.

% Arrow head geometry, tuned to match QUIVER's appearance.
headSize  = 0.33;   % head length as a fraction of the arrow length
headAngle = 22.5;   % half opening angle of the head, in degrees

x = double(x(:));  y = double(y(:));
u = double(u(:));  v = double(v(:));
cdata = double(cdata(:));

% Drop anything that cannot be drawn or colored.
ok = isfinite(x) & isfinite(y) & isfinite(u) & isfinite(v) & isfinite(cdata);
if ~all(ok)
	x = x(ok); y = y(ok); u = u(ok); v = v(ok); cdata = cdata(ok);
end

h = gobjects(0);
n = numel(x);
if n == 0
	return
end

nLevels = size(cmap,1);

% ---- arrow vertices -----------------------------------------------------
xTip = x + u;
yTip = y + v;

ca = cosd(headAngle);  sa = sind(headAngle);
hu = headSize * u;     hv = headSize * v;

xL = xTip - (ca*hu - sa*hv);   yL = yTip - ( sa*hu + ca*hv);
xR = xTip - (ca*hu + sa*hv);   yR = yTip - (-sa*hu + ca*hv);

% Shaft, then head as barb-tip-barb, then NaN to terminate this arrow.
sep = nan(n,1);
VX = [x xTip xL xTip xR sep].';
VY = [y yTip yL yTip yR sep].';

% ---- quantize the color data into levels --------------------------------
lo = clims(1);
hi = clims(2);
if ~isfinite(lo) || ~isfinite(hi) || hi <= lo
	hi = lo + 1;
end
bin = floor((cdata - lo) / (hi - lo) * nLevels) + 1;
bin = min(nLevels, max(1, bin));

% Sorting once makes every level a contiguous block of columns, so each
% line's data is a single reshape with no per-arrow indexing.
[binSorted, ord] = sort(bin);
VX = VX(:,ord);
VY = VY(:,ord);
stop  = cumsum(accumarray(binSorted, 1, [nLevels 1]));
start = [1; stop(1:end-1)+1];

% ---- one line per occupied level ----------------------------------------
h = gobjects(1, nLevels);
used = false(1, nLevels);
for b = 1:nLevels
	if stop(b) < start(b)
		continue
	end
	h(b) = line(target_axis, ...
		'XData', reshape(VX(:,start(b):stop(b)), [], 1), ...
		'YData', reshape(VY(:,start(b):stop(b)), [], 1), ...
		'Color', cmap(b,:), ...
		'LineWidth', linewidth, ...
		'Clipping', 'on', ...
		'Tag', 'pivlab_vector');
	used(b) = true;
end
h = h(used);
