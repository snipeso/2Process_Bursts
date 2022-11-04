
library(rmcorr)

# fixation theta
Bursts <- read.csv("C:/Users/colas/Projects/PhD/LSM/2process_Bursts/Statistics/Data/Fixation_Theta_Bursts.csv")
rmcorr(Participant, Amplitude, Quantity, Bursts)

# oddball theta
Bursts <- read.csv("C:/Users/colas/Projects/PhD/LSM/2process_Bursts/Statistics/Data/Oddball_Theta_Bursts.csv")
rmcorr(Participant, Amplitude, Quantity, Bursts)

# standing theta
Bursts <- read.csv("C:/Users/colas/Projects/PhD/LSM/2process_Bursts/Statistics/Data/Standing_Theta_Bursts.csv")
rmcorr(Participant, Amplitude, Quantity, Bursts)


# fixation alpha
Bursts <- read.csv("C:/Users/colas/Projects/PhD/LSM/2process_Bursts/Statistics/Data/Fixation_Alpha_Bursts.csv")
rmcorr(Participant, Amplitude, Quantity, Bursts)

# oddball alpha
Bursts <- read.csv("C:/Users/colas/Projects/PhD/LSM/2process_Bursts/Statistics/Data/Oddball_Alpha_Bursts.csv")
rmcorr(Participant, Amplitude, Quantity, Bursts)

# standing alpha
Bursts <- read.csv("C:/Users/colas/Projects/PhD/LSM/2process_Bursts/Statistics/Data/Standing_Alpha_Bursts.csv")
rmcorr(Participant, Amplitude, Quantity, Bursts)
