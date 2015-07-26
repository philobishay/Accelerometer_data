# Overview ###########################################
# This project downloads, unzips, and tidies acceleration and rotational data
# taken from the Human Activity Recognition Using Smartphones Dataset Version 1.0
# Smartlab - Non Linear Complex Systems Laboratory
# DITEN - Universit‡ degli Studi di Genova.

## Citation ##########################################
# [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. 
# Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly 
# Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). 
# Vitoria-Gasteiz, Spain. Dec 2012

## Optional code #####################################
#rm(list=ls())             #tidies up global environment
#setwd("/Users/philobishay/Documents/Coursera/Getting and Cleaning Data")

## Run package manager to install packages ###########
if (!require("pacman")) install.packages("pacman")
pacman::p_load(pacman,downloader)

# Download and unzip the data ########################
download(
  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
  dest="project_data.zip", mode="wb")
unzip ("project_data.zip", exdir = "./")

# Begin tidying data #################################
setwd("./UCI HAR Dataset")

# add data labels and named activity labels
activity.labels = read.table("activity_labels.txt")
names(activity.labels) = c("activity.index","activity.description")
data.labels = read.table("features.txt")
names(data.labels) = c("data.index","data.description")

# create 'combined' directory for combining 'test' and 'train' data
dir.create("combined")

# read test and train data
test.x.set = read.table("./test/X_test.txt")
test.y.set = read.table("./test/Y_test.txt")
test.subj.set = read.table("./test/subject_test.txt")
train.x.set = read.table("./train/X_train.txt")
train.y.set = read.table("./train/Y_train.txt")
train.subj.set = read.table("./train/subject_train.txt")

# combine test and train data
x.combined = rbind(test.x.set,train.x.set)
y.combined = rbind(test.y.set,train.y.set)
subject.combined = rbind(test.subj.set,train.subj.set)

# remove uncombined data to maximize memory
rm(test.x.set,test.y.set,test.subj.set,train.x.set,train.y.set,train.subj.set)

# Create a single table that shows the activity index, activity name (label),
# subject index, then all the "x" data from the test and training sets, respectively
colnames(subject.combined) = "subject.index"
colnames(y.combined) = "activity.index"
combined.data = cbind(y.combined,activity.labels[y.combined$activity.index,2],
                      subject.combined,x.combined)

# Create appropriate variable names
names(combined.data)[2] = "activity.labels"
names(combined.data)[4:564] = as.character(data.labels$data.description)

# Extract only the measurements on the mean and standard deviation for each measurement
mean.cols = grep("mean",names(combined.data))
std.cols = grep("std",names(combined.data))
truncated.data = combined.data[,c(2,3,mean.cols,std.cols)]

# Answers to Questions 1 through 4 ##################
#head(truncated.data)

# Answer to Question #5
# Create Tidy Data
p_load(reshape2)
data.melt = melt(truncated.data,id=c("activity.labels","subject.index"))
tidy.data = dcast(data.melt,activity.labels+subject.index~variable,mean)
names(tidy.data)[3:ncol(tidy.data)] = paste("mean.of.",names(tidy.data)[3:ncol(tidy.data)],sep="")
write.table(tidy.data,file="tidy_data.txt",row.names=F)

