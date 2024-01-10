# Higher handgrip strength is linked to higher salience/ventral attention functional network segregation in older adults

## Reference



----
## Background

Converging evidence suggests that handgrip strength is linked to cognitive functioning in older adults, and this may be subserved by shared changes in brain function and structure in ageing. However, the interplay among handgrip strength, brain functional connectivity, and cognitive function remains poorly elucidated. Hence, our study sought to examine these relationships in a cohort of 148 community-dwelling older adults. Specifically, we examined brain network segregation, a summary measure of functional brain organization that is sensitive to ageing and cognitive decline, and its associations with handgrip strength and cognitive function. We showed that higher handgrip strength was related to better processing speed, attention performance, and global cognition in older adults. Individuals with higher handgrip strength also had higher brain functional segregation of the salience/ventral attention network, driven particularly by higher salience/ventral attention intra-network functional connectivity of the right anterior insula to the left posterior insula/frontal operculum and right midcingulate/medial parietal cortex. Importantly, these handgrip strength-related inter-individual differences in salience/ventral attention network functional connectivity were linked to cognitive function, as revealed by functional decoding and brain-cognition association analyses. Taken together, our findings highlight the importance of the salience/ventral attention network in handgrip strength and cognition, and suggest that inter-individual differences in salience/ventral attention network segregation and intra-network functional connectivity could underpin the relationship between handgrip strength and cognition in older adults.


----

## Usage

Please refer to the respective sections for more information on the code used:
* [Assessment of Functional Segregation](#assessment-of-functional-segregation)
* [Association Analyses](#association-analyses)
* [Functional Decoding](#functional-decoding)
* [Mediation Analyses](#mediation-analyses)


Sample data for the above analyses are also located in the SampleData folder. Details of the sample data provided are given below:

* `FCmatrices/`:
	* `Subj001.mat`: 142 x 142 functional connectivity matrix for a specific subject (e.g., Subj001)
	* `subjectlist.txt`: text file containing the list of all subject IDs (each subject ID is specified in a separate row)

* `Demographic.csv`: spreadsheet containing demographic, cognitive, handgrip strength and other participant characteristics
  
* `Handgripstrength-relatedFCmeasures.csv`: spreadsheet containing select subject-level functional connectivity measures that showed significant associations with handgrip strength
  
* `Segregationmeasures.csv`: spreadsheet containing global and network-level segregation measures of each subject
  
* `SVA_InterIntraNetworkFCmeasures.csv`: spreadsheet containing salience/ventral attention inter- and intra-network functional connectivity measures for each subject
  
* `SVA_IntraNetworkRegionalFCmeasures.csv`: spreadsheet containing salience/ventral attention intra-network regional functional connectivity measures for each subject


Other files:
`Parcellation_142ROIs.nii`: Nifti file containing all regions-of-interest used in the study


----

## Assessment of Functional Segregation

### Main files:

* `CalculateSegregation.m`: Calculates system segregation for each subject and saves the values as a table in a csv file.

### Supporting files:

* `systemsegregation.m`: Function file that generates global and network-level system segregation values given the functional connectivity matrix and the network assignment of the parcellation used
  
* `Parcellation_142ROIs_networkassignment.mat`:
	* p: network assignment of the 142 ROI parcellation. Each region is given a number from 1 to 9 (corresponding to a specific network).
	* networknames: corresponding network labels. The labels are ordered in the same manner as the network assignment in variable p (i.e., value of 1 pertains to the default network, which is the first label in the variable network names).


----

## Association Analyses

### Main files:

* `AssociationsbetCognition_HandgripStrength.R`: Runs linear regression analyses to examine the associations between handgrip strength and various cognitive scores. The results are saved in a csv file.
  
* `AssociationsbetFC_HandgripStrength.R`: Runs linear regression analyses to examine the associations between the various functional connectivity measures (e.g., segregation, inter- and intra-network functional connectivity) and handgrip strength. The results are saved in a csv file.
  
* `AssociationsbetCognition_FC.R` Runs linear regression analyses to examine the associations between the handgrip-strength related functional connectivity measures and various cognitive scores. The results are saved in a csv file.
  
* `Validation_AssociationsbetCognition_HandgripStrength.R`: Runs validation analyses where the associations between handgrip strength and various cognitive scores are repeated additionally controlling for various nuisance covariates (e.g., waist-hip ratio, geriatric depression scores etc.). The results are saved in a csv file.
  
* `Validation_AssociationsbetFC_HandgripStrength.R`: Runs validation analyses where the associations between the various functional connectivity measures and handgrip strength are repeated additionally controlling for various nuisance covariates. The results are saved in a csv file.
  
* `Validation_AssociationsbetCognition_FC.R`: Runs validation analyses where the associations between the handgrip-strength related functional connectivity measures and various cognitive scores are repeated additionally controlling for various nuisance covariates. The results are saved in a csv file.

### Supporting files:

* `RunLM_Functions.R`: Function file that organises and outputs the results to a data frame.


----

## Functional Decoding

Functional decoding was performed using the Neurosynth ROI association approach on [NiMARE](https://nimare.readthedocs.io/en/stable/installation.html) v0.0.12 package for Python, which correlates the mean modeled activation values within the binarized ROI with the term weights of all 50 topics in the Neurosynth dataset. 

### Environment setup

Create and activate conda environment named `Decode` from `Decode_environment.yml`
```sh
conda env create -f Decode_environment.yml
conda activate Decode
```

### Running functional decoding

#### Main files:

* `Part1_DownloadLDA50database.ipynb`: Downloads the LDA50 database from Neurosynth and converts it to NiMARE dataset file
  
* `Part2_Functionaldecoding.ipynb`: Loads the downloaded LDA50 database and performs discrete functional decoding using the Neurosynth ROI association method

#### Supporting files:

* `ROI_056_SalVentAttn_L_PI_RO.nii`: Binarized nifti image of the left posterior insula/frontal operculum region
  
* `ROI_069_SalVentAttn_R_MCC_MPC.nii`: Binarized nifti image of the right midcingulate/medial parietal cortex
  
* `ROI_074_SalVentAttn_R_AI.nii`: Binarized nifti image of the right anterior insula


----

## Mediation Analyses

### Main files: 

* `Mediation.R`: Runs mediation analyses to examine the mediation effect of functional connectivity on the relationship between handgrip strength and cognition



----

## Data availability

The data supporting this manuscript is available upon request from the corresponding author. The data is not publicly available due to institute policy.


----

## Bugs and Questions

Please contact Joanna Su Xian Chong at joanna.chong@nus.edu.sg and Helen Zhou at helen.zhou@nus.edu.sg
