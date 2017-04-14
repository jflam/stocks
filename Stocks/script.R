# Experiments in rapidly building a stock tracking application

# Dependencies

install_if_not_present <- function(name) {
    if (!(name %in% rownames(installed.packages()))) {
        install.packages(name)
    }
}

install_if_not_present("shiny")
install_if_not_present("ggvis")
install_if_not_present("quantmod")
install_if_not_present("highcharter")
install_if_not_present("TTR")

# Quantmod package lets you download data
# nice tutorial here: https://www.r-bloggers.com/a-guide-on-r-quantmod-package-how-to-get-started/

library(quantmod)

?getSymbols # pop up help externally

getSymbols("AMZN") # note side-effecting operation
getSymbols("QQQ") # note side-effecting operation

AMZN # symbol gets created, inspect in variable explorer

library(highcharter)

highchart(type = "stock") %>%
    hc_add_series(AMZN, type = "ohlc") %>%
    hc_add_series(QQQ) %>%
    hc_add_theme(hc_theme_538())

# Get symbols

library(TTR)
symbols <- stockSymbols()
write.csv(symbols, "symbols.csv")

# Read symbols