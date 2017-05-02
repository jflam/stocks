library(shiny)
library(quantmod)
library(highcharter)
library(rhandsontable)

starting.investment = 100000
start_date = "2017-01-01"

get.daily.returns <- function(symbol) {
    return(dailyReturn(
        Ad(
            getSymbols(
                toString(symbol),
                auto.assign = FALSE,
                from = start_date)
            )
        )
    )
}

function(input, output) {

    v <- reactiveValues(portfolio = NULL, index = NULL)

    observeEvent(input$go, {

        if (is.null(input$hot)) return()

        # Compute and plot

        DF = hot_to_r(input$hot)
        portfolio.symbols <- DF$Stocks
        portfolio.daily.returns <- do.call(
            cbind,
            lapply(
                portfolio.symbols,
                get.daily.returns
            )
        )
        portfolio.proportion = DF$Fractions
        portfolio.starting.amounts = portfolio.proportion * starting.investment

        # Now let's compute the cumulative returns by summing over
        # all of the rows in the columns

        portfolio.cumulative.gains <- cumsum(portfolio.daily.returns * portfolio.starting.amounts)

        # Create a new column from summing over each rows for 
        # the daily cumulative gain for the symbol

        portfolio.cumulative.gains <- cbind(portfolio.cumulative.gains,
                                    Total = rowSums(portfolio.cumulative.gains))

        v$portfolio <- portfolio.cumulative.gains$Total

        QQQ.daily.returns <- get.daily.returns("QQQ")
        QQQ.cumulative.gains <- cumsum(QQQ.daily.returns * starting.investment)

        v$index <- QQQ.cumulative.gains
    })

    output$chart <- renderHighchart({
        if (is.null(v$portfolio) || is.null(v$index)) return()
        highchart(type = "stock") %>%
            hc_add_series(v$portfolio, name = "Portfolio") %>%
            hc_add_series(v$index, name = "QQQ") %>%
            hc_add_theme(hc_theme_538())
    })

    output$hot <- renderRHandsontable({
        if (!is.null(input$hot)) {
            DF = hot_to_r(input$hot)
        } else {
            DF = data.frame(
                Stocks = c("AMZN", "GOOG", "MSFT"),
                Fractions = c(0.4, 0.4, 0.2),
                stringsAsFactors = FALSE)
        }

        rhandsontable(DF) %>%
            hot_table(highlightCol = TRUE, highlightRow = TRUE)
    })
}