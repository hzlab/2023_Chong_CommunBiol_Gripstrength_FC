# Validation: Perform linear regression to examine the association between functional connectivity measure and handgrip strength, additionally controlling for various nuisance covariates

# Inputs to the script:
# 1) demofile: name and path of spreadsheet containing demographic, cognition and handgrip strength data
# 2) FCfile: name and path of spreadsheet containing functional connectivity measures
#    This spreadsheet could be the segregation measures ("Segregationmeasures.csv"), 
#    salience/ventral attention inter- and intra-network FC measures ("SVA_InterIntraNetworkFCmeasures.csv"), or
#    salience/ventral attention regional FC measures ("SVA_IntraNetworkRegionalFCmeasures.csv")
# 3) outputfile: name and path of output spreadsheet containing results of the linear regression analyses
#    e.g., FCfile: "Segregationmeasures.csv",  outputfile = "Validation_Assoc_handgripstrength_segregation.csv"
#          FCfile: "SVA_InterIntraNetworkFCmeasures.csv",  outputfile = "Validation_Assoc_handgripstrength_SVAinterintraFC.csv"
#          FCfile: "SVA_IntraNetworkRegionalFCmeasures.csv",  outputfile = "Validation_Assoc_handgripstrength_SVAintraregionalFC.csv"
# 4) functiondir: path of folder containing function file "RunLM_Functions.R"
# 5) nuisancecov: names of all additional nuisance covariates examined

# Clear variables
rm (list = ls())

# Specify paths (CHANGE THIS!!)
demofile = '/XXX/SampleData/Demographic.csv'
FCfile = '/XXX/SampleData/Segregationmeasures.csv'
outputfile = '/XXX/AssociationAnalyses/Validation_Assoc_handgripstrength_segregation.csv'
functiondir = '/XXX/AssociationAnalyses/RunLM_Functions.R'
nuisancecov = c('waisthipratio','bmi','gds','MMSE','timeinterval_days','GMV')

# Read spreadsheet containing demographic, cognition and handgrip strength data
demo = read.csv(demofile)

# Read spreadsheet containing functional connectivity measures and extract the names of all functional connectivity measures 
FC = read.csv(FCfile)
Varnames=colnames(FC[,c(2:ncol(FC))])

# Merge data spreadsheets together
data=merge(demo,FC,by = c('SubID'))

# Convert specified columns to numeric
data[, c('Age','Education','handgripstrength','TIV','waisthipratio','bmi','gds','MMSE','timeinterval_days','GMV')] <- lapply(data[, c('Age','Education','handgripstrength','TIV','waisthipratio','bmi','gds','MMSE','timeinterval_days','GMV')], as.numeric)

# Call function file
source(functiondir)

# Run linear regression model for each functional connectivity measure and for each nuisance covariate
for (n in 1:length(nuisancecov)){
  for (i in 1:length(Varnames)){
    rm("data.copy","y","summary.y","templm")
    
    # Assign the functional connectivity variable of interest as a new variable "FC" in the dataframe and remove any rows with infinite or NaN values
    data.copy = data
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
    data.copy$Age.centered=scale(data.copy$Age,scale = F)
    data.copy$Education.centered=scale(data.copy$Education,scale = F)
    data.copy$handgripstrength.centered=scale(data.copy$handgripstrength,scale = F)
    data.copy$TIV.centered=scale(data.copy$TIV,scale = F)
    data.copy$cov.centered=scale(data.copy$cov,scale = F)
    
    # Run linear regression model
    if (nuisancecov[n] == "GMV"){
      y=lm(FC~handgripstrength.centered + Age.centered + Gender + Education.centered + cov.centered, data=data.copy)
    } else {
      y=lm(FC~handgripstrength.centered + Age.centered + Gender + Education.centered + cov.centered + TIV.centered, data=data.copy)
    }
    
    # Summarize outputs (only for predictor of interest - handgrip strength) in a dataframe
    summary.y=as.data.frame(summary(y)$coefficients)
    templm=GetSummary(summary.y,"handgripstrength.centered",c("Estimate","Std. Error","t value","Pr(>|t|)"),Varnames[i])
    templm=data.frame(Dependent = 'handgripstrength',Predictor= Varnames[i], Covariate = nuisancecov[n], n = nrow(data.copy), templm, Rsquared = summary(y)$r.squared)
    colnames(templm)=c('Dependent','Predictor','Covariate','n','Estimate','SE','tStat','pValue','Rsquared')
    
    # Append results together in one dataframe
    if (i==1){ 
      excel.summarylm=templm
    } else {
      excel.summarylm=rbind(excel.summarylm,templm)
    }
  }
  
  # Perform FDR correction across all functional connectivity measures
  if (grepl("Segregation", FCfile)){
    # For segregation measures, correction is done across all network-level measures (i.e., excluding global segregation measure)
    excel.summarylm$adjpValue[excel.summarylm$Predictor == "Global"]=excel.summarylm$pValue[excel.summarylm$Predictor == "Global"]
    excel.summarylm$adjpValue[excel.summarylm$Predictor %in% Varnames[Varnames  != 'Global']] = 
      p.adjust(excel.summarylm$pValue[excel.summarylm$Predictor %in% Varnames[Varnames  != 'Global']], method = "BH")
    
  } else {
    excel.summarylm$adjpValue=p.adjust(excel.summarylm$pValue, method = "BH")
  }
  
  # Append all results together in one dataframe
  if (n==1){ 
    excel.Allsummarylm=excel.summarylm
  } else {
    excel.Allsummarylm=rbind(excel.Allsummarylm,excel.summarylm)
  }
  rm("excel.summarylm")
  
}

# Write output to csv
write.csv(excel.Allsummarylm, file=outputfile, row.names=FALSE)

