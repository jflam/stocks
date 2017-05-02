
# Dependencies

install_if_not_present <- function(name) {
    if (!(name %in% rownames(installed.packages()))) {
        install.packages(name)
    }
}

install_if_not_present("shiny")
install_if_not_present("quantmod")
install_if_not_present("highcharter")
install_if_not_present("TTR")
install_if_not_present("devtools")
install_if_not_present("rhandsontable")

# This will install a package directly from Github

devtools::install_github("AnalytixWare/ShinySky")
