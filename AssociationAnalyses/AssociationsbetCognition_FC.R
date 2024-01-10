# Perform linear regression to examine the association between functional connectivity and cognition

# Inputs to the script:
# 1) demofile: name and path of spreadsheet containing demographic, cognition and handgrip strength data
# 2) FCfile: name and path of spreadsheet containing functional connectivity measures
# 3) outputfile: name and path of output spreadsheet containing results of the linear regression analyses
# 4) cognitivevar: names of all cognitive variables examined
# 5) functiondir: path of folder containing function file "RunLM_Functions.R"

# Clear variables
rm (list = ls())

# Specify paths (CHANGE THIS!!)
demofile = '/XXX/SampleData/Demographic.csv'
FCfile = '/XXX/SampleData/Handgripstrength-relatedFCmeasures.csv'
outputfile = '/XXX/AssociationAnalyses/Assoc_FC_cognition.csv'
cognitivevar = c('GlobalCog_T','SOP_T','Attention_T','EF_T','MMSE')
functiondir = '/XXX/AssociationAnalyses/RunLM_Functions.R'

# Read spreadsheet containing demographic, cognition and handgrip strength data
demo = read.csv(demofile)

# Read spreadsheet containing functional connectivity measures and extract the names of all functional connectivity measures 
FC = read.csv(FCfile)
Varnames=colnames(FC[,c(2:ncol(FC))])

# Merge data spreadsheets together
data=merge(demo,FC,by = c('SubID'))

# Convert specified columns to numeric
data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE','TIV')] <- lapply(data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE','TIV')], as.numeric)

# Call function file
source(functiondir)

# Run linear regression model for each cognitive variable and for each functional connectivity measure
for (i in 1:length(Varnames)){
  for (c in 1:length(cognitivevar)){
    rm("data.copy","y","summary.y","templm")
    
    # Assign the cognitive variable of interest as a new variable "cog" in the dataframe and remove any rows with infinite or NaN values
    data.copy = data
    data.copy$cog = data.copy[, paste(cognitivevar[c], sep='')]
    data.copy = subset(data.copy, !is.na(cog) & !is.nan(cog) & !is.infinite(cog))      
    
    # Assign the functional connectivity variable of interest as a new variable "FC" in the dataframe and remove any rows with infinite or NaN values
    data.copy$FC = data.copy[, paste(Varnames[i], sep='')]
    data.copy = subset(data.copy, !is.na(FC) & !is.nan(FC) & !is.infinite(FC))
    
    # Convert functional connectivity variable to numeric
    if (class(data.copy$FC) != "numeric"){
      data.copy$FC=as.numeric(data.copy$FC)
    }
    
    #Centre variables
    data.copy$FC.centered=scale(data.copy$FC,scale = F)
    data.copy$Age.centered=scale(data.copy$Age,scale = F)
    data.copy$Education.centered=scale(data.copy$Education,scale = F)
    data.copy$TIV.centered=scale(data.copy$TIV,scale = F)
    
    # Run linear regression model
    y=lm(cog~FC.centered + Age.centered + Gender + Education.centered + TIV.centered, data=data.copy)
    
    # Summarize outputs (only for predictor of interest - functional connectivity) in a dataframe
    summary.y=as.data.frame(summary(y)$coefficients)
    templm=GetSummary(summary.y,"FC.centered",c("Estimate","Std. Error","t value","Pr(>|t|)"),cognitivevar[c])
    templm=data.frame(Dependent = cognitivevar[c], Predictor = Varnames[i], n = nrow(data.copy), templm, Rsquared = summary(y)$r.squared)
    colnames(templm)=c('Dependent','Predictor','n','Estimate','SE','tStat','pValue','Rsquared')
    
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
  if (i==1){ 
    excel.Allsummarylm=excel.summarylm
  } else {
    excel.Allsummarylm=rbind(excel.Allsummarylm,excel.summarylm)
  }
  rm("excel.summarylm")
  
   
}
# Write output to csv
write.csv(excel.Allsummarylm, file=outputfile, row.names=FALSE)
