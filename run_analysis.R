debug <- FALSE

# libs
library(RCurl)


# data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipDir <- "UCI HAR Dataset"
targetFile <- "data.zip"
dataPath <- "./data"
targetFilePath <- file.path(dataPath,targetFile)

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
}

# unzip if not already exists
extractedZipPath <- file.path(dataPath, zipDir)
if(!file.exists(targetFilePath) || debug){
  unzip(targetFilePath, exdir=dataPath, overwrite=TRUE)
}

dirList <- list.files(extractedZipPath, recursive=TRUE)
  

# load all train & test .txt files into memory: ignoring the 'Inertial Signals' folders
sanitizedDirList <- dirList[!grepl("Inertial", dirList) & grepl("test|train", dirList)]
for(dataFile in sanitizedDirList){
  # generate parameters based on filesc
  paramName <- paste0("data_", tolower(sub("^.*/([^\\.]+).*$","\\1",dataFile, perl=TRUE)))
  txtFile <- file.path(extractedZipPath, dataFile)
  data <- read.table(txtFile)  
  assign(paramName, data)
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
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
