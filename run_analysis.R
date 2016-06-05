install.packages("dplyr")
install.packages("reshape2")
install.packages("stringr")
library(dplyr)
library(reshape2)
library(stringr)

## setwd(_____________) - To desired working directory

## Download file and unzip
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

unzip(zipfile="./data/Dataset.zip",exdir="./data")



## Load in names for featers and acticities
Feature_Name_Lookup <- read.table("./data/UCI HAR Dataset/features.txt",stringsAsFactors = FALSE,header = FALSE,sep = " ")
Activity_Name_Lookup <- read.table("./data/UCI HAR Dataset/activity_labels.txt",stringsAsFactors = FALSE, header = FALSE,sep = " ")
names(Activity_Name_Lookup) <- c("Activity_Num","Activity_Name")

## Load in training files and assign feature names as headers for feature data file 
train_subject <- read.table("./data/UCI HAR Dataset/train//subject_train.txt",stringsAsFactors = FALSE, header = FALSE, sep = " ")
train_X <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train_activity <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
names(train_X) <- Feature_Name_Lookup[,2]
names(train_subject) <- "SubjectNum"
names(train_activity) <- "ActivityNum"

## Load in test files and assign feature names as headers for feature data file 
test_subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt" ,stringsAsFactors = FALSE, header = FALSE, sep = " ")
test_X <- read.table("./data/UCI HAR Dataset/test/X_test.txt") 
test_activity <- read.table("./data/UCI HAR Dataset/test/y_test.txt",stringsAsFactors = FALSE, header = FALSE, sep = " ")
names(test_X) <- Feature_Name_Lookup[,2]
names(test_subject) <- "SubjectNum"
names(test_activity) <- "ActivityNum"


## Merge parts of train set and merge parts of test set. Note that row count of 
## 7352 for train data and 2947 for test data cleanly match accross tables.
## Add field for train or test so that a the two data sets can be distinguished
## when row bound


trainMaster <- cbind(c(rep('train',7352)), train_subject, train_activity, train_X)
colnames(trainMaster)[1]<- 'Train/Test'
testMaster <- cbind(c(rep('test',2947)),test_subject, test_activity, test_X)
colnames(testMaster)[1]<- 'Train/Test'

## Row bind the data together - 

Master_Table <- rbind(trainMaster, testMaster)

## Flag column names that will be required for mean/sd subset

mean_sd_vec <- (grepl("Train/Test" , colnames(Master_Table))    |
                  grepl("SubjectNum" , colnames(Master_Table))  | 
                  grepl("ActivityNum" , colnames(Master_Table)) | 
                  grepl("*mean*" , colnames(Master_Table))      | 
                  grepl("*std*" , colnames(Master_Table))
                )

## Take subset of data with mean/sd fields and subject name and activity

Master_Stats_Sub <- Master_Table[,mean_sd_vec]


## Merge Activiy_Name_Lookup to add descriptive activity names for the activities

Master_Stats_Sub <- left_join(x=Master_Stats_Sub, y = Activity_Name_Lookup, by = c("ActivityNum" = "Activity_Num"))
Master_Stats_Sub <- Master_Stats_Sub[,c(1:3,83,4:82)] 

## Change headers to more descriptive names
## Code book indicate:
## Acc = accelerometer
## Gyro = gyroscope
## t = time signal
## f = frequency signal
## Jerk = a movement acceleration
## Mag = the magnitude of movement
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"mean","Mean")
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"std","SD")
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"Acc","Accelerometer")
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"Gyro","Gyroscope")
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"^t","Time")
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"^f","Frequency")
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"Mag","Magnitute")
names(Master_Stats_Sub) <- str_replace(names(Master_Stats_Sub),"[(][)]","")


## Make tall skinny data set with all variables in a single field for separate
## pivot data set

Master_Stats_Sub_Tall <- melt(Master_Stats_Sub, id=colnames(Master_Stats_Sub)[c(1:4)], 
                              measure.vars = colnames(Master_Stats_Sub)[5:83])
names(Master_Stats_Sub_Tall)[5:6] = c("Feature_Name","Feature_Value")

## Group by subject, activity and measured metric and average measured value

Master_Pivot <- Master_Stats_Sub_Tall %>% 
                  group_by(SubjectNum, Activity_Name, Feature_Name) %>% 
                  summarise(Metric_Mean = mean(Feature_Value,na.rm = T))


## Write text file with tidy data sets:
## 1) The set with activities merged in, test and training data merged, altered feature names and only mean and SD data
## 2) The set that pivots set 1 on Activity_Name and Measurement_Metric

write.table(Master_Stats_Sub, "TidyData_Combined_Mean_SD.txt", row.name=FALSE)
write.table(Master_Pivot, "TidyData_Pivot.txt", row.name=FALSE)
