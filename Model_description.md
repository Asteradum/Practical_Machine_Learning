Practical Machine Learning Project
==================================

author: Alvaro Martin Orive

The purpose of this document is to describe the machine learning
algorithm used, with the steps taken to define it.

AS we are trying to solve a classification problem, the algorithm used
is Random Forest. This algorithm needs lots of computational time, but
is very accurate and due to the nature of the algorithm it is not
necessary to cross-validate for avoiding overfitting.

First we load the data. After a bit of analyis, there are values that
should be considered as NA, otherwise R will load it the columns as
Factors. Also, we will take care of all the columns with NA values.
After some checking, the values that contain NA is because most of their
values are NA.

    set.seed(12345)

    training <- read.csv(file = "pml-training.csv", na.strings = c("", "NA" , "#DIV/0!" ), stringsAsFactors=FALSE)
    testing <- read.csv(file = "pml-testing.csv", na.strings = c("", "NA" , "#DIV/0!" ), stringsAsFactors=FALSE)

    # drop any column with NA values
    training2 <- training[,colSums(is.na(training)) == 0]

Cleaning Data
-------------

After a further analysis, I decided to take out from the predictors the
following variables:

-   rowid (X variable)
-   new\_window
-   num\_window
-   cvtd\_timestamp
-   raw\_timestamp\_part\_1
-   raw\_timestamp\_part\_2

Variables *rowid* and *num\_window* won't reflect the reality of the
situation as the movements have been done sequentially and the algorithm
will classified strongly using these variables.

For variables *cvtd\_timestamp*, *raw\_timestamp\_part\_1* and
*raw\_timestamp\_part\_2*: lifting quality does not depend on the time
of the day. It might affect (i.e: tireness) but the time refering here
do not represent it.

Variable *new\_window* classifies the time windows measured and if this
value changes some variables adquire different value. However, the rest
of the time, this value has NA value, so right now is useless.

    drops <- c("X", "cvtd_timestamp", "raw_timestamp_part_1", "raw_timestamp_part_2", "new_window", "num_window")

    training2 <- training2[,!(colnames(training2) %in% drops)]

As we can observe that the user\_name and classe (outcome) are not
factors, but chars, so their class are modified.

    str(training2$user_name)

    ##  chr [1:19622] "carlitos" "carlitos" "carlitos" "carlitos" ...

    str(training2$classe)

    ##  chr [1:19622] "A" "A" "A" "A" "A" "A" "A" "A" "A" ...

    # Change values to Factor
    training2$user_name <- as.factor(training2$user_name)
    training2$classe <- as.factor(training2$classe)

Preprocessing
-------------

WE are going to run two models, one with preprocess and another one
without. All the variables here are numeric, so we will process by
centering and scaling the values.

Training and cross-validation
-----------------------------

As said previously, there is no need to cross-validate using Random
Forests. We will use caret default parameters.

    modelFit <- train(classe~., method = "rf", data = training2)
    # Train model with Preprocessing, centering and scaling the values.
    modelFitPP <- train(classe~., method = "rf", preProcess = c("center", "scale"), data = training2)

Results
-------

    modelFit$results

    ##   mtry  Accuracy     Kappa  AccuracySD     KappaSD
    ## 1    2 0.9923574 0.9903287 0.001384898 0.001752297
    ## 2   29 0.9928290 0.9909263 0.001333014 0.001684494
    ## 3   57 0.9842569 0.9800775 0.003818310 0.004835964

    modelFitPP$results

    ##   mtry  Accuracy     Kappa  AccuracySD     KappaSD
    ## 1    2 0.9921803 0.9901090 0.001592058 0.002013493
    ## 2   29 0.9924563 0.9904581 0.001639942 0.002074161
    ## 3   57 0.9847110 0.9806610 0.004058522 0.005133457

As we can see, the acurracy without preprocessing is slightly higher.
Therefore, the model without preprocessing will be used in the test set.
No errors are expected running the test, as the model has almos t
aperfect accuracy.

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
