%% Template Matlab script to create an BIDS compatible dataset_description.json file
% This example lists all required and optional fields.
% When adding additional metadata please use CamelCase 
%
% DHermes, 2017
% modified RG 201809

%%
clear
root_dir = '.';
project_label = 'templates';
json_label = 'dataset_description';


dataset_description_json_name = fullfile(root_dir,project_label,...
    'dataset_description.json');

%%  Required fields:

dd_json.Name = 'FeatAttnDec'; % name of the dataset

dd_json.BIDSVersion = '1.0.2'; % The version of the BIDS standard that was used

%%  Recommended fields:

dd_json.License = '';% what license is this dataset distributed under? The 
% use of license name abbreviations is suggested for specifying a license. 
% A list of common licenses with suggested abbreviations can be found in appendix III.

dd_json.Authors = {'Angela I. Renton','David R. Painter','Jason B. Mattingley'};% List of individuals who contributed to the 
% creation/curation of the dataset

dd_json.Acknowledgements = ''; % who should be acknowledged in helping to collect the data

dd_json.HowToAcknowledge = ''; % Instructions how researchers using this 
% dataset should acknowledge the original authors. This field can also be used 
% to define a publication that should be cited in publications that use the
% dataset.

dd_json.Funding = {'','',''}; % sources of funding (grant numbers)

dd_json.ReferencesAndLinks = {'','',''};% a list of references to 
% publication that contain information on the dataset, or links.

dd_json.DatasetDOI = ''; %the Document Object Identifier of the dataset 
% (not the corresponding paper).



%% Write JSON

json_options.indent = '    '; % this just makes the json file look prettier 
% when opened in a text editor

jsonSaveDir = fileparts(dataset_description_json_name);
if ~isdir(jsonSaveDir)
    fprintf('Warning: directory to save json file does not exist: %s \n',jsonSaveDir)
end

jsonwrite(dataset_description_json_name,dd_json,json_options)
