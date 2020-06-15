library(sparklyr)
sc <- spark_connect("yarn-client")

#connecting to the azure storage on the created cluster.
azure_storage_path <- file.path("wasb://bdaclusterstore@bdaclusterhdistorage1.blob.core.windows.net",
                                "user/sshuser/csvfiles")

# Reading the test and the train data from the files in azure storage.(1m dataset)
test_data <- spark_read_csv(sc, path = azure_storage_path,
                            name = 'test', delimiter = ",")

train_data <- spark_read_csv(sc, path = azure_storage_path,
                             name = 'train1m', delimiter = ",")

# Model Training and Calculating the time taken for model training. 
# Parameters defined are:
##  number_of_trees = 100
##  max_bins        = 20
##  max_depth       = 50
##  impurity        = gini

system.time({
  model <- train_data %>%
    ml_random_forest(dep_delayed_15min ~ ., type = "classification", impurity = "gini",
                     max_bins = 20, max_depth = 50,
                     num_trees = 100)
})

# Prediction with the test dataset.
predict <- sdf_predict(model, test_data)

# Calcualting accuarcy of the model.
ml_classification_eval(predict, "dep_delayed_15min", "prediction", metric = "accuracy")

# Calcualting AUC of the model.
ml_binary_classification_eval(predict, "dep_delayed_15min", "prediction", metric = "areaUnderROC")

# Calculating the MSE and RMSE of the model.
sq_resid <- transform(predict, sq_residuals = (predict$dep_delayed_15min - predict$prediction)^2)
MSE <- collect(summarize(sq_resid, mean = mean(sq_resid$sq_residuals)))$mean
RMSE <- sqrt(MSE)


