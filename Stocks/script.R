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

# Create a dataframe that contains a list of the symbols
# in your portfolio, the date acquired / disposed, and
# the price that you paid. 

portfolio <- data.frame(
     stock = character(), # FEE is reserved symbol for tx fees
     action = factor(), # BUY, SELL
     date = numeric(),
     price = numeric()
)

portfolio <- rbind(portfolio, data.frame(
    stock = "AMZN",
    action = "BUY",
    date = ISOdate(2017,1,1),
    price = 749.23
))

# Helper functions to make it easier to enter data

create_portfolio <- function() {
    return(data.frame(
        stock = character(), # FEE is reserved symbol for tx fees
        action = factor(), # BUY, SELL
        date = numeric(),
        price = numeric()
    ));
}

add_row <- function(df, stock, action, year, month, day, price) {
    rbind(df, data.frame(
        stock, action, ISOdate(year, month, day), price
    ))
}

portfolio <- create_portfolio()
portfolio <- add_row(portfolio, "AMZN", "BUY", 2017, 1, 1, 749.23)
portfolio <- add_row(portfolio, "MSFT", "BUY", 2017, 3, 1, 62.52)


portfolio <- NULL
# Read symbols
