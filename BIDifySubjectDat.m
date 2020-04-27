clear
clc
close all

%% Notes
% Dependencies
% Fieldtrip toolbox - Web:
% JSONio: Web: https://github.com/gllmflndn/JSONio

%% To do:
% add task description and instructions to eeg.json. 
% update status and status description in channels.tsv

%% directories

direct.fieldtrip = 'E:\toolboxes\fieldtrip-20170220\';
direct.json = 'E:\angie\toolboxes\JSONio-master\';
direct.data = 'E:\angie\RTAttnSelectMethods\data\';

addpath(genpath(direct.fieldtrip))
addpath(genpath(direct.json))

%% metadata

sub = 32; % subject number 
bids.taskname = 'FeatAttnDec'; % Unique name of task for saving

if sub <10
    bids.substring = ['sub-0' num2str(sub)];
else
    bids.substring = ['sub-' num2str(sub)];
end

%% BIDS data filename and directory info

direct.data_bids = [direct.data 'BIDS\' bids.substring '\eeg\']; 
mkdir(direct.data_bids);

filename.bids.EEG = [bids.substring '_task-' bids.taskname '_eeg'];
filename.bids.CHAN = [bids.substring '_task-' bids.taskname '_channels'];
filename.bids.EVT = [bids.substring '_task-' bids.taskname '_events'];
filename.bids.BEHAV = [bids.substring '_task-' bids.taskname '_behav'];

%% Step 1 - reorganise origional data into BIDS "sourcedata" folder

direct.data_origeeg = [direct.data 'ORIG\EEG_mat\'];
direct.data_origbehav = [direct.data 'ORIG\BEHAVE\'];

direct.data_sourceeeg =  [direct.data 'BIDS\sourcedata\' bids.substring '\eeg\']; mkdir(direct.data_sourceeeg);
direct.data_sourcebehav =  [direct.data 'BIDS\sourcedata\' bids.substring '\behave\']; mkdir(direct.data_sourcebehav);

% Move EEG data
FNAME = dir([direct.data_origeeg 'S' num2str(sub) '.*EEG_DATA*.mat']);
copyfile([direct.data_origeeg FNAME(1).name],[direct.data_sourceeeg filename.bids.EEG '.mat']);

% Move Behave data
FNAME = dir([direct.data_origbehav 'S' num2str(sub) '.*.mat']);
copyfile([direct.data_origbehav  FNAME(1).name],[direct.data_sourcebehav filename.bids.BEHAV '.mat']);

%% Load EEG
load([direct.data_sourceeeg filename.bids.EEG '.mat'], 'DATA2', 'fs', 'trigChan')

%% Create Header and dataStruct 
% this data was saved in a matlab file format. This next section switched is to the brainvision format (.eeg).

dataStruct.hdr.Fs = fs; % sampling frequency
dataStruct.hdr.nChans = trigChan; % number of EEG channels 
dataStruct.hdr.label = {'Iz' 'Oz' 'POz' 'O1' 'O2' 'TRIG'}; % channel labels (I only recorded 5 channels here)
dataStruct.hdr.chantype = {'EEG' 'EEG' 'EEG' 'EEG' 'EEG' 'TRIG'}; % channel types
dataStruct.hdr.nSamples = length(DATA2); % data length
dataStruct.hdr.nSamplesPre = 0; 
dataStruct.hdr.nTrials = 1; 
dataStruct.hdr.chanunit = repmat({'uV'},dataStruct.hdr.nChans,1);

dataStruct.label = dataStruct.hdr.label; 
dataStruct.time{1} = [1:dataStruct.hdr.nSamples]/dataStruct.hdr.Fs; % duration of file
dataStruct.trial{1} = DATA2'; % 
dataStruct.fsample = dataStruct.hdr.Fs; 
dataStruct.sampleinfo = [1 dataStruct.hdr.nSamples];

% now fetch a header
hdr_data = ft_fetch_header(dataStruct);

%% write brain vision file
ft_write_data([direct.data_bids filename.bids.EEG '.eeg' ], DATA2', 'header', hdr_data, 'dataformat', 'brainvision_eeg')

%% Preview new data
% define trials
cfg            = [];
cfg.dataset    = [direct.data_bids filename.bids.EEG '.eeg'];
cfg.continuous = 'yes';
cfg.channel    = 'all';
data           = ft_preprocessing(cfg);

cfg            = [];
cfg.viewmode   = 'vertical';


% view data - make sure it looks normal
ft_databrowser(cfg, data);
input('enter')


%%  ######################## Subject specific EEG Quality fields to be ported to the sections later: ######################## 
switch sub
    case 4
        tmpChanInfo.SubjectArtefactDescription = 'Data quality decreases toward end or recording - particularly in Iz. Should still be usable.';
        tmpChanInfo.badchans = []; % Indices of bad channels which should be excluded or interpolated.
        tmpChanInfo.badchans_description = {}; % Freeform text description of noise or artifact affecting data quality on the bad channels.
    
    case 7
        tmpChanInfo.SubjectArtefactDescription = 'Ear reference became detached during recording - data could not be saved'; 
        tmpChanInfo.badchans = [1 2 3 4 5];
        tmpChanInfo.badchans_description = {'Lost Reference' 'Lost Reference' 'Lost Reference' 'LostReference' 'Lost Reference'}; 
    
    case 15
        tmpChanInfo.SubjectArtefactDescription = 'Channel O1 became excessively noisy half way through the recording. Unclear why - possible the subject bent the electrode cable? ';
        tmpChanInfo.badchans = [4];
        tmpChanInfo.badchans_description = {'Excessive noise from about halfway through recording'}; 
     
    case 18
        tmpChanInfo.SubjectArtefactDescription = 'Lots of low frequency noise in Iz';
        tmpChanInfo.badchans = [];
        tmpChanInfo.badchans_description = {}; 
    
    case 19
        tmpChanInfo.SubjectArtefactDescription = 'Regular artifact is really strongly evident - data could not be saved';
        tmpChanInfo.badchans = [1 2 3 4 5];
        tmpChanInfo.badchans_description = {'artifact' 'artifact' 'artifact' 'artifact' 'artifact'}; 
        
    case 20
        tmpChanInfo.SubjectArtefactDescription = 'So MUCH Alpha!! - If poor decoding, could be attributed to sleepiness';
        tmpChanInfo.badchans = [];
        tmpChanInfo.badchans_description = {};
    
    case 21
        tmpChanInfo.SubjectArtefactDescription = 'Periodic noise in O1';
        tmpChanInfo.badchans = [4];
        tmpChanInfo.badchans_description = {'Periodically very noisy'}; 
        
    case 23
        tmpChanInfo.SubjectArtefactDescription = 'Periodic noise throughout - especially in Iz, probably still useable though';
        tmpChanInfo.badchans = [];
        tmpChanInfo.badchans_description = {}; 
        
    otherwise
        tmpChanInfo.SubjectArtefactDescription = 'Strange Regular artifact across most recordings in dataset - visually looks to be at about 0.5Hz, but resistant to filtering. Suspect this is some sort of electrical artifact in the room - testing was not perfomed in a farraday cage. Should not effect FFT based anayses'; %Freeform description of the observed subject artefact and its possible cause
        tmpChanInfo.badchans = []; % Indices of bad channels which should be excluded or interpolated.
        tmpChanInfo.badchans_description = {}; % Freeform text description of noise or artifact affecting data quality on the bad channels.
end


%% ######################## create BIDS eeg.json ######################
% This example lists all required and optional fields.
% When adding additional metadata please use CamelCase

% ####------------ Subject Specific ------------####

eeg_json.SubjectArtefactDescription = tmpChanInfo.SubjectArtefactDescription ; % Freeform description of the observed 
% subject artefact and its possible cause (e.g. door open, nurse walked into room at 2 min, 
% "Vagus Nerve Stimulator", non-removable implant, seizure at 10 min). 
% If this field is left empty, it will be interpreted as absence of artifacts.


% ####------------ Experiment Specific ------------####
% ---- Required fields: ----

eeg_json.TaskName = 'bids.taskname'; 
eeg_json.SamplingFrequency = num2str(hdr_data.Fs); 
eeg_json.PowerLineFrequency = '50'; 
eeg_json.SoftwareFilters = {'n/a'}; %  List of temporal software filters applied. (n/a if none). E.g., “{'HighPass': {'HalfAmplitudeCutOffHz': 1, 'RollOff: '6dB/Octave'}}”.
eeg_json.DCOffsetCorrection = ''; % A description of the method (if any) used to correct for a DC offset.If the method used was subtracting the mean value for each channel, use “mean”.
eeg_json.EEGReference = 'ear'; 
eeg_json.EEGGround = 'Cz'; 

% ---- Recommended fields: ---- 

HardwareFilters.HighpassFilter.CutoffFrequency = ['1'];
HardwareFilters.LowpassFilter.CutoffFrequency = ['100'];
eeg_json.HardwareFilters = HardwareFilters; % Cutoff frequencies of high and low pass filter are stored in this variable automatically. No further input necessary. 

eeg_json.Manufacturer = 'g.tec'; % Manufacturer of the amplifier system  (e.g. "TDT, blackrock")
eeg_json.ManufacturersModelName = 'g.USBamp'; % Manufacturer's designation of the EEG amplifier model (e.g. "TDT"). 
eeg_json.SoftwareVersions = 'g.tec API functions running in MATLAB 2017a'; % Manufacturer's designation of the acquisition software.
eeg_json.InstitutionName = 'Queensland Brain Institute, The University of Queensland'; %  The name of the institution in charge of the equipment that produced the composite instances.
eeg_json.InstitutionAddress = 'Building 79, The University of Queensland, St Lucia, Australia, 4072'; % The address of the institution in charge of the equipment that produced the composite instances. 

eeg_json.EEGChannelCount = num2str(dataStruct.hdr.nChans-1); % Number of scalp EEG channels recorded simultaneously (e.g., 21)
eeg_json.TriggerChannelCount = '1'; % Number of channels for digital (TTL bit level) triggers. 
eeg_json.RecordingDuration = num2str(dataStruct.time{1}(end)); % Length of the recording in seconds (e.g. 3600)
eeg_json.RecordingType = 'continuous'; % Defines whether the recording is “continuous” or “epoched”; this latter 
% limited to time windows about events of interest (e.g., stimulus presentations, subject responses etc.)

eeg_json.TaskDescription = 'We set out to collect an EEG dataset to use to train various machine learning algorithms to detect the focus of feature-selective attention. Subjects were cued to attend to attend to either black or white moving dots, and respond to brief periods of coherent motion in the cued colour. The display consisted of either both black and white dots, or only the cued colour in randomly interleaved trials. The field of moving dots in the uncued colour never moved coherently, and should thus not have captured attention. The fields of dots flickered at 6 and 7.5 Hz. Colour and frequency were fully counterbalanced. Each trial consisted of a 1 second cue followed by 15 s of the dot motion stimulus. '; % Longer description of the task.

eeg_json.Instructions = 'Participants were informed of the purpose of the study, and instructed to press the arrow keys corresponding to the direction of any epoch of coherent motion they saw in the cued colour.'; % Text of the instructions given to participants before the recording. This is especially important in context of resting 
% state and distinguishing between eyes open and eyes closed paradigms. 

% NB removed some fields like cognitive atlas and stimulation parameters
% that aren't relevant to me. Check official BIDS template if you aren't
% Angie or you're doing something diffrent. 

% ---- write -----
json_options.indent = '    '; % this just makes the json file look prettier % when opened in a text editor

jsonwrite([direct.data_bids filename.bids.EEG '.json' ],eeg_json,json_options)
% json = jsonread([direct.data_bids filename.bids.EEG_json ])

%% ######################## create BIDS electrodes.tsv ######################

% ---- Required fields: ----
name = dataStruct.hdr.label'; % Label of the channel, only contains letters and numbers. The label must 
% correspond to _electrodes.tsv name and all eeg type channels are required to have \
% a position. The reference channel name MUST be provided in the reference column

type = dataStruct.hdr.chantype'; % Type of channel, see below for adequate keywords in this field 

units = dataStruct.hdr.chanunit; % Physical unit of the value represented in this channel, e.g., V for Volt, 
% specified according to the SI unit symbol and possibly prefix symbol (e.g., mV, ?V), 
% see the BIDS spec (section 15 Appendix V: Units) for guidelines for Units and Prefixes.

low_cutoff = repmat(HardwareFilters.LowpassFilter.CutoffFrequency, dataStruct.hdr.nChans,1) ; %Frequencies used for the low pass filter applied to the 
% channel in Hz. If no low pass filter was applied, use n/a. Note that 
% anti-alias is a low pass filter, specify its frequencies here if applicable.

high_cutoff = repmat(HardwareFilters.HighpassFilter.CutoffFrequency, dataStruct.hdr.nChans,1) ; % Frequencies used for the high pass filter applied to 
% the channel in Hz. If no high pass filter applied, use n/a.

% ---- Reccomended fields: ----

reference = {'ear' 'ear' 'ear' 'ear' 'ear' 'n/a'}'; % Specification of the reference (e.g., ‘mastoid’, ’ElectrodeName01’,
% ‘intracranial’, ’CAR’, ’other’, ‘n/a’). If the channel is not an electrode channel 
% (e.g., a microphone channel) use `n/a`.

group = {'1' '1' '1' '1' '1' 'n/a'}'; % Which group of channels (grid/strip/probe) this channel belongs to. 
% One group has one wire and noise can be shared. This can be a name or number.
% Note that any groups specified in `_electrodes.tsv` must match those present here.

% ---- Optional fields: ----
 
sampling_frequency = repmat([dataStruct.hdr.Fs], dataStruct.hdr.nChans,1);% Sampling rate of the channel in Hz.

description = repmat({'n/a'}, dataStruct.hdr.nChans,1); % Brief free-text description of the channel, or other information of 
% interest (e.g. position (e.g., 'left lateral temporal surface', 'unipolar/bipolar', etc.)).

notch = repmat(50, dataStruct.hdr.nChans,1); % Frequencies used for the notch filter applied to the channel, 
% in Hz. If no notch filter applied, use n/a. 

status = repmat({'good'}, dataStruct.hdr.nChans,1); % Data quality observed on the channel (good/bad). A channel is considered bad 
% if its data quality is compromised by excessive noise. Description of noise type SHOULD be 
% provided in [status_description].

status_description = repmat({'n/a'}, dataStruct.hdr.nChans,1); % Freeform text description of noise or artifact affecting data 
% quality on the channel. It is meant to explain why the channel was declared bad in [status].

% Update channel status for each subject
for ii = 1:length(tmpChanInfo.badchans)
   status{tmpChanInfo.badchans(ii)} = 'bad';
   status_description{tmpChanInfo.badchans(ii)} = tmpChanInfo.badchans_description{ii};
end

% ---- WRITE: ----
t = table(name,type,units,low_cutoff,high_cutoff,reference,...
    group,sampling_frequency,description,notch,status,status_description);

writetable(t,[direct.data_bids filename.bids.CHAN '.tsv' ],'FileType','text','Delimiter','\t');

%% ######################## create BIDS events.tsv ######################

% Extract Triggers and Latency from EEG
TRIG = DATA2(:,end);
tmp = [0; diff(TRIG)];
LATENCY = find(tmp~=0);
TYPE = TRIG(LATENCY);

% ---- Required fields: ----
% REQUIRED Onset (in seconds) of the event  measured from the beginning of 
% the acquisition of the first volume in the corresponding task imaging data file.  
% If any acquired scans have been discarded before forming the imaging data file, 
% ensure that a time of 0 corresponds to the first image stored. In other words 
% negative numbers in onset are allowed.
onset = dataStruct.time{1}(LATENCY)'; 

%REQUIRED. Duration of the event (measured  from onset) in seconds.  
% Must always be either zero or positive. A "duration" value of zero implies 
% that the delta function or event is so short as to be effectively modeled as an impulse.
duration = zeros(length(onset),1); 

%OPTIONAL Primary categorisation of each trial to identify them as instances 
% of the experimental conditions
trial_type = TYPE;

%OPTIONAL. Response time measured in seconds. A negative response time can be 
% used to represent preemptive responses and n/a denotes a missed response.
% response_time=[0]';

% ---- WRITE: ----

t = table(onset,duration,trial_type);
writetable(t,[direct.data_bids filename.bids.EVT '.tsv' ],'FileType','text','Delimiter','\t');
