# Loading the required packages

library(data.table)
library(dplyr)
library(tidyr)

# Loading the files

## Data files

tr_x <- fread("UCI HAR Dataset/train/X_train.txt")
te_x <- fread("UCI HAR Dataset/test/X_test.txt")

all_x <- rbind(tr_x, te_x) # Merging train and test files

## Activity Files

tr_y <- fread("UCI HAR Dataset/train/y_train.txt", col.names = "ActivityCode")
te_y <- fread("UCI HAR Dataset/test/y_test.txt", col.names = "ActivityCode")

all_y <- rbind(tr_y, te_y) # Merging train and test files

## Subject Files

tr_sub <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = "SubjectCode")
te_sub <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = "SubjectCode")

all_sub <- rbind(tr_sub, te_sub) # Merging train and test files

## Features and activities Labels Files 

feat <- fread("UCI HAR Dataset/features.txt")
act_labels <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("ActivityCode", "Activity"))

## Renaming the Columns name
colnames(all_x) <- as.character(feat$V2)

## Merging all the data file to create an uniue file

all_data <- cbind(all_sub, all_y, all_x)

## Extracting and subsetting the "MEAN" and "STANDARD DEVIATION" features
all_data <- subset(all_data, select = union(c("SubjectCode","ActivityCode"), grep("mean\\(\\)|std\\(\\)", feat$V2, value = TRUE))) 

## Adding the Activity Name for each activity code
all_data <- merge(act_labels, all_data, by="ActivityCode", all.x = TRUE)

## Improving features label

names(all_data) <- gsub("[[:punct:]]", " ", names(all_data))
names(all_data) <- gsub("^t", "Time", names(all_data))
names(all_data) <- gsub("^f", "Frequency", names(all_data))
names(all_data) <- gsub("std", "SD", names(all_data))
names(all_data) <- gsub("mean", "MEAN", names(all_data))
names(all_data) <- gsub("Acc", "Accelerometer", names(all_data))
names(all_data) <- gsub("Gyro", "Gyroscope", names(all_data))
names(all_data) <- gsub("Mag", "Magnitude", names(all_data))
names(all_data) <- gsub("BodyBody", "Body", names(all_data))

## Creating factor variables for futher steps

all_data$ActivityCode <- as.factor(all_data$ActivityCode)
all_data$SubjectCode <- as.factor(all_data$SubjectCode)
all_data$Activity <- as.factor(all_data$Activity)
act_labels$ActivityCode <- as.factor(act_labels$ActivityCode)

## Creating tidy data set gruoped by activity and subject to report the average of each feature

all_data_resume <- aggregate(x = all_data[ ,-(1:3), with = FALSE], by = list(Activity = all_data$ActivityCode , Subject = all_data$SubjectCode), FUN = "mean")
all_data_resume <- merge(act_labels, all_data_resume, by.x = "ActivityCode", by.y = "Activity", all.x = TRUE)
all_data_resume <- arrange(all_data_resume, Subject, ActivityCode)

## Creating the output file

write.table(all_data_resume, "TidyData.txt", row.name = FALSE)
