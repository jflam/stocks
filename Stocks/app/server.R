library(shiny)
library(quantmod)
library(highcharter)
library(rhandsontable)

starting.investment = 100000
start.date = "2017-01-01"

create.starting.portfolio <- function() {
    portfolio.symbols <- c("AMZN", "MSFT", "TSLA")
    portfolio.percentage = c(0.40, 0.20, 0.40)
    df = data.frame(
        symbols = portfolio.symbols,
        percentage = portfolio.percentage,
        stringsAsFactors = FALSE)
    return(df)
}

compute.portfolio.daily.book.value <- function(portfolio, dollars) {
    portfolio <- cbind(portfolio, dollars = portfolio$percentage * dollars)
    df <- NULL

    compute.daily.book.value <- function(symbol, dollars) {

        symbol.data <- getSymbols(
            symbol,
            auto.assign = FALSE,
            from = start.date)

        shares <- dollars / first(Op(symbol.data))
        book.value <- Ad(symbol.data) * shares

        if (is.null(df)) {
            df <<- data.frame(book.value)
        }
        else {
            df <<- cbind(df, data.frame(book.value))
        }
    }

    mapply(compute.daily.book.value, portfolio$symbols, portfolio$dollars)

    # Compute totals for each day

    df <- cbind(df, data.frame(Total = rowSums(df)))
    return(df)
}

function(input, output) {

    v <- reactiveValues(portfolio = NULL, index = NULL)

    observeEvent(input$go, {

        if (is.null(input$hot)) return()

        # Compute the value of the portfolio and the comparison 
        # portfolio (we do QQQ here)

        portfolio = hot_to_r(input$hot)

        v$portfolio <- compute.portfolio.daily.book.value(portfolio, starting.investment)
        v$index <- compute.portfolio.daily.book.value(
            data.frame(
                symbols = c("QQQ"),
                percentage = c(1.0),
                stringsAsFactors = FALSE
            ),
            starting.investment
        )
        print(v$index)
    })

    output$chart <- renderHighchart({
        if (is.null(v$portfolio) || is.null(v$index)) return()
        highchart(type = "stock") %>%
            hc_add_series(v$portfolio$Total, name = "Portfolio") %>%
            hc_add_series(v$index$Total, name = "QQQ") %>%
            hc_add_theme(hc_theme_538())
    })

    output$hot <- renderRHandsontable({
        if (!is.null(input$hot)) {
            portfolio = hot_to_r(input$hot)
        } else {
            portfolio = create.starting.portfolio()
        }

        rhandsontable(portfolio) %>%
            hot_table(highlightCol = TRUE, highlightRow = TRUE)
    })
}