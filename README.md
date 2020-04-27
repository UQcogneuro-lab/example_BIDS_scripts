# example_BIDS_scripts
These are the three Matlab files I used to "BIDS-ify" an old dataset. This was cobbled together from the BIDS starter kit files for iEEG data:
https://github.com/bids-standard/bids-starter-kit

and this paper on BIDS for EEG: 

Pernet, C.R., Appelhoff, S., Gorgolewski, K.J. et al. EEG-BIDS, an extension to the brain imaging data structure for electroencephalography. Sci Data 6, 103 (2019). https://doi.org/10.1038/s41597-019-0104-8

# 1. "BIDifySubjectDat.m" 
This script:
- loads in matlab files of EEG and behavioural data
- creates new folders in line with the BIDS format and moves the files to the correct folders
- Reformats the EEG files from matlab to a brainvision format
- Writes subject specfific json data descriptors to the correct folders
- Writes subject specific tsv files describing data collection parameters
- writes subjects specific events files in tsv format 

# 2. "CreateBIDS_dataset_description_json.m"
This script:
- Creates a json dataset description, to be saved with the data in the top data folder

# 3. "createBIDS_participants_tsv.m"
This script:
- creates a tsv file which describes the participant metadata. 
