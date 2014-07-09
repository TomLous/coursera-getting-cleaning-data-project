#change this to source file location!
setwd("~/Documents/coursera/getdata/project")

vars <- ls()
vars <- vars[which(vars!="mergedData")]
#rm(list = vars)
debug <- FALSE

if(debug && exists("mergedData")){
  rm(mergedData)
}

# libs
library(RCurl)


# data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipDir <- "UCI HAR Dataset"
targetFile <- "data.zip"
dataPath <- "./data"
targetFilePath <- file.path(dataPath,targetFile)

if(!exists("keyColumns")){
  keyColumns <<- c()
}


if(!exists("featureColumns")){
  featureColumns <<- c()
}

# create path
if(!file.exists(dataPath)){
  dir.create(dataPath)
}

# download .zip file if not exists
if(debug){file.remove(filePath)}

if(!file.exists(targetFilePath)){
  binaryData <- getBinaryURL(fileUrl, ssl.verifypeer=FALSE, followlocation=TRUE) 
  fileHandle <- file(targetFilePath, open="wb")
  writeBin(binaryData, fileHandle)  
  close(fileHandle)  
  rm(binaryData)
}

# unzip if not already exists
extractedZipPath <- file.path(dataPath, zipDir)
if(!file.exists(targetFilePath) || debug){
  unzip(targetFilePath, exdir=dataPath, overwrite=TRUE)
}

dirList <- list.files(extractedZipPath, recursive=TRUE)
  

# load all train & test .txt files into memory: ignoring the 'Inertial Signals' folders
sanitizedDirList <- dirList[!grepl("Inertial", dirList) & grepl("test|train", dirList)]

if(!exists("mergedData") || debug){
  for(dataFile in sanitizedDirList){
    # generate parameters based on filesc
    paramName <- paste0("data_", tolower(sub("^.*/([^\\.]+).*$","\\1",dataFile, perl=TRUE)))
    txtFile <- file.path(extractedZipPath, dataFile)
    tableData <- read.table(txtFile)  
    assign(paramName, tableData)
  }
  
  
  
  # should have these variables (check via ls()):
  # data_subject_test
  # data_subject_train
  # data_x_test
  # data_x_train
  # data_y_test
  # data_y_train
 
  # Assignment/Project:
  # 1. Merges the training and the test sets to create one data set.
  
  # combine test & training data as rows into 3 data sets
  data_subject <- rbind(data_subject_test, data_subject_train)
  names(data_subject) <- c("subject")
  keyColumns <- union(keyColumns, names(data_subject))
  rm(data_subject_test)
  rm(data_subject_train)
  
  
  data_y <- rbind(data_y_test, data_y_train)
  names(data_y) <- c("activity_num")
  keyColumns <- union(keyColumns, names(data_y))
  rm(data_y_test)
  rm(data_y_train)
  
  data_x <- rbind(data_x_test, data_x_train)
  featuresFile <- file.path(extractedZipPath,"features.txt")
  featureData <- read.table(featuresFile)
  featureColumns <- featureData$V2
  names(data_x) <- featureColumns
  rm(data_x_test)
  rm(data_x_train)
  rm(featureData)
  
  
  
  # combine the 3 data sets as colums into mergedData
  mergedData <- cbind(data_subject, data_y)
  mergedData <- cbind(mergedData, data_x)
  rm(data_subject)
  rm(data_x)
  rm(data_y)
  
}  


# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

meanStdFeatureColumns <- featureColumns[grepl("(mean|std)\\(\\)",featureColumns)]
subSetColumns <- union(keyColumns, meanStdFeatureColumns)
subSetMergedData <- mergedData[,subSetColumns]



# 3. Uses descriptive activity names to name the activities in the data set
activitiesFile <- file.path(extractedZipPath,"activity_labels.txt")
activitiesData <- read.table(activitiesFile)
names(activitiesData) <- c("activity_num", "activity_name")

subSetMergedData <- merge(subSetMergedData, activitiesData, by="activity_num", all.x=TRUE)
subSetKeyColumns <- union(keyColumns, c("activity_name"))

# 4. Appropriately labels the data set with descriptive variable names. 
reshapedData <- melt(subSetMergedData, subSetKeyColumns)

variableList <- strsplit(gsub("^((f|t)(Body|BodyBody|Gravity)(Gyro|Acc|Body)[\\-]*(Jerk)?(Mag)?[\\-]*(mean|std)[\\(\\)\\-]*(X|Y|Z)?)", "\\2|\\3|\\4|\\5|\\6|\\7|\\8|\\1", subSetMergedData$variable), "\\|")

# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
