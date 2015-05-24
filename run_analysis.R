#############################################################################################################
## File Name:   run_analysis.R
## Author:      M. Fawcett
## Date:        05/21/2015
## Description: R script for programming assignment "Getting and Cleaning Data".
############################################################################################################# 
## Goal of the assignment is to summarize data files containing sensor data in the way
## requested by the instructor.
##
## The course instructions for the assignment are here:
##      https://class.coursera.org/getdata-014/human_grading/view/courses/973501/assessments/3/submissions
##
##      Create one R script called run_analysis.R that does the following. 
##      1. Merges the training and the test sets to create one data set.
##      2. Extracts only the measurements on the mean and standard deviation for each measurement. 
##      3. Uses descriptive activity names to name the activities in the data set
##      4. Appropriately labels the data set with descriptive variable names. 
##      5. From the data set in step 4, creates a second, independent tidy data set with the average of each 
##      variable for each activity and each subject.
##
## A FAQ by teaching assistant David Hood helpful in determining what the structure and content of the 
## output file should be is here:
##      https://class.coursera.org/getdata-014/forum/thread?thread_id=30
##
## Additional tidy data understanding is here:
##      https://class.coursera.org/getdata-014/forum/thread?thread_id=31
##
## Source data for the assignment was provided at this location:
##      https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
## 
## Source data files used by my solution:
##      activity_labels.txt, features.txt, subject_test.txt, subject_train.txt, X_test.txt, 
##      X_train.txt, y_test.txt, y_train.txt
##
## Source data files not used: Files in the Inertial Signals folders.  
## These were not seen to be critical to the dataset requested by the instructor. The dimensions
## of the set of files that I chose to use were consistent with one another and "made sense". 
## The inertial files seemed to be extraneous to the assignment. The FAQ appeared to confirm this.
##
#################################################################################################
## After downloading the zip file containing the source data files, it was unzipped and copies of 
## unzipped data files were moved to a working directory for manipuation.
##
## Note: for the purpose of this assignment all steps for the solution are containined in one
## script file for convenience.  In real life, the source data download might be in a separate
## script, the initial loading of source data frames might be in another script and
## data manipulation and output performed in yet another script.  Creating separate scripts makes
## sense when tasks need to be performed at different frequencies or when rerunning
## a task would potentially be harmful.  In this case the source data is unlikely to change so
## reloading it each time this script is run is considered safe.
#################################################################################################
## Make sure needed library are available
## sessionInfo()

## plyr package needed for arrange()
## install.packages("plyr")
## library(plyr) 

## Make sure gdata functions are available. (needed for matchCols())
## install.packages("gdata")
## library(gdata)

## make sure sqldf functions are available. (needed to insert activity descriptions)
## install.packages("sqldf")
## library(sqldf)
## ?? Is MySQL service started on your computer ??

## Create data frames containing each of the source files.
## test data file to a data frame
testX <- read.csv("X_test.txt", sep = "", header=FALSE)
## dim(testX): 2947  561

## training data file to a data frame
trainX <- read.csv("X_train.txt", sep = "", header = FALSE)
## dim(trainX): 7352  561

## testing data labels to a data frame
testy <- read.csv("y_test.txt", sep = "", header = FALSE)
## dim(testy): 2947    1

## training data labels to a data frame 
## y Values correspond to Activity labels
trainy <- read.csv("y_train.txt", sep = "", header = FALSE)
## dim(trainy): 7352    1

## feature names to a data frame
features <- read.csv("features.txt", sep = "", header = FALSE)
## dim(features): 561   2

## test data subjects to a data frame
testSubject <- read.csv("subject_test.txt", sep = "", header = FALSE)
## dim(testSubject): 2947    1

## training data subjects to a data frame
trainSubject <- read.csv("subject_train.txt", sep = "", header = FALSE)
## dim(trainSubject): 7352    1

## activity labels to a data frame
## (Activity label numbers correspond to the testy and trainy labels)
activityLabels <- read.csv("activity_labels.txt", sep = "", header = FALSE)
## dim(activityLabels): 6 2

#################################################################################################
## 1. Merge the training and the test sets to create one data set.
# Merge data files
x <- rbind(testX, trainX)  
# Note: Can do sum(x) to see if all values are numeric. Will get an error if not all numeric.

# Merge subject label files
s <- rbind(testSubject, trainSubject)

# Merge subject labels and data
sd <- cbind(s, x)

# Merge activity label files
y <- rbind(testy, trainy)
# Note: Can do unique(y) to see if all values are consistent with the numeric labels in activity_labels.txt
# This will be important in part 3

# Merge activity labels with subject labels and data
ysd <- cbind(y, sd) 

# Create a column header vector
f <- as.vector(t(features[, 2]))

# Add elements to header vector for activity and subject labels
ch <- append(f, "Subject", after = 0)
ch <- append(ch, "ActivityLabel", after = 0)

# Add column heads to data
names(ysd) <- ch

##################################################################################################

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# Identify data columns involving means and standard deviations using a gdata function.
# Also, provide column headings for activity and subject labels. matchcols in gdata package.
ds <- ysd[,c("ActivityLabel", "Subject", matchcols(ysd, with = c("-mean\\(", "std\\("), method = c("or")))] 

## Note:  There are data features involving "mean freq" or "gravity mean". My 
## interpretation of the problem is that those are not to be included in the tidy dataset.
## Only features with -mean() or -std() in their descriptions are to be included in the dataset. 
## In the real world we would hope to be able to get clarification from the investigators 
## whether this interpretation is correct.

##################################################################################################

## 3. Uses descriptive activity names to name the activities in the data set
# Create a data frame using look up values in activity_Labels.txt for "y" values (ie ActivityLabel)
activityText <- sqldf("Select activityLabels.V2 from ds JOIN activityLabels ON ds.ActivityLabel = activityLabels.V1")

# Give the activtyText data frame a column name
names(activityText) <- "ActivityText"

# Insert the activityText data frame into the main dataset so it is the second column between 
# ActivityLabel and Subject
ds <- data.frame(ds[1:1], activityText, ds[-c(1:1)])

##################################################################################################

## 4. Appropriately labels the data set with descriptive variable names. 
# This got done in section 1.  See: Add column heads to data; names(ysd) <- ch
# Note: The hyphen and parentheses characters in the features names are converted to dots.
# "ds" is the data set to be grouped and summarized for the assignment in part 5.

##################################################################################################

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each 
##    variable for each activity and each subject.
# Create a grouping data frame using the activity and subject labels. 
dsTemp <- aggregate(ds[, 4:ncol(ds)], list(ds$ActivityLabel, ds$ActivityText, ds$Subject), data = ds,  mean)
# Note: Find means of only the numeric data columns starting wth column 4.

# Rename the group name columns from Group.1 etc to meaningful names.
names(dsTemp)[1:3] <- c("ActivityLabel", "ActivityText", "Subject") 

# Reorder the dataset so it is sorted by activity and then by subject
dsSummary <- arrange(dsTemp, ActivityLabel, ActivityText, Subject)
# "dsSummary" is the dataset to be uploaded as file dsSummaryMRF.txt
write.table(dsSummary, "dsSummaryMRF.txt", row.name = FALSE)

message("The tidy data output was saved in your working directory in a file named dsSummaryMRF.txt")
message("The output can be viewed by doing `data <- read.table('dsSummaryMRF.txt', header = TRUE)`")
message("then, `View(data)`")


##################################################################################################

## Notes:
# Do str(dsSummary), summary(dsSummary), dim(dsSummary) to see if values are numeric for all features of interest
# and the results seem reasonable.
# Also can cross check results by using sqldf to calculate the mean for a few activity, 
# subject combinations.
# sqldf("select avg(ds.[tBodyAcc.mean...X]) from ds where Subject = '1' and ActivityText = 'LAYING'")

