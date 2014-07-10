# Code Book
generated 2014-07-10 10:07:36 during sourcing of `run_analysis.R`

## Actions performed on data:
* create data dir `./data`
* downloading zip file: `https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip` to `./data`
* extracting zip file: `./data/UCI HAR Dataset` to `./data`
* merging all *_test.txt and *_train.txt files into one dataset: `mergedData`
* `mergedData` loaded in memory, dimensions: 10299 x 563
* subsetted `mergedData` into `subSetMergedData` keeping only the key columns and features containing `std` or `mean`, dimensions : 10299 x 68
* merged `./data/UCI HAR Dataset/activity_labels.txt` contents with correct `activity_num` column, effectivly appending `activity_name` to `subSetMergedData`, dimensions : 10299 x 69
* melt `subSetMergedData` into `reshapedData`, based on key columns, dimensions : 679734 x 5
* split feature column `variable` into 7 seperate colums (for each sub feature), and added it to `reshapedData`, dimensions : 679734 x 12
* renamed `reshapedData` to `resultData`
* cast `resultData` into `tidyData` with the average of each variable for each activity and each subject dimensions :180 x 68
* write `tidyData` to file  `./data/tidy_data.txt`
## `reshapedData` variable

### key columns

* `subject`
* `activity_name`
* `activity_num`
