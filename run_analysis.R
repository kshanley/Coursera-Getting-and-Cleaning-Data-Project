library(plyr)

# Download file and unzip the dataset:
filename <- "getdata_dataset.zip"
if (!file.exists(filename)){
    fileURL <- " "
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                  filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

# Get activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Get features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Keep only the  mean and standard deviation
mean_sd <- grep(".*mean.*|.*std.*", features[,2])
mean_sd_names <- features[mean_sd,2]
mean_sd_names = gsub('-mean', 'Mean', mean_sd_names)
mean_sd_names = gsub('-std', 'SD', mean_sd_names)
mean_sd_names <- gsub('[-()]', '', mean_sd_names)

# Read train datasets
trainx <- read.table("UCI HAR Dataset/train/X_train.txt")[mean_sd]
trainy <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainsubjects, trainy, trainx)

# Read test datasets
testx <- read.table("UCI HAR Dataset/test/X_test.txt")[mean_sd]
testy <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testsubjects, testy, testx)

# Merge datasets and add labels
all <- rbind(train, test)
colnames(all) <- c("Subject", "Activity", mean_sd_names)

all[, 2] <- activityLabels[all[, 2], 2]

# Summarise for average of variables
means <- ddply(all, .(Subject, Activity), function(x) colMeans(x[, 3:81]))

# Output text file
write.table(means, "tidy.txt", row.names=FALSE)
