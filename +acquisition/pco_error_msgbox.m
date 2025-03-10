function pco_error_msgbox
filepath = fileparts(which('PIVlab_GUI.m'));
%uiwait(msgbox(['PCO camera drivers not found in this directory:' sprintf('\n') fullfile(filepath, 'PIVlab_capture_resources\PCO_resources') sprintf('\n\n') 'The free pco toolbox for Matlab can be downloaded here:' sprintf('\n') 'https://www.pco.de/de/software/third-party/matlab/' sprintf('\n\n') 'Please download and install this toolbox to use your pco camera in PIVlab.'],'modal'))
uiwait(msgbox(['pco.matlab extension not found.' newline  'You need to install pco.matlab, and then add that folder to the Matlab search path permanently.' newline newline 'Please follow the instructions in the wiki on github: ' newline newline 'https://github.com/Shrediquette/PIVlab/wiki/Setup-pco-cameras'],'modal'))

