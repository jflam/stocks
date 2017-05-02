library(quantmod)

# We are comparing our performance against QQQ
# which tracks the Nasdaq 100

QQQ <- getSymbols("QQQ", auto.assign = FALSE, from = "2017-01-01")

# View this in variable explorer
# Open table viewer
# Export to Excel

# Now lets plot QQQ for the YTD using the HighCharter package

library(highcharter)

highchart(type = "stock") %>%
    hc_add_series(QQQ, type = "ohlc")

# Let's get another stock MSFT and plot that in a comparison chart

MSFT <- getSymbols("MSFT", auto.assign = FALSE, from = "2017-01-01")

highchart(type = "stock") %>%
    hc_add_series(QQQ, type = "ohlc") %>%
    hc_add_series(MSFT) %>%
    hc_add_theme(hc_theme_538())

# The scale is difficult to ascertain because we're plotting
# the price of the stock, which doesn't correlate to its 
# performance. 

# 1. Discuss how dailyReturn function operates against xts
# 2. Discuss how cumsum function operates against xts
# 3. Discuss how to get help on these functions 

starting.investment = 100000

QQQ.cumulative <- cumsum(dailyReturn(QQQ) * starting.investment)
MSFT.cumulative <- cumsum(dailyReturn(MSFT) * starting.investment)

highchart(type = "stock") %>%
    hc_add_series(QQQ.cumulative, name = "QQQ") %>%
    hc_add_series(MSFT.cumulative, name = "MSFT") %>% 
    hc_add_theme(hc_theme_538())

# Let's examine the data again in QQQ. You can see that it contains
# open, high, low, close, volume, and adjusted prices. 

head(QQQ)

# We really are only interested in the adjusted prices at close 
# for the purposes of computing daily returns, which we can 
# extract using the Ad() function

QQQ.adjusted <- Ad(QQQ)

# Let's view the first few rows of the xts result set. We can see
# that it contains both dates and the adjusted price for QQQ.

head(QQQ.adjusted)

# Now, let's write a generic function that will return us 
# the adjusted price of any stock.

start_date <- "2017-01-01"

get.daily.adjusted.price <- function(symbol) {
    return(Ad(getSymbols(symbol, auto.assign = FALSE, from = start_date)))
}

# Let's get the adjusted price for AMZN

QQQ.adjusted <- get.daily.adjusted.price("QQQ")
head(QQQ.adjusted)

# Now, let's get the daily returns, expressed as a percentage
# gain or loss, based on the adjusted prices

QQQ.daily.returns <- dailyReturn(QQQ.adjusted)
head(QQQ.daily.returns)

# Let's write a new function to compute daily returns for a symbol

get.daily.returns <- function(symbol) {
    return(dailyReturn(get.daily.adjusted.price(symbol)))
}

# Let's test it on TSLA

TSLA.daily.returns <- get.daily.returns("TSLA")
head(TSLA.daily.returns)

TSLA.cumulative.returns <- cumsum(TSLA.daily.returns * starting.investment)
head(TSLA.cumulative.returns)

# Now let's do the same thing for a portfolio

portfolio.symbols <- c("AMZN", "MSFT", "TSLA")

# Let's compute the daily returns for the stocks in
# portfolio.symbols. Note that iteration in R is done via
# lapply, not via loops.
# TODO: explain this better

portfolio.daily.returns <- do.call(cbind, lapply(portfolio.symbols, get.daily.returns))

# Assign the column names to be the same as the symbols

colnames(portfolio.daily.returns) <- portfolio.symbols

# Now let's define the asset allocation of our initial 
# starting investment amount, allocated across all of the
# stocks in portfolio.symbols:

portfolio.proportion = c(0.40, 0.20, 0.40)
portfolio.starting.amounts = portfolio.proportion * starting.investment

# Now let's compute the cumulative returns by summing over
# all of the rows in the columns

portfolio.cumulative.gains <- cumsum(portfolio.daily.returns * portfolio.starting.amounts)

# Create a new column from summing over each rows for 
# the daily cumulative gain for the symbol

portfolio.cumulative.gains <- cbind(portfolio.cumulative.gains,
                                    Total = rowSums(portfolio.cumulative.gains))

# Now do the same cumulative gain computation for QQQ

QQQ.cumulative.gains <- cumsum(QQQ.daily.returns * starting.investment)
head(QQQ.cumulative.gains)

# Now let's plot the two curves against each other

highchart(type = "stock") %>%
    hc_add_series(QQQ.cumulative.gains, name = "QQQ") %>%
    hc_add_series(portfolio.cumulative.gains$Total, name = "Portfolio") %>%
    hc_add_theme(hc_theme_538())

# Now the next step in this is to turn this analysis into an applicatoin
# where you can pick the stocks to add to your asset allocation and their 
# proportions. The constraint is that they must add up to 100% in your allocation.
# Hit the compute button to generate the results.

