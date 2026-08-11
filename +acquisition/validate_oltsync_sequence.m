function [ok, msg] = validate_oltsync_sequence(frame_time, pin_string)
%VALIDATE_OLTSYNC_SEQUENCE Check an oltSync sequence against the firmware rules.
%   [ok, msg] = validate_oltsync_sequence(frame_time, pin_string) mirrors the
%   PIVlab-SimpleSync firmware ParseSequence() checks so an invalid sequence can
%   be caught locally (with a clear message) instead of relying on the device's
%   round-trip 'Sequence:Error' reply.
%
%   pin_string is colon-separated pins, each a comma-separated list of integer
%   microsecond edge times, e.g. '0,500:100,200,300,400'. pin1 = camera,
%   pin2 = laser. An empty pin (e.g. ':10,11') is allowed as long as at least
%   one pin carries edges.
%
%   A sequence is accepted iff:
%     - frame_time is non-zero
%     - at least one pin has edges
%     - each pin has an even number of edges (0 counts as even)
%     - edge times strictly increase within a pin (every pulse/gap >= 1 us)
%     - the largest edge time of each pin does not exceed frame_time
%     - the assembled sequence string is at least 15 characters long

ok = false;

if isempty(frame_time) || frame_time == 0
	msg = 'Frame time is zero.';
	return
end

pins = strsplit(pin_string, ':', 'CollapseDelimiters', false);
any_entries = false;
for p = 1:numel(pins)
	pin = strtrim(pins{p});
	if isempty(pin)
		times = [];
	else
		parts = strsplit(pin, ',');
		times = zeros(1, numel(parts));
		for k = 1:numel(parts)
			v = str2double(parts{k});
			if isnan(v)
				msg = sprintf('Pin %d contains a non-numeric value.', p);
				return
			end
			times(k) = v;
		end
	end

	% each pin must have an even number of edges (0 is even)
	if mod(numel(times), 2) ~= 0
		msg = sprintf('Pin %d has an odd number of edges.', p);
		return
	end

	if ~isempty(times)
		any_entries = true;
		% edge times must strictly increase -> every pulse and gap is >= 1 us
		if any(diff(times) < 1)
			msg = sprintf('Pin %d: pulse or gap shorter than 1 us (edge times must strictly increase).', p);
			return
		end
		% the largest edge time must not exceed the frame period
		if max(times) > frame_time
			msg = sprintf('Pin %d: pulse extends beyond the frame period (%d us).', p, frame_time);
			return
		end
	end
end

if ~any_entries
	msg = 'No pulses defined on any pin.';
	return
end

seq = ['sequence:' int2str(frame_time) ':0,0:' pin_string];
if numel(seq) < 15
	msg = 'Sequence string is too short.';
	return
end

ok = true;
msg = '';
