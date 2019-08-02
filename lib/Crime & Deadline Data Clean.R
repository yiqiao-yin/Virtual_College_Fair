#install.packages("lettercase")
library(lettercase)

setwd("/Users/timxie/Downloads")
crime <- read.csv("FBI Crime Data.csv", header = T, stringsAsFactors = F)
finaldata <- read.csv("final3data.csv", header = T, stringsAsFactors = F)
deadline <- read.csv("College Application Deadline_clean.csv", header = T, stringsAsFactors = F)

str(crime); str(finaldata)


# Clean Crime data
for (i in 1: nrow(crime)){
  if (crime$State[i] == ""){
    crime$State[i] <- crime$State[i-1]
  }
}

crime$State <- str_ucfirst(str_decapitalize(crime$State))

for (i in 1182:nrow(crime)){
  crime$State.Abbr[i] <- state.abb[which(state.name == crime$State[i])]
}

crime$Crime.Rate <- crime$Total.Crime/crime$Population

str(crime)
write.csv(crime, "FBI Crime Data_Cleaned.csv")


# Merge Crime data
crime_clean <- read.csv("FBI Crime Data_Cleaned.csv", header = T, stringsAsFactors = F)

for (j in 1:nrow(finaldata)){
  if (sum(finaldata$State[j] == crime_clean$State.Abbr & finaldata$City[j] == crime$City) >0){
    index <- which(finaldata$State[j] == crime_clean$State.Abbr & finaldata$City[j] == crime$City)
    finaldata$FBI.TotalCrime[j] <- crime_clean$Total.Crime[index]
    finaldata$FBI.CrimeRate[j] <- crime_clean$Crime.Rate[index] * 100
  } else {
    finaldata$FBI.TotalCrime[j] <- NA
    finaldata$FBI.CrimeRate[j] <- NA
  }
}

write.csv(finaldata, "final4data.csv")





#############


finaldata <- read.csv("final4data_crimedata.csv", header = T, stringsAsFactors = F)
deadline <- read.csv("College Application Deadline_clean.csv", header = T, stringsAsFactors = F)

str(finaldata)
str(deadline)

# Merge Deadline data
finaldata$NewName <- gsub("-", " ", finaldata$Name)

for (j in 1:nrow(finaldata)){
  if (sum(finaldata$NewName[j] == deadline$College) >0){
    index <- which(finaldata$NewName[j] == deadline$College)
    finaldata$Application.Deadline[j] <- deadline$Application.Deadline[index]
  } else {
    finaldata$Application.Deadline[j] <- NA
  }
}
finaldata <- finaldata[,-(ncol(finaldata)-1)]
sum(is.na(finaldata$Application.Deadline))
str(finaldata)

write.csv(finaldata, "final5data.csv")





