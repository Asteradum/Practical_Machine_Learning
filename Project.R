#install.packages("doParallel")
library(doParallel)
library(caret)
registerDoParallel(cores=5)

#this.dir <- dirname(parent.frame(2)$ofile)
#setwd(this.dir)

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

modelFit <- train(classe~., method = "rf", data = training2)
# Train model with Preprocessing, centering and scaling the values.
modelFitPP <- train(classe~., method = "rf", preProcess = c("center", "scale"), data = training2)

modelFit$results
modelFitPP$results

# The model works better without preprocessing

# Cross-validation
# There is no needs to use cross-validation if using random forest, as the algorithm itself creates multiple trees
# Random forest avoids overfitting.


# Check which ones were errors
check <- predict(modelFit,training2)
errors <- training2[training2$classe != check,]
errors

# Testing
answers <- predict(modelFit,testing)

# delivery
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}
pml_write_files(answers)