# Getting_and_Cleaning_Data_Course_Project

This repo contains a single script labeled run_analysis.r

The code uses data related to body movement measurements from a smartphone from:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The original data source is: 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The script performs the following tasks:

1) Downloads the zip and unzips the data in a "data" directory created in the current working directory

2) Merges training and the test data sets available in the zip to create one data set.

3) Extract the mean and standard deviation data points, ignoring the 14 other aggregation statisitcs (min, max, signal magnitude etc) available in the data.

4) Uses descriptive activity names to name the activities in the data set.
* There is a file within the data labeled "activity_labels" which is a lookup table on activity number -> activity name

5) Appropriately labels the data set with descriptive variable names.
* Used full naming conventions for the fields as described in the codebook

6) Write text file with tidy data sets:
* 1) The set with activities merged in, test and training data merged, altered feature names and only mean and SD data
* 2) The set that pivots set 1 on Activity_Name and Feature_Name
