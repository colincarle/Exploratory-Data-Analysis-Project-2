library(reshape2)
library(ggplot2)

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

## Search the SCC data frame EI.Sector for the expression "On-road". Use that
## index to subset the Baltimore NEI data for plotting.
baltimoreCity    <- NEI[NEI$fips == "24510", ]
vehicleIndex     <- grep("On-Road", SCC$EI.Sector)
vehicleSCC       <- as.character(SCC$SCC[vehicleIndex])
vehicleBaltimore <- baltimoreCity[baltimoreCity$SCC %in% vehicleSCC, ]

## reduce the Baltimore/vehicle dataframe to its molten form and recast as a
## data frame to calculate vehicle emissions in Baltimore as a function of year.
molten5     <- melt(vehicleBaltimore,
                    id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
                    measure.vars = "Emissions")
casted5     <- dcast(molten5, year ~ variable, sum)

## Plot Baltimore vehicle emissions as a function of year using ggplot.
plot5 <- ggplot(casted5, aes(x = year, y = Emissions)) +
    geom_bar(stat = "identity", colour = "dodgerblue", fill = "dodgerblue4") +
    scale_x_continuous(breaks = c(casted5$year)) +
    ggtitle(bquote("PM"[2.5]~"Emissions From Motor Vehicle Sources in"~
                       "Baltimore City, Maryland 1999 - 2008")) +
    ylab(expression("PM"[2.5]*" Motor Vehicle Emissions (tons)")) +
    theme(plot.title = element_text(size = 20, face = "bold", vjust = 0.75),
          axis.title.y = element_text(size = 14, face = "bold", vjust = 0.35),
          axis.title.x = element_text(size = 14))

## Output the stored ggplot object 'plot5' to the png device.
png(filename = "./plot5.png", width = 640, height = 640)
print(plot5)
dev.off()

# clean up the workspace
rm(list=ls())
