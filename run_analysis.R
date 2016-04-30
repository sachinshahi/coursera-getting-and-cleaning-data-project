if (!require("data.table")) {
    install.packages("data.table")
}

if (!require("dplyr")) {
    install.packages("dplyr")
}

require("data.table")
require("dplyr")

# Read training data
training_data <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
# Read test data
test_data <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)

# Read training activity data
training_activity <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
colnames(training_activity)<-c('activity')
training_data<-cbind(training_activity,training_data)
# Read test activity data
test_activity <- read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
colnames(test_activity)<-c('activity')
test_data<-cbind(test_activity,test_data)

# read training subject
training_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE,col.names = c("subject"))
training_data<-cbind(training_subject,training_data)

# read test subject
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE,col.names = c("subject"))
test_data<-cbind(test_subject,test_data)

#1.Merges the training and the test sets to create one data set.
mergedData<-rbind(test_data,training_data)

#2.Extracts only the measurements on the mean and standard deviation for each measurement.
features <- read.table("./UCI HAR Dataset/features.txt",header=FALSE,col.names = c('id','name'))
colnames(mergedData)<-c('subject','activity',as.vector(features$name))
required_columns<-grep("mean|std",names(mergedData),ignore.case = TRUE)
required_columns<-c(1,2,required_columns)
mean_std_data<- mergedData[,required_columns]

#3.Uses descriptive activity names to name the activities in the data set
# read activity_label
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE,col.names = c('id','name'))
mean_std_data$activity<- activity_labels[match(mean_std_data$activity,activity_labels$id),2]

#4.Appropriately labels the data set with descriptive variable names.
names(mean_std_data)<-gsub("Acc", "Accelerometer", names(mean_std_data))
names(mean_std_data)<-gsub("Gyro", "Gyroscope", names(mean_std_data))
names(mean_std_data)<-gsub("^t", "Time", names(mean_std_data))
names(mean_std_data)<-gsub("^f", "Frequency", names(mean_std_data))
names(mean_std_data)<-gsub("BodyBody", "Body", names(mean_std_data))
names(mean_std_data)<-gsub("Mag", "Magnitude", names(mean_std_data))
names(mean_std_data)<-gsub("-", ".", names(mean_std_data))

#From the data set in step 4, creates a second, independent tidy data set with the 
#average of each variable for each activity and each subject.
grp<-group_by(mean_std_data,subject,activity)
tidy_data <- summarize_each(grp,funs(mean))
#write data into text file
write.table(tidy_data, file = "./tidy_data.txt",row.names = FALSE)




