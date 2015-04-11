# Libraries
library (ggplot2)
library (graphics)
library (knitr)
library (lattice)
library (reshape2)
library (R.oo)
library (R.utils)

# Variables
main_dir <- "~"
main_folder <- "activity"
folder <- "Raw Data"
img <- "img"
img_path <- "~/activity/img"
activity_zip <- "activity.zip"
activity_csv <- "activity.csv"
file_url <- "http://d396qusza40orc.cloudfront.net/repdata/data/activity.zip"
setwd (main_dir)
# Validate and create directory
if (!file.exists (main_folder)) {
        dir.create (main_folder)
        setwd (main_folder)
        if (!file.exists (folder)){
                dir.create (folder)
                dir.create (img)
        }
        setwd (folder)

        # Validate if activity.zip and activity.zip files exist, if not download the .zip file
        if (!file.exists (activity_csv) & !file.exists (activity_zip)) {
                # Download the file
                download.file (url = file_url,
                               destfile = activity_zip,
                               method = "auto"
                )
                unzip (activity_zip)
        }
        else {
                # Validate if the activity.csv file exist
                if (!file.exists (activity_csv)) {
                        unzip (activity_zip)
                }
        }
} else {
        # Setting the working directory
        setwd (main_folder)
        setwd (folder)

        # Validate if activity.zip and activity.zip files exist, if not download the .zip file
        if (!file.exists (activity_csv) & !file.exists (activity_zip)) {
                # Download the file
                download.file (url = file_url,
                               destfile = activity_zip,
                               method = "auto"
                )
                unzip (activity_zip)
        } else {
                # Validate if the activity.csv file exist
                if (!file.exists (activity_csv)) {
                        unzip (activity_zip)
                }
        }
}

setwd (main_dir)
setwd (main_folder)

# Loading and Processing the Data

## Load the info into a data.frame (info_activity)
info_activity <- read.csv (file.path (folder ,activity_csv),
                           header = TRUE,
                           colClasses = c ("numeric",
                                           "Date",
                                           "numeric")
)

## Verifying Data
### head (info_activity)
head (info_activity)

### Structure of data.frame (info_activity) --> str (info_activity)
str (info_activity)

### Summary of data.frame (info_activity) --> summary (info_activity)
summary (info_activity)

# 1. What is mean total number of steps taken per day?

## Calculate the total number of steps taken per day
steps_per_day <- aggregate (steps ~ date,
                            data = info_activity,
                            sum,
                            na.rm = TRUE)
steps_per_day

## Calculate and report the mean and median total number of steps taken per day
mean_steps <- mean (steps_per_day$steps)
median_steps <- median (steps_per_day$steps)

## Make a histogram of the total number of steps taken each day
hist (steps_per_day$steps,
      breaks = 10,
      col = "darkgreen",
      main = "Total Number of Steps Taken each day",
      xlim = c (0,
                25000),
      ylim = c (0 ,
                20),
      xlab = "Steps per day",
      ylab = "Frequency"
)

abline (v = mean_steps,
        col = "blue",
        lwd = 7
)

abline (v = median_steps,
        col = "red",
        lty = 1,
        lwd = 2
)

legend (15000,
        20,
        c ( "mean",
            "median"),
        col = c("blue",
                "red"),
        lty=1,
        lwd = 2
)
dev.copy (png,
          file.path(img_path, "image1.png"),
          width = 640,
          height = 520,
          units = "px"
)
dev.off ()
# What is the average dailiy activity pattern?

## Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis)
## and the average number of steps taken, averaged across all days (y-axis)

### Calculate the average number of steps taken
info_activity_noNA <- info_activity[complete.cases(info_activity),]
average_steps <- as.data.frame (tapply (info_activity_noNA$steps,
                                        INDEX = info_activity_noNA$interval,
                                        FUN = "mean",
                                        na.rm = TRUE)
)

colnames (average_steps) <- "average_steps"
average_steps$interval <- rownames (average_steps)
row.names (average_steps) <- NULL

head (average_steps)

### Time series plot
plot (average_steps$interval,
      average_steps$average_steps,
      type = "l",
      col = "darkblue",
      main = "Time Series Plot",
      xlab = "Interval (5-minutes)",
      ylab = "Average steps accross all days"
)

## Which 5-minute interval, on average across all the days in the dataset,
## contains the maximum number of steps?
max_steps <- which.max (average_steps$average_steps)# == average_steps$average_steps
which_max_steps <- as.integer (average_steps[max_steps,"interval"])

abline (v = which_max_steps,
        col = "red",
        lty = 2,
        lwd = 4
)

legend (900,
        200,
        legend = paste ("Max Steps Interval = ", which_max_steps),
        col = c("red"),
        lty= 1,
        lwd = 4
)

dev.copy (png,
          file.path(img_path, "image2.png"),
          width = 640,
          height = 520,
          units = "px"
)
dev.off ()
# Imputing missing values

## Calculate and report the total number of missing values in the dataset
## (i.e. the total number of rows with NAs)
total_NAs <- sum (is.na (info_activity))

## Devise a strategy for filling in all of the missing values in the dataset.
## The strategy does not need to be sophisticated.
## For example, you could use the mean/median for that day,
##  or the mean for that 5-minute interval, etc.

## Create a new dataset that is equal to the original dataset
##  but with the missing data filled in.
info_activity_steps <- dcast (info_activity,
                              interval ~ date,
                              fill = 0,
                              value.var = "steps"
)
info_activity_steps_full <- dcast (info_activity,
                                   interval ~ date,
                                   fill = rowMeans (info_activity_steps, na.rm = TRUE),
                                   value.var = "steps"
)
average_steps_mean <- as.data.frame(reshape (info_activity_steps_full,
                                             varying = list ( names (info_activity_steps_full [2:length (names (info_activity_steps_full))])),
                                             v.names = c ("steps"),
                                             timevar = "date",
                                             idvar = c ("interval"),
                                             times = names (info_activity_steps_full) [2:length (names (info_activity_steps_full))],
                                             direction = "long",
                                             new.row.names = 1:dim(info_activity)[1]
))

average_steps_mean$date <- as.Date (average_steps_mean$date, "%Y-%m-%d")

## Make a histogram of the total number of steps taken each day and Calculate and report
##  the mean and median total number of steps taken per day.
## Do these values differ from the estimates from the first part of the assignment?
## What is the impact of imputing missing data on the estimates of the total daily number of steps?
steps_per_day_mean <- aggregate (steps ~ date,
                                 FUN = sum,
                                 data = average_steps_mean,
                                 na.rm = TRUE
)

hist (steps_per_day_mean$steps,
      breaks = 10,
      col = "darkgreen",
      main = "Total Number of Steps Taken each day",
      xlim = c (0,
                25000),
      ylim = c (0 ,
                20),
      xlab = "Steps per day",
      ylab = "Frequency"
)

mean_steps_per_day_mean <- mean (steps_per_day_mean$steps)
median_steps_per_day_mean <- median (steps_per_day_mean$steps)

abline (v = mean_steps,
        col = "black",
        lwd = 7
)

abline (v = median_steps,
        col = "orange",
        lty = 1,
        lwd = 2
)

abline (v = mean_steps_per_day_mean,
        col = "darkblue",
        lwd = 7
)

abline (v = median_steps_per_day_mean,
        col = "red",
        lty = 1,
        lwd = 2
)

legend (15000,
        20,
        c ( paste ("mean1 = ", round (mean_steps,2)),
            paste ("mean2 = ", round (mean_steps_per_day_mean,2)),
            "",
            paste ("median1 = ", median_steps),
            paste ("median2 = ", median_steps_per_day_mean)
        ),
        col = c("black",
                "darkblue",
                "000",
                "orange",
                "red"),
        lty=1,
        lwd = 2
)
dev.copy (png,
          file.path(img_path, "image3.png"),
          width = 640,
          height = 520,
          units = "px"
)
dev.off ()
# Are there differences in activity patterns between weekdays and weekends?

## Create a new factor variable in the dataset with two levels – “weekday” and “weekend”
##   indicating whether a given date is a weekday or weekend day.

size_frame <- nrow (average_steps_mean)
for (i in 1:size_frame) {
        if (weekdays (average_steps_mean$date[i]) %in% c ("Saturday", "Sunday")) {
                average_steps_mean$day_type[i] <- "weekend"
        }
        else {
                average_steps_mean$day_type[i] <- "weekday"
        }
}
##  Make a panel plot containing a time series plot (i.e. type = "l")
##   of the 5-minute interval (x-axis) and the average number of steps taken,
##   averaged across all weekday days or weekend days (y-axis).
## See the README file in the GitHub repository to see an example
##   of what this plot should look like using simulated data.

steps_time_series <- aggregate (steps ~ interval + day_type,
                                data = average_steps_mean,
                                FUN = mean
)

day_type_mean <- aggregate (average_steps_mean$steps,
                            by = list (average_steps_mean$day_type),
                            FUN = mean,
                            na.rm = TRUE
)

colnames (day_type_mean) <- c ("day_type", "mean")
weekdays_mean <- round (day_type_mean[1,2], 2)
weekend_mean <- round (day_type_mean[1,2], 2)

xyplot (steps ~ interval | day_type,
        steps_time_series,
        type = "l",
        layout = c (1,
                    2
        ),
        main = "Time Series Plot - Weekdays Vs Weekend",
        xlab = "5-minutes interval",
        ylab = "Average Number of Steps Taken",
)

dev.copy (png,
          file.path(img_path, "image4.png"),
          width = 640,
          height = 520,
          units = "px"
)
dev.off ()
