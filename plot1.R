library(reshape2)

## Check for the presence of the data file, and download if not present.
dataFile <- "./data/eiinformation.zip"
if (!file.exists(dataFile))
{
    suppressWarnings(dir.create("./data"))
    fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(fileURL, destfile = dataFile, method = 'curl')
    rm(fileURL)
}

# Extract the contents of the compressed archive.
unzip(dataFile, exdir = "./data")

# Read the National Emission Inventory and Source Classification Code table into
# data frames NEI and SCC
NEI                <- readRDS("./data/summarySCC_PM25.rds")
SCC                <- readRDS("./data/Source_Classification_code.rds")

## reduce the NEI dataframe to its molten form and recast as an array
## to calculate total emissions as a function of year
molten1 <- melt(NEI, id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
               measure.vars = "Emissions")
casted1 <- acast(molten1, variable ~ year, sum)

## open the png device and plot the total emissions as a function of year using
## the base graphics function barplot.
png(filename = "./plot1.png", width = 640, height = 640)
barplot(casted1, ylim = c(0, 8e6), yaxt = "n",
        ylab = bquote(PM[2.5]~"all sources (millions of tons)"),
        main = bquote("Total PM"[2.5]~"Emissions in the United States"~
                      "1999 - 2008"),
        col = "dodgerblue4", border = "dodgerblue")
axis(side = 2, at = c(0, 2e6, 4e6, 6e6, 8e6), labels = c(0, 2, 4, 6, 8))
dev.off()

# clean up the workspace
rm(list=ls())
