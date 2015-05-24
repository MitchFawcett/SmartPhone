# SmartPhone
A repository for Coursera Data Science - Getting and Cleaning Data - Assignment. 
This repo contains code for analyzing Samsung smart phone accelerometer data.

Goal of the project is to summarize data files containing Samsung smart phone accelerometer data in the way requested by the instructor.

Source data for the assignment was provided at this location:
 https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

Source data files used by my solution:
* activity_labels.txt 
* features.txt
* subject_test.txt
* subject_train.txt
* X_test.txt
* X_train.txt
* y_test.txt
* y_train.txt

Source data files not used: 
* Files in the Inertial Signals folders. 
 
The exluded source files were not seen to be critical to the dataset requested by the instructor. The dimensions of the set of files that I chose to use were dimensionally consistent with one another and "made sense". The inertial files seemed to be extraneous to the assignment and the FAQ appeared to confirm this.

Additional codebook information describing the source data used by this project was provided by the vendor in their README.TXT and features_info.txt files. 

See my Readme.md markup file at https://github.com/MitchFawcett/SmartPhone for information about my solution that you cannot find here.

There were basically five components of the source data that needed to be combined into a single dataframe for analysis.  
1. measurement data - files: X_test and X_train. These are the numeric values from smart phone accelerometer.   
2. subject identifier data - files: subject_test and subject_Train.  These are integer values 1 to 30 identifying people performing activities with the smart phone.  
3. activity identifier data - files: y_test and y_train.  These are integer values 1 to 6 identifying the activity being performed by the subject (sitting, standing etc).  
4. column headings for the measurement data - file: features. Descriptions for the kinds accelerometer readings.  
5. activity descriptions - file: activity_Labels.  Descriptive terms for each of the 6 activity types.

The source data was supplied in the form of a "training" set of data and a "testing" set of data.  For purposes of the assignment these two sets were row merged into one contiguous dataset.

Once the source data files were merged I had a single data frame with three factor columns (activitylabel, activitydescription and subject) and 561 numeric data columns and 10299 rows. (The number of rows matched what the vendor had said on their web site was the number of observations in their data and the number of numeric data columns matched what the vendor said in their features_info.txt file.)

The combined dataset was then manipulated to produce the final output file which I called dsSummaryMRF.txt.

The instructions called for calculating the average of mean and standard deviation values found in the source data.  The following R code can be used to identify the columns that we need.  

allcol <- features
toMatch <- c("-std\\(", "-mean\\(")
matches <- grep(paste(toMatch,collapse="|"),  allcol$V2, value=TRUE)


 




