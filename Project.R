#install.packages("doParallel")
library(doParallel)
library(caret)
registerDoParallel(cores=5)

# setwd("C:/Users/User/Documents/Coursera/Practical_Machine_Learning/CourseProject")

# import numbers as numeric (imported as factor by default) and clean trash values
training <- read.csv(file = "pml-training.csv", na.strings = c("", "NA" , "#DIV/0!" ), stringsAsFactors=FALSE)
testing <- read.csv(file = "pml-testing.csv", na.strings = c("", "NA" , "#DIV/0!" ), stringsAsFactors=FALSE)

# drop any column with NA values
training2 <- training[,colSums(is.na(training)) == 0]

# drop rowid, new_window, num_window, cvtd_timestamp, raw_timestamp_part_1, raw_timestamp_part_2.
# Drop rowid and num_window as the movements have been done sequentially will give a overfitting.
# lifting quality does not depend on the time of the day (it might, i.e: tireness) but the time refering here do not represent that
# new_window classifies the time windows measured.

drops <- c("X", "cvtd_timestamp", "raw_timestamp_part_1", "raw_timestamp_part_2", "new_window", "num_window")

training2 <- training2[,!(colnames(training2) %in% drops)]
# Change values to Factor
training2$user_name <- as.factor(training2$user_name)
training2$classe <- as.factor(training2$classe)


#Preprocess? Which one is best?
# Cross-validation
#Check which ones were errors


modelFitPP <- train(classe~., method = "rf", preProcess = c("center", "scale"), data = training2)

testing2 <- testing[,colnames(testing) %in%colnames(training2)]
predictTest <- predict(modelFit,testing2)
modelFit$finalModel
# result <- predict(modelFit, training2)
# correct <- result == training2$classe
# wrongvalues <- training2[!correct,]
# unique(correct)
