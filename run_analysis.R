library(tidyverse)
library(plyr)

# MEMO I initially just worked with the data stored locally on my computer
# then I found this solution by wdluft on github which I liked alot since this way reviewers do not need the data before validating the code

if(!file.exists("./COURSERA_DATA_CLEANING_ASSIGNMENT")){dir.create("./getcleandata")}
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "./getcleandata/projectdataset.zip")
unzip(zipfile = "./getcleandata/projectdataset.zip", exdir = "./getcleandata")

# STEP 1 - prepare all the data downloaded before

x_train <- read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/train/subject_train.txt")
x_test <- read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/test/subject_test.txt")
features <- read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/features.txt")
activityLabels = read.table("./COURSERA_DATA_CLEANING_ASSIGNMENT/UCI HAR Dataset/activity_labels.txt")

# I would like to also highlight another method -> you can basically combine ALL files in a folder instantly.
# this would have been very useful in case we would have to work with the scalar data, too -->
# see here if you are interested: https://psychwire.wordpress.com/2011/06/03/merge-all-files-in-a-directory-using-r-into-a-single-dataframe/ 
# you basically create a list of filenames and iterate over it and append them all to a new dataframe

# STEP 2 --> extract relevant information for the task at hand

colnames(x_train) <- features[,2]
# --> this means ALL VALUES FROM COLUMN TWO IN THE FEATURES DATAFRAME
colnames(y_train) <- "activityID"
colnames(subject_train) <- "subjectID"
colnames(x_test) <- features[,2]
# --> this means ALL VALUES FROM COLUMN TWO IN THE FEATURES DATAFRAME
colnames(y_test) <- "activityID"
colnames(subject_test) <- "subjectID"
colnames(activityLabels) <- c("activityID", "activityType")

# its the same for both training and test data
# now we have to combine the dataframes -> cbind: "Combine R Objects by Rows or Columns"

alltrain <- cbind(y_train, subject_train, x_train)
alltest <- cbind(y_test, subject_test, x_test)
finaldataset <- rbind(alltrain, alltest)

colNames <- colnames(finaldataset)

# 2.2 Create vector for defining ID, mean, and sd

# --> this gives you either TRUE if the condition is met or FALSE if the condition is not met.
# u can continue working with this to select columns (e.g. COUNT of a column is true ? --> include; false? --> exclude)
# GREP means global regular expressions -> that is basically a method to select objects/texts based on text rules (e.g. includes the word MEAN or STD; starts with; ends with or so)

mean_and_std <- (grepl("activityID", colNames) | grepl("subjectID", colNames) |grepl("mean..", colNames) | grepl("std...", colNames))

setforMeanandStd <- finaldataset[ , mean_and_std == TRUE]

# second example to illustrate how grepl works

GREPL_AUX <- (grepl("activityID", colNames) | grepl("subjectID", colNames))

secondGREPLEXAMPLE <- finaldataset[ , GREPL_AUX == TRUE] #> WILL NOW ONLY MATCH TWO COLUMNS

# 3 + 4 descriptive labels/ activity names
data_step_5 <- merge(setforMeanandStd, activityLabels,by = "activityID", all.x = TRUE,)


class(data_step_5)

# Final step 5
data_step_5 <- as_tibble(data_step_5)
class(data_step_5)
head(data_step_5)

final_data_frame <- data_step_5 %>% group_by(activityID, subjectID) %>% summarize_all(funs(mean))

# I did not know how to iterate over the activity factor to automate this "replace process"

final_data_frame$activityID[final_data_frame$activityID == 1] <- "WALKING"
final_data_frame$activityID[final_data_frame$activityID == 2] <- "WALKING_UPSTARS"
final_data_frame$activityID[final_data_frame$activityID == 3] <- "WALKING_DOWNSTARS"
final_data_frame$activityID[final_data_frame$activityID == 4] <- "SITTING"
final_data_frame$activityID[final_data_frame$activityID == 5] <- "STANDING"
final_data_frame$activityID[final_data_frame$activityID == 6] <- "LAYING"


write.csv(final_data_frame,"final_data_frame.csv", row.names = FALSE)