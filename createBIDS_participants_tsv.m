%% Template Matlab script to create an BIDS compatible participants.tsv file
% This example lists all required and optional fields.
% When adding additional metadata please use CamelCase
%
% DHermes, 2017
% modified RG 201809

%% Subject Details

direct.data = [pwd '\BIDS\'];
SUBDAT = {
    1  21 'M';
    2  42 'F';
    3  34 'M';
    4  34 'M';
    5  20 'M';
    6  21 'F';
    7  23 'F';
    8  25 'M';
    9  23 'M';
    10 21 'F';
    11 27 'M';
    12 18 'F';
    13 22 'F';
    14 22 'F';
    15 19 'F';
    16 22 'F';
    17 NaN 'F';
    18 18 'M';
    19 NaN 'M';
    20 20 'M';
    21 21 'M';
    22 19 'F';
    23 22 'F';
    24 23 'M';
    25 23 'M';
    26 23 'M';
    27 18 'F';
    28 23 'F';
    29 24 'M';
    30 22 'F';
    31 22 'M';
    32 34 'F';   
    
    };
%% Subject strings

n.sub = 32;
participant_id = cell(n.sub,1);
age = NaN(n.sub,1);
sex =  cell(n.sub,1);

for sub = 1:32 % subject number
    
    if sub <10
        bids.substring = ['sub-0' num2str(sub)];
    else
        bids.substring = ['sub-' num2str(sub)];
    end
    participant_id{sub} = bids.substring;
    age(sub) = SUBDAT{sub,2};
    sex{sub} = SUBDAT{sub,3};
end

%% make a participants table and save

t = table(participant_id,age,sex);

writetable(t,[direct.data 'participants.tsv'],'FileType','text','Delimiter','\t');


