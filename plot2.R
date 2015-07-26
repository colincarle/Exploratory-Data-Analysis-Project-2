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

## Subset the NEI data by fips code 24510 i.e. Baltimore
baltimoreCity <- NEI[NEI$fips == "24510", ]

## reduce the NEI dataframe to its molten form and recast as an array to
## calculate total emissions in Baltimore as a function of year.
molten2 <- melt(baltimoreCity,
               id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
               measure.vars = "Emissions")
casted2 <- acast(molten2, variable ~ year, sum)

## open the png device and plot Baltimore emissions as a function of year using
## the base graphics function barplot.
png(filename = "./plot2.png", width = 640, height = 640)
barplot(casted2, yaxt = "n", ylim = c(0, 3500),
        ylab = bquote("PM"[2.5]~"all sources (tons)"),
        main = bquote("Total PM"[2.5]~"Emissions in Baltimore City,"~
                      "Maryland 1999 - 2008"),
        col = "dodgerblue4", border = "dodgerblue")
axis(side = 2, at = c(seq(0, 3500, 500)),
     labels = c("0", "", "1000", "", "2000", "", "3000", ""))
dev.off()

# clean up the workspace
rm(list=ls())
