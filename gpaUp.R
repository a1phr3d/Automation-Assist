### get user's home directory
home <- setwd(Sys.getenv("HOME"))


### construct path to file
fpath <- file.path(home, "Desktop", "Weekly GPA")


### load up the files we will work with
## paths
idspath <- paste(fpath, "/ids.csv", sep = '')
dload302path <- paste(fpath, "/Download_3.02.csv", sep = '')
dload303path <- paste(fpath, "/Download_3.03.csv", sep = '')

## import
ids <- read.csv(idspath, header = T, as.is = T)
dload302 <- read.csv(dload302path, header = T, as.is = T)
dload303 <- read.csv(dload303path, header = T, as.is = T)

## refine
idsframe <- data.frame(ids)

dload302.1 <- subset(dload302, 
                     Category == "Homework" & Department != "Club",
                     select = c("StudentID", "Course", "AVG"))
for (course in list(dload302.1$Course)){
  dload302.1$newCourseName <- ifelse(startsWith(course, "E"), "ELA",
                                     ifelse(startsWith(course, "H"), "History",
                                            ifelse(startsWith(course, "M"), "Math",
                                                   ifelse(startsWith(course, "S"),"Science", "Club"))))
}

dload303.1 <- subset(dload303,
                     select = c("StudentID", "Course", "AVG"))
for (course in list(dload303.1$Course)){
  dload303.1$newCourseName <- ifelse(startsWith(course, "E"), "ELA",
                                     ifelse(startsWith(course, "H"), "History",
                                            ifelse(startsWith(course, "M"), "Math", "Science")))
}


### get overall averages -- by subject
for (scholar in ids){
  # ela
  idsframe$ELAAvgs <- dload303.1$AVG[dload303.1$newCourseName == "ELA" & dload303.1$StudentID == scholar]
  # science
  idsframe$SciAvgs <- dload303.1$AVG[dload303.1$newCourseName == "Science" & dload303.1$StudentID == scholar]
  # math
  idsframe$MatAvgs <- dload303.1$AVG[dload303.1$newCourseName == "Math" & dload303.1$StudentID == scholar]
  # history
  idsframe$HisAvgs <- dload303.1$AVG[dload303.1$newCourseName == "History" & dload303.1$StudentID == scholar]
}

### get honework gpas -- by subject
for (scholar in ids){
  # elaHW
  idsframe$ELAHWAvgs <- dload302.1$AVG[dload302.1$newCourseName == "ELA" & dload302.1$StudentID == scholar]
  # scienceHW
  idsframe$SciHWAvgs <- dload302.1$AVG[dload302.1$newCourseName == "Science" & dload302.1$StudentID == scholar]
  # mathHW
  idsframe$MatHWAvgs <- dload302.1$AVG[dload302.1$newCourseName == "Math" & dload302.1$StudentID == scholar]
  # historyHW
  idsframe$HisHWAvgs <- dload302.1$AVG[dload302.1$newCourseName == "History" & dload302.1$StudentID == scholar]
}


### date pulled for gpa email
today <- Sys.Date()
idsframe$Date <- format(today, format="%B %d %Y")


### combine data into one file to be pasted into google sheets/ gpa tracker
gpaOut <- paste(fpath, "/gpa_out.csv", sep = '')
write.csv(idsframe, gpaOut)
