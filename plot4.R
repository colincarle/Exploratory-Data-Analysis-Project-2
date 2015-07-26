## Plot 4
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

## Search the SCC data frame EI.Sector for combinations of the word coal. Use
## that index to subset the NEI data for plotting.
coalCombIndex   <- grep("[Cc][Oo][Aa][Ll]", SCC$EI.Sector)
coalCombSCC     <- as.character(SCC$SCC[coalCombIndex])
coalCombNEI     <- NEI[NEI$SCC %in% coalCombSCC, ]

## reduce the NEI dataframe to its molten form and recast as a data frame to
## calculate total coal emissions as a function of year.
molten4         <- melt(coalCombNEI,
                        id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
                        measure.vars = "Emissions")
casted4         <- dcast(molten4, year ~ variable, sum)

## Plot Coal combustion emissions as a function of year using ggplot.
plot4 <- ggplot(casted4, aes(x = year, y = Emissions)) +
    geom_bar(stat = "identity", colour = "dodgerblue", fill = "dodgerblue4") +
    scale_x_continuous(breaks = c(casted4$year)) +
    scale_y_continuous(labels = c(0, 200, 400, 600)) +
    ggtitle(bquote(atop(PM[2.5]~"Emissions From Coal Combustion Related",
                        "Sources in the United States 1999 - 2008"))) +
    ylab(bquote("PM"[2.5]*" Coal Emissions (kilotons)")) +
    theme(plot.title = element_text(size = 20, face = "bold", vjust = 0.75),
          axis.title.y = element_text(size = 14, face = "bold", vjust = 0.35),
          axis.title.x = element_text(size = 14))

## Output the stored ggplot object 'plot4' to the png device.
png(filename = "./plot4.png", width = 480, height = 480)
print(plot4)
dev.off()

# clean up the workspace
rm(list=ls())
