library(data.table)
library(dplyr)
library(tidyr)

tr_x <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/train/X_train.txt")
te_x <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/test/X_test.txt")
all_x <- rbind(tr_x, te_x)

tr_y <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/train/y_train.txt", col.names = "ActivityCode")
te_y <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/test/y_test.txt", , col.names = "ActivityCode")
all_y <- rbind(tr_y, te_y)

tr_sub <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/train/subject_train.txt", col.names = "SubjectCode")
te_sub <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/test/subject_test.txt", col.names = "SubjectCode")
all_sub <- rbind(tr_sub, te_sub)

feat <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/features.txt")
act_labels <- fread("C:/Users/Fortunato/Desktop/UCI HAR Dataset/activity_labels.txt", col.names = c("ActivityCode", "Activity"))

colnames(all_x) <- as.character(feat$V2)

all_data <- cbind(all_sub, all_y, all_x)






all_data <- subset(all_data, select = union(c("SubjectCode","ActivityCode"), grep("mean\\(\\)|std\\(\\)", feat$V2, value = TRUE))) 

all_data <- merge(act_labels, all_data, by="ActivityCode", all.x = TRUE)


names(all_data) <- gsub("[[:punct:]]", " ", names(all_data))
names(all_data) <- gsub("^t", "Time", names(all_data))
names(all_data) <- gsub("^f", "Frequency", names(all_data))
names(all_data) <- gsub("std", "SD", names(all_data))
names(all_data) <- gsub("mean", "MEAN", names(all_data))
names(all_data) <- gsub("Acc", "Accelerometer", names(all_data))
names(all_data) <- gsub("Gyro", "Gyroscope", names(all_data))
names(all_data) <- gsub("Mag", "Magnitude", names(all_data))
names(all_data) <- gsub("BodyBody", "Body", names(all_data))

all_data$ActivityCode <- as.factor(all_data$ActivityCode)
all_data$SubjectCode <- as.factor(all_data$SubjectCode)
all_data$Activity <- as.factor(all_data$Activity)
act_labels$ActivityCode <- as.factor(act_labels$ActivityCode)


all_data_resume <- aggregate(x = all_data[ ,-(1:3), with = FALSE], by = list(Activity = all_data$ActivityCode , Subject = all_data$SubjectCode), FUN = "mean")
all_data_resume <- merge(act_labels, all_data_resume, by.x = "ActivityCode", by.y = "Activity", all.x = TRUE)
all_data_resume <- arrange(all_data_resume, Subject, ActivityCode)

write.table(all_data_resume, "TidyData.txt", row.name = FALSE)



