#Download
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

#Unzip
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#File List
path<-file.path("./data","UCI HAR Dataset")
file<-list.files(path,recursive=T)
file

##Stage 1: Merge the training and the test sets to create one data set
#Read Files
test_activities_data<-read.table(file.path(path,"test","Y_test.txt"),header=F)
train_activities_data<-read.table(file.path(path,"train","Y_train.txt"),header=F)
test_features_data<-read.table(file.path(path,"test","X_test.txt"),header=F)
train_features_data<-read.table(file.path(path,"train","X_train.txt"),header=F)
test_subject_data<-read.table(file.path(path,"test","subject_test.txt"),header=F)
train_subject_data<-read.table(file.path(path,"train","subject_train.txt"),header=F)

#Row bind
activities_data<-rbind(test_activities_data,train_activities_data)
features_data<-rbind(test_features_data,train_features_data)
subject_data<-rbind(test_subject_data,train_subject_data)

#Name
names(subject_data)<-c("subject")
names(activities_data)<- c("activity")
features_data_name<-read.table(file.path(path,"features.txt"),head=F)
names(features_data)<-features_data_name$V2

#Merge
combined_data <- cbind(subject_data, activities_data)
data1 <- cbind(features_data, combined_data)

##Stage 2: Extract only the measurements on the mean and standard deviation for each measurement
#Name identification
sub_features_data_name<-features_data_name$V2[grep("mean\\(\\)|std\\(\\)",features_data_name$V2)]

#Create subsets
selected_names<-c("subject","activity",as.character(sub_features_data_name))
data2<-subset(data1,select=selected_names)

##Stage 3: Use descriptive activity names to name the activities in the data set
#Get activities name
activities_label <- read.table(file.path(path, "activity_labels.txt"),header = F,col.names=c("class_label","activity_name"))
head(activities_label)

#Factorize
data2$activity<-factor(data2$activity,levels=activities_label[,"class_label"],labels=activities_label[,"activity_name"])
data2$subject<-as.factor(data2$subject) 
data2$activity

##Stage 4: Appropriately label the data set with descriptive variable names
#Name
names(data2)<-gsub("^t", "time", names(data2))
names(data2)<-gsub("^f", "frequency", names(data2))
names(data2)<-gsub("Acc", "Accelerometer", names(data2))
names(data2)<-gsub("Gyro", "Gyroscope", names(data2))
names(data2)<-gsub("Mag", "Magnitude", names(data2))
names(data2)<-gsub("BodyBody", "Body", names(data2))
names(data2)

##Stage 5: From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
#Create
install.packages("plyr")
library(plyr)
data3<-aggregate(. ~subject + activity, data2, mean)
data3<-data3[order(data3$subject,data3$activity),]
write.table(data3, file = "tidydata.txt",row.name=F)
read.table("tidydata.txt",header=F)
