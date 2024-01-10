# Perform mediation analyses to examine the mediation effect of functional connectivity on the handgrip strength-cognition association
# In these models, functional connectivity is the mediator, handgrip strength is the predictor/independent variable and cognition is the dependent variable

# The "lavaan" package is required for this analyses. It can be installed using the following command "install.packages("lavaan")

# Inputs to the script:
# 1) demofile: name and path of spreadsheet containing demographic, cognition and handgrip strength data
# 2) FCfile: name and path of spreadsheet containing functional connectivity measures
# 3) outputfile: name and path of output spreadsheet containing results of the mediation analyses
# 4) cognitivevar: names of all cognitive variables examined
# 5) nuisancecov: name of nuisance covariate to control for (GMV or TIV)

# Clear variables
rm (list = ls())

# Load lavaan package
require(lavaan)

# Specify paths (CHANGE THIS!!)
demofile = '/XXX/SampleData/Demographic.csv'
FCfile = '/XXX/SampleData/Handgripstrength-relatedFCmeasures.csv'
outputfile = '/XXX/MediationAnalyses/Mediation.csv'
cognitivevar = c('GlobalCog_T','SOP_T')
nuisancecov = c('TIV','GMV')

# Read spreadsheet containing demographic, cognition and handgrip strength data
demo = read.csv(demofile)

# Read spreadsheet containing functional connectivity measures and extract the names of all functional connectivity measures 
FC = read.csv(FCfile)
Varnames=colnames(FC[,c(2:ncol(FC))])

# Merge data spreadsheets together
data=merge(demo,FC,by = c('SubID'))

# Convert specified columns to numeric
data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE','TIV','GMV')] <- lapply(data[, c('Age','Education','handgripstrength','Attention_T','SOP_T','EF_T','GlobalCog_T','MMSE','TIV','GMV')], as.numeric)

# Run mediation model for each cognitive variable, for each functional connectivity measure and for each nuisance covariate
for (n in 1:length(nuisancecov)){
  for (i in 1:length(Varnames)){
    for (c in 1:length(cognitivevar)){
      rm("data.copy","y.cognition","y.mediator","y.predictor","resid","model","fit","temp")
      
      # Assign the functional connectivity variable of interest as a new variable "mediator" in the dataframe and remove any rows with infinite or NaN values
      data.copy = data
      data.copy$mediator = data.copy[, paste(Varnames[i] ,sep = '')]
      data.copy = subset(data.copy, !is.na(mediator) & !is.nan(mediator) & !is.infinite(mediator))
      
      # Assign the cognitive variable of interest as a new variable "cognition" in the dataframe and remove any rows with infinite or NaN values
      data.copy$cognition = data.copy[, paste(cognitivevar[c], sep ='')]
      data.copy = subset(data.copy, !is.na(cognition) & !is.nan(cognition) & !is.infinite(cognition))      
      
      # Assign handgrip strength as a new variable "predictor" in the dataframe and remove any rows with infinite or NaN values
      data.copy$predictor = data.copy$handgripstrength
      data.copy = subset(data.copy, !is.na(predictor) & !is.nan(predictor) & !is.infinite(predictor))      
      
      # Assign the nuisance covariate of interest as a new variable "cov" in the dataframe and remove any rows with infinite or NaN values
      data.copy$cov = data.copy[, paste(nuisancecov[n], sep='')]
      data.copy = subset(data.copy, !is.na(cov) & !is.nan(cov) & !is.infinite(cov))
      
      # Convert functional connectivity variable (mediator) to numeric
      if (class(data.copy$mediator) != "numeric"){
        data.copy$mediator=as.numeric(data.copy$mediator)
      }
      
      #Centre variables
      data.copy$Age.centered=scale(data.copy$Age,scale = F)
      data.copy$Education.centered=scale(data.copy$Education,scale = F)
      data.copy$cov.centered=scale(data.copy$cov,scale = F)
      
      #Model
      y.cognition=lm(cognition~Age.centered + Gender + Education.centered + cov.centered, data=data.copy)
      y.mediator=lm(mediator~Age.centered + Gender + Education.centered + cov.centered, data=data.copy)
      y.predictor=lm(predictor~Age.centered + Gender + Education.centered + cov.centered, data=data.copy)
      
      #Get residuals and put them in one data frame
      resid=data.frame(Y = residuals(y.cognition), M = residuals(y.mediator), X = residuals(y.predictor))
      
      #Perform mediation model based on this link: http://lavaan.ugent.be/tutorial/mediation.html
      model <- ' # direct effect
          Y ~ c*X
          # mediator
          M ~ a*X
          Y ~ b*M
          # indirect effect (a*b)
          ab := a*b
          # total effect
          total := c + (a*b)
          '
      #fit <- sem(model, data = resid, se="bootstrap", bootstrap = 5000)
      fit <- sem(model, data = resid, se="bootstrap", bootstrap = 100)
      temp=data.frame(covariate = nuisancecov[n], predictor="handgripstrength", cognition=cognitivevar[c], mediator=Varnames[i], parameterEstimates(fit))
      
      if (n==1 & i==1 & c==1){
        excel.summary=temp
      } else {
        excel.summary=rbind(excel.summary,temp)  
      }
    }
  }
}

# Write output to csv
write.csv(excel.summary, file=outputfile,row.names=FALSE)
  
  