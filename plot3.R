## Plot 3
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
baltimoreCity <- NEI[NEI$fips == "24510", ]

## reduce the NEI dataframe to its molten form and recast as a data frame to
## calculate total emissions in Baltimore as a function of type and year.
molten3 <- melt(baltimoreCity,
                id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
                measure.vars = "Emissions")
casted3 <- dcast(molten3, year + type ~ variable, sum)

## plot the total emissions by type using ggplot. Each type is displayed
## separately by using facet_wrap about the type variable.
plot3   <- ggplot(casted3, aes(x = year, y = Emissions)) +
    geom_bar(stat = "identity", colour = "dodgerblue", fill = "dodgerblue4") +
    facet_wrap(~type, nrow = 1) +
    scale_x_continuous(breaks = c(casted3$year)) +
    ggtitle(bquote(atop("PM"[2.5]~"Total Emissions in the United States",
                       "by Type 1999 - 2008"))) +
    ylab(expression("PM"[2.5]*" Emissions (tons)")) +
    theme(plot.title = element_text(size = 20, face = "bold", vjust = 0.75),
          axis.title.y = element_text(size = 14, face = "bold", vjust = 0.35),
          axis.title.x = element_text(size = 14))

## output the stored ggplot object 'plot3' to the png device
png(filename = "./plot3.png", width = 480, height = 480)
print(plot3)
dev.off()

# clean up the workspace
rm(list=ls())
