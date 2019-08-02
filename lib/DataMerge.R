setwd("/Users/timxie/Downloads")
enroll1 <- read.csv("schoolInfo.csv", header = T, stringsAsFactors = F)
rawdata <- read.csv("final3data.csv", header = T, stringsAsFactors = F)
#enroll2 <- read.csv("US Undergrad Enrollment.csv", header = T, stringsAsFactors = F)

str(rawdata)
str(enroll1)

for (i in 1:nrow(rawdata)){
  if (sum(rawdata$Name[i] == enroll1$displayName)>0){
    index <- which(rawdata$Name[i] == enroll1$displayName)
    rawdata$Enrollment[i] <- enroll1$enrollment[index]
    rawdata$ACT[i] <- enroll1$act.avg[index]
    rawdata$hs.gpa[i] <- enroll1$hs.gpa.avg[index]
  } else {
    rawdata$Enrollment[i] <- NA
    rawdata$ACT[i] <- NA
    rawdata$hs.gpa[i] <- NA
  }
}


write.csv(rawdata, "final4data.csv")

sum(!is.na(rawdata$Enrollment))
