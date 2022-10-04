# 2process_Bursts
 
These scripts are used to analyze data for Paper 3. They rely on data preprocessed with the scripts from [The Theta Paradox](https://github.com/snipeso/Theta-SD-vs-WM), and calculate bursts using the functions in the [matcycle](https://github.com/HuberSleepLab/Matcycle) repository. These are a MATLAB adaptation of the python scripts for [bycycle](https://github.com/bycycle-tools/bycycle). Lastly, this uses the plotting repository [chART](https://github.com/snipeso/chART). There are probably some functions from EEGLAB as well.


## Starting data
For both the power calculation and the burst detection, this script uses data filtered between 0.5-40 Hz, and downsampled to 250 Hz. In my file structure, this is saved as "Power".



## Power calculation
pWelch power was calculated with scripts in the Theta Paradox. Here we just plot the output.