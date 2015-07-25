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

molten1 <- melt(NEI, id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
               measure.vars = "Emissions")
# casted  <- dcast(molten, year ~ variable, sum)
casted1 <- acast(molten1, variable ~ year, sum)
png(filename = "./plot1.png", width = 640, height = 640)
barplot(casted1, ylim = c(0, 8e6), yaxt = "n",
        ylab = expression("PM"[2.5]*" all sources (millions of tons)"),
        main = expression("Total PM"[2.5]*" Emissions in the United States 1999 through 2008"),
        col = "dodgerblue4")
axis(side = 2, at = c(0, 2e6, 4e6, 6e6, 8e6), labels = c(0, 2, 4, 6, 8))
dev.off()
