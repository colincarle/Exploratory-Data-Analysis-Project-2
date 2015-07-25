library(reshape2)

dataFile <- "./data/eiinformation.zip"
if (!file.exists(dataFile))
{
    suppressWarnings(dir.create("./data"))
    fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(fileURL, destfile = dataFile, method = 'curl')
    rm(fileURL)
}
unzip(dataFile, exdir = "./data")
NEI  <- readRDS("./data/summarySCC_PM25.rds")
SCC  <- readRDS("./data/Source_Classification_code.rds")
baltimoreCity <- subset(NEI, NEI$fips == 24510)

molten2 <- melt(baltimoreCity,
               id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
               measure.vars = "Emissions")
# casted  <- dcast(molten, year ~ variable, sum)
casted2 <- acast(molten2, variable ~ year, sum)
png(filename = "./plot2.png", width = 640, height = 640)
barplot(casted2, yaxt = "n", ylim = c(0, 3500),
        ylab = expression("PM"[2.5]*" all sources (tons)"),
        main = expression("Total PM"[2.5]*" Emissions in Baltimore 1999 through 2008"),
        col = "dodgerblue4")
axis(side = 2, at = c(seq(0, 3500, 500)), labels = c(seq(0, 3500, 500)))
dev.off()
