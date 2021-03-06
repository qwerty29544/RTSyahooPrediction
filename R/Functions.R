future_calendar <- function(day_from = Sys.Date(), days_future = 10){
  dates_in_future <- 1:(days_future + (days_future %/% 5 + 1) * 2)
  dates_in_future <- day_from + dates_in_future
  names(dates_in_future) <- as.POSIXlt(dates_in_future)$wday

  delete_names <- c("6", "0")

  dates_in_future <- dates_in_future[!(names(dates_in_future) %in% delete_names)][1:days_future]

  return(dates_in_future)
}

# download_series ---------------------------------------------------------


#' Download Yahoo time series by symbols
#'
#' @param symbol
#' @param from
#' @param to
#'
#' @return
#' @export quantmod
#' @export stringr
#' @export dplyr
#' @export data.table
#' @export zoo
#'
#' @examples
download_series <- function(symbol, from = Sys.Date() - 90, to = Sys.Date()) {
  # Загрузка данных из Yahoo по symbol
  quantmod::getSymbols(Symbols = symbol, src = "yahoo", from = from, to = to)

  # Переопределение строки для того, чтобы взять переменную датасета по её имени
  symbol <- stringr::str_remove(string = symbol, pattern = "[:punct:\\^]")

  ts_df <- get(symbol)
  date_ts <- as.Date(x = zoo::index(ts_df),
                     format = "%Y-%d-%m")

  years <- as.numeric(x = format(x = date_ts,"%Y"))
  months <- as.numeric(x = format(x = date_ts, "%m"))
  days <- as.numeric(x = format(x = date_ts, "%d"))

  quarter <- as.numeric(
    gsub(pattern = "Q",
         replacement = "",
         x = quarters(date_ts))
  )

  weekdays_numeric_vector <- 1:5
  names(weekdays_numeric_vector) <- unique(weekdays(date_ts))
  weekdays_numeric_vector <- weekdays_numeric_vector[weekdays(date_ts)]

  ts_df <- data.table::data.table(
    Date = date_ts,
    Symbol = symbol,
    id = paste0(symbol, as.numeric(date_ts)),
    Year = years,
    Month = months,
    Day = days,
    Quarter = quarter,
    Weekday = weekdays_numeric_vector,
    Date_days = as.numeric(date_ts),
    Date_days_zero = as.numeric(date_ts) - min(as.numeric(date_ts)),
    Close = as.numeric(ts_df[, 4]),
    Volume = as.numeric(ts_df[, 5]),
    tag_obs_pred = "observed"
  )

  return(ts_df)
}



# scaler ------------------------------------------------------------------
apply_scale <- function(ts, min, max) {
  ts <- (ts - min)/(max - min)
  return(ts)
}


log_scaler <- function(dataset) {
  dataset_new <- dataset

  dataset_new$Close <- log(dataset_new$Close + 1)
  dataset_new$Volume <- log(dataset_new$Volume + 1)

  min_Vol <- min(dataset_new$Volume)
  max_Vol <- max(dataset_new$Volume)

  min_Close <- min(dataset_new$Close)
  max_Close <- max(dataset_new$Close)

  dataset_new$Close <- apply_scale(dataset_new$Close, min_Close, max_Close)
  dataset_new$Volume <- apply_scale(dataset_new$Volume, min_Vol, max_Vol)

  return(list(dataset = dataset_new,
              min_Close = min_Close,
              max_Close = max_Close,
              min_Vol = min_Vol,
              max_Vol = max_Vol))
}

log_unscaler <- function(ts, min, max) {
  ts <- exp(ts * (max - min) + min) - 1
  return(ts)
}


# Get hours, minutes, seconds now -----------------------------------------

get_hms <- function() {
  time <- as.character(Sys.time())
  time <- stringr::str_extract(string = time,
                               pattern = "[0-9]{2}\\:+[0-9]{2}\\:+[0-9]{2}")
  now <- stringr::str_extract_all(string = time, pattern = "[0-9]{2}")

  hour_now <- now[[1]][1]
  minutes_now <- now[[1]][1]
  seconds_now <- now[[1]][1]

  return(list(hours = hour_now,
              minutes = minutes_now,
              seconds = seconds_now))
}


# prediction to dataset ---------------------------------------------------

predictions_to_dataset <- function(dataset, predictions){
  last_date <- dataset$Date[nrow(dataset)]
  # 1 clumn -----------------------------------------------------------------
  calendar_preds <- future_calendar(last_date, length(predictions))
  # 2 clumn -----------------------------------------------------------------
  Symbol <- dataset$Symbol[1]
  # 3 clumn -----------------------------------------------------------------
  id <- paste0(Symbol, as.numeric(calendar_preds))
  # 4 clumn -----------------------------------------------------------------
  years <- as.numeric(x = format(x = calendar_preds,"%Y"))
  # 5 clumn -----------------------------------------------------------------
  months <- as.numeric(x = format(x = calendar_preds, "%m"))
  # 6 clumn -----------------------------------------------------------------
  days <- as.numeric(x = format(x = calendar_preds, "%d"))
  # 7 clumn -----------------------------------------------------------------
  quarter <- as.numeric(gsub(pattern = "Q", replacement = "", x = quarters(calendar_preds)))
  # 8 clumn -----------------------------------------------------------------
  Weekday <- as.numeric(names(calendar_preds))
  # 9 clumn -----------------------------------------------------------------
  Date_days <- as.numeric(calendar_preds)
  # 10 clumn ----------------------------------------------------------------
  Date_days_zero <- dataset$Date_days_zero[nrow(dataset)] + 1:length(predictions)
  # 11 clumn ----------------------------------------------------------------
  Close <- as.numeric(predictions)
  # 12 clumn ----------------------------------------------------------------
  Volume <- rep(0, length(predictions))
  # 13 clumn ----------------------------------------------------------------
  tag_obs_pred = "predicted"

  new_dataset <- data.table::data.table(
    Date = calendar_preds,
    Symbol = Symbol,
    id = id,
    Year = years,
    Month = months,
    Day = days,
    Quarter = quarter,
    Weekday = Weekday,
    Date_days = Date_days,
    Date_days_zero = Date_days_zero,
    Close = Close,
    Volume = Volume,
    tag_obs_pred = tag_obs_pred
  )
  dataset <- rbind(dataset, new_dataset)

  return(dataset)
}
