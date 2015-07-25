library(reshape2)
library(ggplot2)

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
baltimoreCity3 <- subset(NEI, NEI$fips == 24510)

molten3 <- melt(baltimoreCity3,
                id.vars = c("fips", "SCC", "Pollutant", "type", "year"),
                measure.vars = "Emissions")
casted3 <- dcast(molten3, year + type ~ variable, sum)

temp <- qplot(aes(x = year, y = Emissions), data = casted3)

temp

plot3a <- qplot(year, Emissions, data = casted3, geom = "bar", stat = "identity") +
            scale_x_continuous(breaks = c(casted3$year)) +
            facet_wrap(~ type, nrow = 1)
plot3a

plot3b <- qplot(year, Emissions, data = casted3, geom = "bar", stat = "identity") +
    scale_x_continuous(breaks = c(casted3$year)) +
    facet_wrap(~ type, nrow = 2)
plot3b

plot3c <- qplot(x = year, y = Emissions, fill = type, data = casted3,
                geom = "bar", stat = "identity", position = "dodge") +
                scale_x_continuous(breaks = c(casted3$year))
plot3c


png(filename = "./plot3a.png", width = 640, height = 640)
plot3a
dev.off()
png(filename = "./plot3b.png", width = 640, height = 640)
plot3b
dev.off()
png(filename = "./plot3c.png", width = 640, height = 640)
plot3c
dev.off()

# barplot(casted2, yaxt = "n", ylim = c(0, 3500),
#         ylab = expression("PM"[2.5]*" all sources (tons)"),
#         main = expression("Total PM"[2.5]*" Emissions in Baltimore 1999 through 2008"),
#         col = "dodgerblue4")
# axis(side = 2, at = c(seq(0, 3500, 500)), labels = c(seq(0, 3500, 500)))
# dev.off()
