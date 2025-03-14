# fMRI Analysis of Concussion

## Dataset
- Total of 81 participants:
  - 46 Patients (Chronic Phase; 38.22 $\pm$ 11.45 y.o.; 13 Male)
  - 35 healthy controls (41.09 $\pm$ 13.66 y.o.; 18 Male)
- Resting-State fMRI
  
## Preprocessing Pipeline
### Spatial Preprocessing
- Susceptibility Distortion Correction of functional volumes
- Realignment of functional volumes
- Segmentation of structural image to WM, GM, and CSF TPMs.
- Coregistration of functional volumes to the structural space
- Normalization of the structural image, TPMs, and functional volumes to the MNI space.
- Smoothing of functional volumes (FWHM=4mm)

### Temporal Denoising
- General Linear Model
  - Nuisance regressors:
    - 6 motion regressors
    - The first derivative of motion regressors
    - The first 5 principal components of the WM mask time series
    - The first 5 principal components of the CSF mask time series
    - Outlier volumes
    - Constant and linear detrending regressors
- Bandpass Filtering 
  - BPF in the range of [0.008, 0.09] Hz. 
