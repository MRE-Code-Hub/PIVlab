% test_validate_oltsync_sequence.m
% Standalone tests (no GUI, no hardware) for the oltSync sequence validator
% acquisition.validate_oltsync_sequence, which mirrors the PIVlab-SimpleSync
% firmware ParseSequence() acceptance rules, and for the fixed low energy
% string produced by acquisition.low_energy_sequence.
%
% Run with:
%   cd <PIVlab repo root>
%   run('unittests/test_validate_oltsync_sequence.m')

clc; clear; close all;

project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(project_root);

n_passed = 0;
n_failed = 0;

fprintf('=== test_validate_oltsync_sequence ===\n\n');

% ── The fixed low energy string must be well formed and pass ──────────────
[le_frame_time, le_pin_string] = acquisition.low_energy_sequence();
if le_frame_time == 20000 && strcmp(le_pin_string, ':10,11')
	fprintf('[PASS] low_energy_sequence returns 20000 us / '':10,11''\n');
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] low_energy_sequence returned %g / ''%s''\n', le_frame_time, le_pin_string);
	n_failed = n_failed + 1;
end

% ── Valid sequences (expect ok == true) ───────────────────────────────────
[n_passed, n_failed] = check('low energy laser-only string', true, ...
	le_frame_time, le_pin_string, n_passed, n_failed);
[n_passed, n_failed] = check('normal camera+laser sequence', true, ...
	40000, '0,500:100,200,300,400', n_passed, n_failed);
[n_passed, n_failed] = check('empty camera pin, valid laser pin', true, ...
	20000, ':10,11', n_passed, n_failed);

% ── Invalid sequences (expect ok == false) ────────────────────────────────
[n_passed, n_failed] = check('frame time zero', false, ...
	0, ':10,11', n_passed, n_failed);
[n_passed, n_failed] = check('odd number of edges on a pin', false, ...
	40000, '0,500,700:100,200', n_passed, n_failed);
[n_passed, n_failed] = check('equal edges (sub-1us pulse)', false, ...
	20000, ':10,10', n_passed, n_failed);
[n_passed, n_failed] = check('decreasing edges', false, ...
	20000, ':11,10', n_passed, n_failed);
[n_passed, n_failed] = check('edge time exceeds frame time', false, ...
	20000, ':0,25000', n_passed, n_failed);
[n_passed, n_failed] = check('both pins empty', false, ...
	20000, ':', n_passed, n_failed);
[n_passed, n_failed] = check('non-numeric edge', false, ...
	20000, ':0,abc', n_passed, n_failed);

% ── Summary ────────────────────────────────────────────────────────────────
fprintf('\n--- Summary: %d passed, %d failed ---\n', n_passed, n_failed);
if n_failed > 0
	error('test_validate_oltsync_sequence: %d test(s) FAILED', n_failed);
end

% ── Helper ─────────────────────────────────────────────────────────────────
function [n_passed, n_failed] = check(desc, expected_ok, frame_time, pin_string, n_passed, n_failed)
[ok, msg] = acquisition.validate_oltsync_sequence(frame_time, pin_string);
if ok == expected_ok
	fprintf('[PASS] %s (ok=%d)\n', desc, ok);
	n_passed = n_passed + 1;
else
	fprintf('[FAIL] %s: expected ok=%d, got ok=%d (msg: %s)\n', desc, expected_ok, ok, msg);
	n_failed = n_failed + 1;
end
end
