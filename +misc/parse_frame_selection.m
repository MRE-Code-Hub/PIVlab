function [frames_rows, str_rows, ok] = parse_frame_selection(str, num_frames)
% Parse a frame-selection string into numeric frame vectors.
%   str        - e.g. '1:end', '1,4,7,10:15', '3-9', or multi-row
%                '[1:10:end;2:10:end]'
%   num_frames - the value that 'end' resolves to (caller-defined)
% Returns:
%   frames_rows - 1xR cell, one numeric row vector per ';'-separated row
%   str_rows    - 1xR cell of the matching cleaned strings ('-'->':', 'end'
%                 substituted, brackets removed) for use in eval-based indexing
%   ok          - true only if every row parsed to a valid integer selection
str = strrep(str,'-',':');
if ~isempty(strfind(str,'end'))              %#ok<STREMP>
	str = strrep(str,'end',num2str(num_frames));
end
str_clean = strrep(strrep(str,'[',''),']','');
str_rows  = strtrim(strsplit(str_clean, ';'));
str_rows  = str_rows(~cellfun(@isempty, str_rows));
frames_rows = cell(1, numel(str_rows));
ok = ~isempty(str_rows);
for r = 1:numel(str_rows)
	v = str2num(str_rows{r}); %#ok<ST2NM>
	if isempty(v) || ~isempty(strfind(str_rows{r},'.'))   % empty or decimals -> invalid
		ok = false; break
	end
	frames_rows{r} = v;
end
