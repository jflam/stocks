fluidPage(sidebarLayout(
  sidebarPanel(
# use regions as option groups
    selectizeInput('x1', 'X1', choices = list(
      Eastern = c(`New York` = 'NY', `New Jersey` = 'NJ'),
      Western = c(`California` = 'CA', `Washington` = 'WA')
    ), multiple = TRUE),
    dateInput('date',
      label = 'Date input: yyyy-mm-dd',
      value = Sys.Date()
    ),
  ),
  mainPanel(
    verbatimTextOutput('values')
  )
), title = 'Options groups for select(ize) input')