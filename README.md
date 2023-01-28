# 2process_Bursts
 
These scripts are used to analyze data for *EEG oscillations reflect sleep need - except during the wake maintenance zone*. They rely on data preprocessed with the scripts from [The Theta Paradox](https://github.com/snipeso/Theta-SD-vs-WM), and calculate bursts using the functions in the [matcycle](https://github.com/HuberSleepLab/Matcycle) repository. These are a MATLAB adaptation of the python scripts for [bycycle](https://github.com/bycycle-tools/bycycle). Lastly, this uses the plotting repository [chART](https://github.com/snipeso/chART). There are probably some functions from EEGLAB as well.


## How to use the scripts

1) Run preprocessing and power calculations through the Theta Paradox scripts
2) Run burst detection scripts (Burst_Detection/)
3) Run pupil preprocessing (Pupil_Detection/)
4) Run the Analysis scripts, first the L series ("load"), then the P series ("print")


## Quick access

### Plots and tables

- **Table 1**: Statistics conducted in [P1_StatisticsTable.m](Analysis/P1_StatisticsTable.m). Data is saved as matrices after running the L1-L5 scripts in Analysis/
- **Figure 2**: in [P3_KSS.m](Analysis/P3_KSS.m), after having run L2_Questionnaires.m.
- **Figure 3, 4**: in [P2_Power.m](Analysis/P2_Power.m), after having run L1_Power.m.
- **Figure 5, 6**: in [P4_BurstDetection.m](Analysis/P4_BurstDetection.m), after having run L3_Bursts.m, and of course all the burst detection scripts before that.
- **Figure 7**: in [P5_Bursts.m](Analysis/P5_Bursts.m).
- **Figure 8**: in [P6_BurstToporaphies.m](Analysis/P6_BurstTopographies.m).
- **Figure 9**: in [P7_Pupillometry.m](Analysis/P7_Pupillometry.m), after having run L4_Pupillometry.m.
- **Figure 10**: in [P7_1_OddballResponse.m](Analysis/P7_1_OddballResponse.m).
- **Figure 11**: in [P8_EyeBehavior.m](Analysis/P8_EyeBehavior.m), after having run L5_EyeBehavior.m.