
d <- ggplot(diamonds, aes(carat, price, fill = ..density..)) +
    xlim(0, 2) + stat_binhex(na.rm = TRUE) + theme(aspect.ratio = 1)
d + facet_wrap(~ color)
d + facet_wrap(~ color, ncol = 1)
d + facet_wrap(~ color, ncol = 4)
d + facet_wrap(~ color, nrow = 1)
d + facet_wrap(~ color, nrow = 3)


p <- qplot(displ, hwy, data = mpg)
p + facet_wrap(~ cyl)
p + facet_wrap(~ cyl, scales = "free")

# Use as.table to to control direction of horizontal facets, TRUE by default
p + facet_wrap(~ cyl, as.table = FALSE)

# Add data that does not contain all levels of the faceting variables
cyl6 <- subset(mpg, cyl == 6)
p + geom_point(data = cyl6, colour = "red", size = 1) +
    facet_wrap(~ cyl)
p + geom_point(data = transform(cyl6, cyl = 7), colour = "red") +
    facet_wrap(~ cyl)
p + geom_point(data = transform(cyl6, cyl = NULL), colour = "red") +
    facet_wrap(~ cyl)
