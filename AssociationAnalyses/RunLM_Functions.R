GetSummary <- function(coefs,vars,stats,name) {
  
  for (v in 1:length(vars)){
    rm("a")
    a=coefs[c(paste(vars[v])),stats]
    statnames=vector()
    for (s in 1:length(stats)){
      statnames[s]=paste(vars[v],"_",stats[s],sep='')
    }
    
    colnames(a)=c(paste(vars[v],"_Estimate",sep=''),paste(vars[v],"_SE",sep=''),paste(vars[v],"_t.value",sep=''),paste(vars[v],"_p.z",sep=''))
    if (v==1) {
      temp=a
    } else {
      temp=cbind(temp,a)
      
    }
  }
  rownames(temp)=paste(name)
  
  return(temp)
}