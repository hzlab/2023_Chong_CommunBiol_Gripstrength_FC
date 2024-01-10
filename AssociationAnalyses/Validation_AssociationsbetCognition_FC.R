# Validation: Perform linear regression to examine the association between functional connectivity and cognition, additionally controlling for various nuisance covariates

# Inputs to the script:
# 1) demofile: name and path of spreadsheet containing demographic, cognition and handgrip strength data
# 2) FCfile: name and path of spreadsheet containing functional connectivity measures
# 3) outputfile: name and path of output spreadsheet containing results of the linear regression analyses
# 4) cognitivevar: names of all cognitive variables examined
# 5) functiondir: path of folder containing function file "RunLM_Functions.R"
# 6) nuisancecov: names of all additional nuisance covariates examined

# Clear variables
rm (list = ls())

# Specify paths (CHANGE THIS!!)
demofile = '/XXX/SampleData/Demographic.csv'
FCfile = '/XXX/SampleData/Handgripstrength-relatedFCmeasures.csv'
outputfile = '/XXX/AssociationAnalyses/Validation_Assoc_FC_cognition.csv'
cognitivevar = c('GlobalCog_T','SOP_T','Attention_T','EF_T','MMSE')
functiondir = '/XXX/AssociationAnalyses/RunLM_Functions.R'
nuisancecov = c('waisthipratio','bmi','gds','MMSE','GMV')

# Read spreadsheet containing demographic, cognition and handgrip strength data
demo = read.csv(demofile)

# Read spreadsheet containing functional connectivity measures and extract the names of all functional connectivity measures 
FC = read.csv(FCfile)
Varnames=colnames(FC[,c(2:ncol(FC))])

# Merge data spreadsheets together
data=merge(demo,FC,by = c('SubID'))

# Convert specified columns to numeric
data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE','TIV','waisthipratio','bmi','gds','timeinterval_days','GMV')] <- lapply(data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE','TIV','waisthipratio','bmi','gds','timeinterval_days','GMV')], as.numeric)

# Call function file
source(functiondir)

# Run linear regression model for each cognitive variable, for each functional connectivity measure and for each nuisance covariate
for (n in 1:length(nuisancecov)){
  for (i in 1:length(Varnames)){
    
    if (nuisancecov[n]=="MMSE"){
      cognitivevar2=cognitivevar[cognitivevar != "MMSE"]
    } else {
      cognitivevar2=cognitivevar
    }
    
    for (c in 1:length(cognitivevar2)){
      rm("data.copy","y","summary.y","templm")
      
      # Assign the cognitive variable of interest as a new variable "cog" in the dataframe and remove any rows with infinite or NaN values
      data.copy = data
      data.copy$cog = data.copy[, paste(cognitivevar2[c], sep='')]
      data.copy = subset(data.copy, !is.na(cog) & !is.nan(cog) & !is.infinite(cog))      
      
      # Assign the functional connectivity variable of interest as a new variable "FC" in the dataframe and remove any rows with infinite or NaN values
      data.copy$FC = data.copy[, paste(Varnames[i], sep='')]
      data.copy = subset(data.copy, !is.na(FC) & !is.nan(FC) & !is.infinite(FC))
      
      # Assign the nuisance covariate of interest as a new variable "cov" in the dataframe and remove any rows with infinite or NaN values
      data.copy$cov = data.copy[, paste(nuisancecov[n], sep='')]
      data.copy = subset(data.copy, !is.na(cov) & !is.nan(cov) & !is.infinite(cov))
      
      # Convert functional connectivity variable to numeric
      if (class(data.copy$FC) != "numeric"){
        data.copy$FC=as.numeric(data.copy$FC)
      }
      
      #Centre variables
      data.copy$FC.centered=scale(data.copy$FC,scale = F)
      data.copy$Age.centered=scale(data.copy$Age,scale = F)
      data.copy$Education.centered=scale(data.copy$Education,scale = F)
      data.copy$TIV.centered=scale(data.copy$TIV,scale = F)
      data.copy$cov.centered=scale(data.copy$cov,scale = F)
      
      # Run linear regression model
      if (nuisancecov[n] == "GMV"){
        y=lm(cog~FC.centered + Age.centered + Gender + Education.centered + cov.centered, data=data.copy)
        
      } else {
        y=lm(cog~FC.centered + Age.centered + Gender + Education.centered + cov.centered + TIV.centered, data=data.copy)
      }
      
      # Summarize outputs (only for predictor of interest - functional connectivity) in a dataframe
      summary.y=as.data.frame(summary(y)$coefficients)
      templm=GetSummary(summary.y,"FC.centered",c("Estimate","Std. Error","t value","Pr(>|t|)"),cognitivevar2[c])
      templm=data.frame(Dependent = cognitivevar2[c], Predictor = Varnames[i], Covariate = nuisancecov[n], n = nrow(data.copy), templm, Rsquared = summary(y)$r.squared)
      colnames(templm)=c('Dependent','Predictor','Covariate','n','Estimate','SE','tStat','pValue','Rsquared')
      
      # Append results together in one dataframe
      if (c==1){ 
        excel.summarylm=templm
      } else {
        excel.summarylm=rbind(excel.summarylm,templm)
      }
    }
    
    # Perform FDR correction across all cognitive variables
    excel.summarylm$adjpValue=p.adjust(excel.summarylm$pValue, method = "BH")
    
    # Append all results together in one dataframe
    if (i==1 & n==1){ 
      excel.Allsummarylm=excel.summarylm
    } else {
      excel.Allsummarylm=rbind(excel.Allsummarylm,excel.summarylm)
    }
    rm("excel.summarylm")
    
    
  }
}

# Write output to csv
write.csv(excel.Allsummarylm, file=outputfile, row.names=FALSE)
