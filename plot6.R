## Plot 6
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
## index to subset the Baltimore-LA NEI data for plotting.
baltimoreLA        <- NEI[NEI$fips == "24510" | NEI$fips == "06037", ]
vehicleIndex       <- grep("On-Road", SCC$EI.Sector)
vehicleSCC         <- as.character(SCC$SCC[vehicleIndex])
vehicleBaltimoreLA <- baltimoreLA[baltimoreLA$SCC %in% vehicleSCC, ]

## reduce the Baltimore-LA/vehicle data to its molten form and recast as a data
## frame to compare vehicle emissions as a function of year and county(fips).
molten6 <- melt(vehicleBaltimoreLA,
                id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
                measure.vars = "Emissions")
casted6 <- dcast(molten6, year + fips ~ variable, sum)

## This function will standardize the range of the input vector, rescaling the
## range to [0, 1]
normalize <- function(x)
{
    return((x - min(x)) / (max(x) - min(x)))
}

## LA emissions data dominates Baltimore emissions data. It is easier to compare
## them on a similar scale by using the normalize function above.
casted6$Emissions[casted6$fips == "24510"] <-
    normalize(casted6$Emissions[casted6$fips == "24510"])
casted6$Emissions[casted6$fips == "06037"] <-
    normalize(casted6$Emissions[casted6$fips == "06037"])

## Plot the normalized emissions data with ggplot. The question asks about which
## county has seen greater changes over time, so I have plotted a regression
## line with geom_smooth which shows the rate of decline for Baltimore vehicle
## emissions is greater than the rate of increase for LA vehicle emissions.
plot6 <- ggplot(casted6, aes(x = year, y = Emissions)) +
    geom_point(aes(colour = fips, shape = fips), size = 4) +
    geom_smooth(aes(colour = fips), method = "lm", linetype = "dashed",
                se = FALSE) +
    scale_x_continuous(breaks = c(casted6$year)) +
    ggtitle(bquote(atop("PM"[2.5]~"Changes in Emissions from",
                   "Motor Vehicle Sources 1999 - 2008"))) +
    ylab(bquote("PM"[2.5]~"Motor Vehicle Emissions (feature scaled)")) +
    scale_colour_discrete(name = "County",
                          labels = c("Los Angeles", "Baltimore City")) +
    scale_shape_discrete(name = "County",
                         labels = c("Los Angeles", "Baltimore City")) +
    theme(plot.title = element_text(size = 20, face = "bold", vjust = 0.75),
          axis.title.y = element_text(size = 14, face = "bold", vjust = 0.35),
          axis.title.x = element_text(size = 14))

## output the stored ggplot object 'plot6' to the png device
png(filename = "./plot6.png", width = 480, height = 480)
print(plot6)
dev.off()

# clean up the workspace
rm(list=ls())
