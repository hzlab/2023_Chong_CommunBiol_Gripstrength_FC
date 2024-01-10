# Perform linear regression to examine the association between handgrip strength and cognition

# Inputs to the script:
# 1) datafile: name and path of spreadsheet containing demographic, cognition and handgrip strength data
# 2) outputfile: name and path of output spreadsheet containing results of the linear regression analyses
# 3) cognitivevar: names of all cognitive variables examined
# 4) functiondir: path of folder containing function file "RunLM_Functions.R"

# Clear variables
rm (list = ls())

# Specify paths (CHANGE THIS!!)
datafile = '/XXX/SampleData/Demographic.csv'
outputfile = '/XXX/AssociationAnalyses/Assoc_handgripstrength_cognition.csv'
cognitivevar = c('GlobalCog_T','SOP_T','Attention_T','EF_T','MMSE')
functiondir = '/XXX/AssociationAnalyses/RunLM_Functions.R'

# Read spreadsheet containing demographic, cognition and handgrip strength data
data = read.csv(datafile)

# Convert specified columns to numeric
data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE')] <- lapply(data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE')], as.numeric)

# Call function file
source(functiondir)

# Run linear regression model for each cognitive variable
for (c in 1:length(cognitivevar)){
  rm("data.copy","y","summary.y","templm")
  
  # Assign the cognitive variable of interest as a new variable "cog" in the dataframe and remove any rows with infinite or NaN values
  data.copy = data
  data.copy$cog = data.copy[, paste(cognitivevar[c], sep ='')]
  data.copy = subset(data.copy, !is.na(cog) & !is.nan(cog) & !is.infinite(cog))      
  
  #Centre variables
  data.copy$Age.centered=scale(data.copy$Age,scale = F)
  data.copy$Education.centered=scale(data.copy$Education,scale = F)
  data.copy$handgripstrength.centered=scale(data.copy$handgripstrength,scale = F)

  # Run linear regression model
  y=lm(cog~handgripstrength.centered + Age.centered + Gender + Education.centered, data=data.copy)
  
  # Summarize outputs (only for predictor of interest - handgrip strength) in a dataframe
  summary.y=as.data.frame(summary(y)$coefficients)
  templm=GetSummary(summary.y,"handgripstrength.centered",c("Estimate","Std. Error","t value","Pr(>|t|)"),cognitivevar[c])
  templm=data.frame(Dependent = cognitivevar[c], Predictor = 'handgripstrength', n = nrow(data.copy), templm, Rsquared = summary(y)$r.squared)
  colnames(templm)=c('Dependent','Predictor','n','Estimate','SE','tStat','pValue','Rsquared')
  
  # Append results together in one dataframe
  if (c==1){ 
    excel.summarylm=templm
  } else {
    excel.summarylm=rbind(excel.summarylm,templm)
  }
}

# Perform FDR correction
excel.summarylm$adjpValue=p.adjust(excel.summarylm$pValue, method = "BH")

# Write output to csv
write.csv(excel.summarylm, file=outputfile, row.names=FALSE)

