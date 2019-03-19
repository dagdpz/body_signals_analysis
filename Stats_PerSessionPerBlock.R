# 0. load the following installed packages
rm(list=ls())
library("lme4")
library("ggplot2")
library("gridExtra")
library("ggsignif")
library("emmeans")
library(tidyr)


## 1. clean the workspace
rm(list=ls())
## 2. load the data
setwd("/Users/kristinkaduk/Dropbox/promotion/Projects/BodySignal_Pulvinar/Data/")
Dataset = read.table("Table_HeartrateVaribility_PerSessionPerBlock.txt",header = TRUE)
head(Dataset)

# 3. statistic
Dataset$Experiment <- relevel(Dataset$Experiment, ref="Control")
Dataset$Injection  <- relevel(Dataset$Injection, ref="pre")
Dataset$TaskType   <- relevel(Dataset$TaskType, ref="rest")

Variables = c( which(colnames(Dataset) == "mean_R2R_valid_bpm"),which(colnames(Dataset) == "median_R2R_valid_bpm"),
               which(colnames(Dataset) == "rmssd_R2R_valid_ms"),  which(colnames(Dataset) == "std_R2R_valid_bpm"),  
               which(colnames(Dataset) == "lfPower"),  which(colnames(Dataset) == "hfPower")) 
#indV = 8
#Dataset_Task = subset(Dataset, Dataset$TaskType == unique(Dataset$TaskType)[2])
#LM_2Inter = lm(Dataset_Task[ , indV] ~  Experiment * Injection   , data = Dataset_Task)
#summary(LM_2Inter)
## PREPARE DATASET to compare between Blocks


# indV = 2
tabl_MultCom_ConfiInterval = c(); 
tabl_MultCom_pValues       = c(); 
for(indV in Variables){
  #for(indV in Variables){  
LM_3Inter = lm(Dataset[ , indV] ~  Experiment * Injection * TaskType  , data = Dataset)
Anova_3Inter = aov(Dataset[ , indV] ~  Experiment * Injection * TaskType  , data = Dataset)
#summary(LM_3Inter)
AnovaTable = anova(LM_3Inter)
#summary(Anova_3Inter)

c = emmeans(LM_3Inter, pairwise~ Experiment * Injection * TaskType ,Interaction = F,  adjust="fdr")$contrasts
c = data.frame(summary(c))
c[2:6] = round(c[2:6], digits = 4)
c$Variable = rep(colnames(Dataset)[indV], length(c$estimate))

# split the comparision into variables 
for (indCon in 1: length(c$contrast)){ 
  c$Comparison1[indCon]         = strsplit(as.character(c$contrast), split=' - ', fixed=TRUE)[[indCon]][1]
  c$Comparison2[indCon]         = strsplit(as.character(c$contrast), split=' - ', fixed=TRUE)[[indCon]][2]
  c$Experiment_Comp1[indCon]    = strsplit(as.character(c$Comparison1), split=',', fixed=TRUE)[[indCon]][1]
  c$Injection_Comp1[indCon]     = strsplit(as.character(c$Comparison1), split=',', fixed=TRUE)[[indCon]][2]
  c$TaskType_Comp1[indCon]      = strsplit(as.character(c$Comparison1), split=',', fixed=TRUE)[[indCon]][3]
  c$Experiment_Comp2[indCon]    = strsplit(as.character(c$Comparison2), split=',', fixed=TRUE)[[indCon]][1]
  c$Injection_Comp2[indCon]     = strsplit(as.character(c$Comparison2), split=',', fixed=TRUE)[[indCon]][2]
  c$TaskType_Comp2[indCon]      = strsplit(as.character(c$Comparison2), split=',', fixed=TRUE)[[indCon]][3]
  }
c_emmeans = emmeans(LM_3Inter, pairwise~ Experiment * Injection * TaskType ,Interaction = F,  adjust="fdr")$emmeans
c_emmeans = data.frame(summary(c_emmeans))
c_emmeans$Variable = rep(colnames(Dataset)[indV], length(c_emmeans$Experiment))

write.table(AnovaTable,paste0(colnames(Dataset)[indV], "_Anova_PValues_HeartrateVaribility_PerSession.txt") ,quote=F,row.names=F,dec=".",sep="\t")

tabl_MultCom_pValues = rbind(tabl_MultCom_pValues, c) 
tabl_MultCom_ConfiInterval = rbind(tabl_MultCom_ConfiInterval, c_emmeans) 

}

source('/Users/kristinkaduk/Dropbox/promotion/Projects/BodySignal_Pulvinar/body_signals_analysis/@AddStarBasedPValues.R')
tabl_MultCom_pValues$Star =  AddStarBasedPValues(tabl_MultCom_pValues$p.value)

## transform to matlab-file
library(R.matlab)
writeMat("MultComp_PValues_HeartrateVaribility_PerSession.mat", tabl_MultCom_pValues_Data=tabl_MultCom_pValues)

setwd("/Users/kristinkaduk/Dropbox/promotion/Projects/BodySignal_Pulvinar/Data/")
write.table(tabl_MultCom_pValues,"MultComp_PValues_HeartrateVaribility_PerSession.txt" ,quote=F,row.names=F,dec=".",sep="\t")
#write.table(tabl_MultCom_ConfiInterval,"ConfidenceInterval_DF_HeartrateVaribility_PerSession.txt" ,quote=F,row.names=F,sep="\t")



