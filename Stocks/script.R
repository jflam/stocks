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

# Helper functions to make it easier to enter data

create_portfolio <- function() {
    return(data.frame(
        stock = character(), # FEE is reserved symbol for tx fees
        action = factor(), # BUY, SELL
        date = numeric(),
        price = numeric()
    ));
}

add_row <- function(df, stock, action, date, price) {
    rbind(df, data.frame(
        stock,
        action,
        date = as.Date(date, tz = "PST"),
        price
    ))
}

portfolio <- create_portfolio()
portfolio <- add_row(portfolio, "AMZN", "BUY", "2017-01-01", 749.23)
portfolio <- add_row(portfolio, "MSFT", "BUY", "2017-03-03", 62.52)

write.csv(portfolio, "portfolio.csv", row.names = FALSE)

# Read in a portfolio

portfolio <- read.csv("portfolio.csv")


