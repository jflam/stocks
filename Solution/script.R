# Experiments in rapidly building a stock tracking application

# Dependencies

install_if_not_present <- function(name) {
    if (!(name %in% rownames(installed.packages()))) {
        install.packages(name)
    }
}

# TODO: pare this list down to a more manageable set ... the 
# downstream dependencies are crazy here!

install_if_not_present("shiny")
install_if_not_present("ggvis")
install_if_not_present("quantmod")
install_if_not_present("highcharter")
install_if_not_present("TTR")
install_if_not_present("rhandsontable")

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
portfolio <- add_row(portfolio, "MSFT", "BUY", "2017-03-03", 62.52)

write.csv(portfolio, "portfolio.csv", row.names = FALSE)

# Read in a portfolio

starting_balance = 100000
portfolio <- read.csv("portfolio.csv", stringsAsFactors = FALSE)

# Compute a new portfolio value on a daily basis
# Compute using min and max of dates in a column

start_date <- min(portfolio$date)
end_date <- max(portfolio$date)

# Simple computation - take QQQ quotes for those days and compute
# value on a daily basis

library(quantmod)
getSymbols("QQQ")

# Compute a blended portfolio
# 1. Get the min and max date ranges from portfolio
# 2. Get a unique list of all of the stocks in the portfolio
# 3. Retrieve the symbols for each of those stocks via getSymbols() API
# 4. Compute the daily returns for each symbol between the min and the max
# 5. Generate a daily returns dataframe that contains 
#    a. Row for each day
#    b. Column for each stock that contains the daily return for that day
# 6. Compute a returns dataframe that contains 
#    a. Rows representing each day
#    b. Columns representing the returns from that investment for that day

symbols <- unique(portfolio$stock)
symbols[1] == "AMZN"
symbols[2] == "MSFT"

e <- new.env()
getSymbols(symbols, env = e, from = start_date, to = end_date)

# Can index
ls(e)[1]

# Can iterate using for (v in ls(e))

library(quantmod)

# BUGBUG: note that RTVS fails to render this correctly - we need
# to have the date show up as the row labels. R does this correctly
# when you just dump drAMZN to the console. RStudio also renders this
# correctly in their table viewer

drAMZN <- dailyReturn(e$AMZN)
drMSFT <- dailyReturn(e$MSFT)

# TODO: compute dailyReturns of all of the stocks and concatenate
# them all together column-wise into a struct that contains returns by stock

c <- cbind(AMZN = drAMZN, MSFT = drMSFT)
colnames(c) <- symbols

# Can now access via names or index
head(c$AMZN)
for (z in c) {
    head(z)
}

# Can we read all of the symbols into a dataframe vs. side effects?
t <- getSymbols(symbols, auto.assign = FALSE)

msft = getSymbols("MSFT", auto.assign = FALSE, from = start_date, to = end_date)

# Let's do the simplified version of this where you can compare a portfolio of stocks
# all purchased on a single start date with an index vs. buy/sell lots
# That will be an exercise left to the reader :)

symbols <- c("AMZN", "MSFT", "AAPL")
get.symbol <- function(symbol) {
    data <- getSymbols(symbol, auto.assign = FALSE, from = start_date, to = end_date)
    return(dailyReturn(data))
}

portfolio.returns <- do.call(cbind, lapply(symbols, get.symbol))
colnames(portfolio.returns) <- symbols

# Asset allocation
# starting_balance gets allocated across a range of stocks

portfolio.symbols = c("AMZN", "MSFT", "AAPL")
portfolio.proportion = c(0.10, 0.50, 0.40)
portfolio.amounts = starting_balance * portfolio.proportion

portfolio.dollar.returns <- portfolio.amounts * portfolio.returns
daily.returns <- rowSums(portfolio.dollar.returns)
portfolio.dollar.returns <- cbind(portfolio.dollar.returns, Totals = daily.returns)

aggregate_return = sum(portfolio.dollar.returns$Totals)

# Now compare against QQQ

qqq <- get.symbol("QQQ")
qqq.returns <- starting_balance * qqq
aggregate.qqq.return <- sum(qqq.returns)

# ShinySky examples

library(shinysky)
shinysky::run.shinysky.example()

# Get stock ticker symbols

symbols <- read.csv("symbols.csv")

################

# More experiments

library(tidyquant)

data(FANG)

FANG.annual.returns <-
    FANG %>%
    group_by(symbol) %>%
    tq_transmute(
        select = adjusted,
        mutate_fun = periodReturn,
        period = "yearly",
        type = "arithmetic")


library(quantmod)

QQQ = getSymbols("QQQ", auto.assign = FALSE, from = "2017-04-01")
QQQ.daily.returns <- dailyReturn(QQQ)
QQQ.shares  <- 100000/first(QQQ)
QQQ.daily.profit.or.loss <- 