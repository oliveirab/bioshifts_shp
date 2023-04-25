# Load shape files from Bioshifts

library(tidyverse)
library(googledrive)
library(rgdal)
library(terra)

setwd("~/bioshifts_shp")

# download shape files

# list geodatabase content on google drive 
my_folder = "https://drive.google.com/drive/folders/1JIcpTyIH1__GvCR0xPGNO3Xiq25jGjTu"
folder_id = drive_get(as_id(my_folder))

#find files in folder
files = drive_ls(folder_id)

# create folder to store data
dir.create("Study_Areas.gdb")

#download files
for (file_i in seq_along(files$name)) {
    #fails if already exists
    try({
        drive_download(
            as_id(files$id[file_i]),
            path = str_c("Study_Areas.gdb/", files$name[file_i])
        )
    })
}

# load bioshifts database
my_folder = "https://drive.google.com/drive/folders/176IhIliTpCmOx_ESpG1ISK7tZLTBAYp-"
folder_id = drive_get(as_id(my_folder))

#find files in folder
files = drive_ls(folder_id)
file = files %>% 
    filter(name == "Shifts2018_checkedtaxo.txt") %>% 
    select(id)

drive_download(
    as_id(file$id),
    path = "Shifts2018_checkedtaxo.txt")

Bioshiftsv1 <- read.table("Shifts2018_checkedtaxo.txt",
                          header = T,
                          encoding="latin1")

StudyID <- unique(Bioshiftsv1$ID)

# look at shape files
StudyID_i <- StudyID[1]
fgdb <- here::here("Study_Areas.gdb")

StudyArea <- lapply(StudyID_i, function(x) {
    tmp <- readOGR(dsn=fgdb,layer=x)
    vect(tmp)
})
StudyArea <- vect(StudyArea)
StudyArea$NAME = StudyID_i

plot(StudyArea)
