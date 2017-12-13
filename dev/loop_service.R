## Need to re-point working directory to the location where this script is saved
setwd("~/GitHub/loop_service/dev")

## Extract Zip-files to CSV format. Save in Data folder.
baseline_zip_file <- "../Data/baseline.csv.zip"
unzip(baseline_zip_file,exdir = "../Data")

stream_zip_file <- "../Data/stream.csv.zip"
unzip(stream_zip_file,exdir = "../Data")


## Install any required R Packages
packages <- c("readr","dplyr","stringr","tidyr","gbm","ggplot2","corrplot")
install.packages.set.repos <- function(package_name){
  install.packages(package_name, repos="https://cloud.r-project.org")
}
s <- suppressWarnings(
  lapply(packages,install.packages.set.repos)
)


## Load packages
packages <- c("readr","dplyr","stringr","tidyr","randomForest","rpart","ggplot2","corrplot")
s <- suppressWarnings(
  lapply(packages,library,character.only = TRUE)
)


## Read in the data
baseline <- read_csv(file = "../Data/baseline.csv") %>%
  rename(id = X1)
stream <- read_csv(file = "../Data/stream.csv") %>%
  rename(id = X1)


## Update the baseline data to remove missing annual income and loan amount records
## Assumption:  these are not completed applications
baseline <- baseline %>% 
  filter(!is.na(annual_inc)) %>%
  filter(!is.na(loan_amnt))

## Count the records remaining
N <- baseline %>% tally()
N



## Data by verification status

verification_table <- baseline %>%
  group_by(verification_status) %>%
  summarise(total_amnt = sum(loan_amnt),
            number_applications = n(),
            avg_dti = mean(dti,na.rm=T),
            avg_income = mean(annual_inc),
            med_income = median(annual_inc),
            avg_loan_amnt = mean(loan_amnt)) %>%
  mutate(app_freq = number_applications/sum(number_applications)) %>%
  mutate(amnt_freq = total_amnt/sum(total_amnt))

verification_table


## Default or Charged Off loans by verification status
verification_default_table <- baseline %>%
  filter(loan_status=="Default"|loan_status=="Charged Off")%>%
  group_by(verification_status) %>%
  summarise(total_amnt = sum(loan_amnt),
            number_applications = n(),
            avg_dti = mean(dti,na.rm=T),
            avg_income = mean(annual_inc),
            avg_loan_amnt = mean(loan_amnt))

verification_default_table


## Incoming stream of applications for comparison
## Remove missing income data from stream dataset

stream <- stream %>% 
  filter(!is.na(annual_inc))

stream %>%
  group_by(verification_status) %>%
  summarise(
    number_applications = n(),
    avg_dti = mean(dti,na.rm=T),
    avg_income = mean(annual_inc,na.rm=T),
    med_income = median(annual_inc,na.rm=T)) %>%
  mutate(prop_n = number_applications/sum(number_applications))

stream %>% tally()


## Variable selection
## Top-down rules:
## - remove any information that we would not know prior to granting loan
## - remove any information directly tied to income, e.g. DTI
## - remove any ratios, which are inherently related to other vars in set

## Select just numeric data
baseline_numeric <- baseline %>% 
  select(which(sapply(., is.numeric))) %>%
  select(-dti,-loan_amnt,-funded_amnt,-funded_amnt_inv,-bc_util,-recoveries) %>% ## remove fields not available in new apps
  replace(is.na(.), 0) %>% ## fill in missing data
  arrange(id) %>%
  select(-id)


cor_matrix <- cor(baseline_numeric,use="pairwise")
corrplot(cor_matrix,tl.cex=.5,tl.col=1,type="upper",method="square",order="FPC")
## indicates that as expected multicollinearity is present


## On read, R misclassified several numeric columns, which are converted here
baseline_mistyped <- baseline %>%
  select(total_bal_il, max_bal_bc, revol_util, mths_since_rcnt_il, il_util, 
         all_util, open_acc_6m, open_rv_12m, open_rv_24m, inq_last_12m,
         total_cu_tl,open_il_6m, open_il_12m, open_il_24m, inq_fi) %>%
  mutate(revol_util = gsub("%","",revol_util,fixed=T)) %>%
  mutate_all(as.numeric) %>% ## convert to numeric
  replace(is.na(.), 0) ## clean up missing values, replacing with 0

baseline_factor <- baseline %>%
  select(which(sapply(., is.character))) %>%
  select(-int_rate,-total_bal_il, -max_bal_bc, -revol_util, -mths_since_rcnt_il, 
         -il_util, -all_util, -open_acc_6m, -open_rv_12m, -open_rv_24m, 
         -inq_last_12m,-total_cu_tl,-open_il_6m, -open_il_12m, -open_il_24m, -inq_fi) %>%
  select(-loan_status,-grade) %>% ## removed because it is not in the streaming set
  select(-zip_code,-earliest_cr_line) %>% ## removed because randomForest has structural limitation with diverse categorical variables
  replace(is.na(.),"unknown") %>% ## clean up missing data
  mutate(emp_title = toupper(emp_title)) %>% ## clean up free-entry job-title field (a little)
  mutate_all(as.factor) ## convert to factor - categorical variable data type

## Recombine the typed datasets
baseline_for_model <- bind_cols(baseline_numeric,baseline_factor,baseline_mistyped) %>%
  select(-desc,-term,-emp_title,-title,-pymnt_plan,-installment)

## Do the same for the stream data
stream_numeric <- stream %>% 
  select(which(sapply(., is.numeric))) %>%
  select(-dti,-bc_util) %>%
  replace(is.na(.), 0)

stream_mistyped <- stream %>%
  select(revol_util) %>%
  mutate(revol_util = gsub("%","",revol_util,fixed=T)) %>%
  mutate_all(as.numeric) %>%
  replace(is.na(.), 0)

stream_factor <- stream %>%
  select(which(sapply(., is.character))) %>%
  select(-revol_util) %>%
  replace(is.na(.),"unknown") %>%
  mutate(emp_title = toupper(emp_title)) %>%
  mutate_all(as.factor)

stream_for_model <- bind_cols(stream_numeric,stream_factor,stream_mistyped)



## Variable importance using random forest
## Due to memory constraints on my laptop, I've had to reduce the size of each tree and number of trees
## this could be 'beefed up' in a v2
set.seed(1)
rf <- randomForest(annual_inc ~ ., data = baseline_for_model, ntree=250, maxnodes=4)
var_imp <- rf$importance[sort.list(rf$importance,decreasing=TRUE),]
var_imp[var_imp > 0]

## Forms the model of the most important columns found via the random forest method and the 
## specific variables 'purpose', 'verification_status', and 'emp_length' based on conversation with Andrew
model_call = as.formula(paste("annual_inc ~ ",
                              paste(unique(c(names(rf$importance[rf$importance>0,]),"purpose","verification_status","emp_length")),
                                    collapse="+")))



## Fit a regression tree model
# Preferential because of interpretability and compute resources
rpart_fit <- rpart(model_call, data = baseline_for_model, control = rpart.control(cp = 0.001)) 

## drop the cp to get a more complex tree


## Add residuals and predictions from regression tree to the data stream
stream_for_model <- stream_for_model %>%
  mutate(pred_rpart = predict(rpart_fit,newdata=stream_for_model)) %>%
  mutate(resid_rpart = annual_inc - predict(rpart_fit,newdata=stream_for_model))

## Print the average residual for each verification status
stream_for_model %>%
  group_by(verification_status) %>%
  summarise(avg_resid = mean(resid_rpart,na.rm=T))


## Identify outliers using Boxplot methodology (outlier = 75th percentile + 1.5*IQR)
## Count the outliers
stream_for_model %>%
  filter((verification_status == "unknown" | verification_status == "Unverified") 
         & resid_rpart > quantile(resid_rpart) + 1.5*IQR(resid_rpart)) %>%
  tally()

## Print the outliers
stream_for_model %>%
  filter((verification_status == "unknown" | verification_status == "Unverified") 
         & resid_rpart > quantile(resid_rpart) + 1.5*IQR(resid_rpart)) %>%
  select(id,purpose,verification_status,annual_inc,pred_rpart,resid_rpart) %>%
  arrange(desc(resid_rpart))