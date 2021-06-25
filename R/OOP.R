NewCat <- function(phrase = "Meow") {
  this_phrase <- phrase

  say <- function() {
    print(this_phrase)
  }

  environment()
}

cat = NewCat()
cat$phrase # Meow
cat$say() # Meow



Model_1 <- function(train) {
  this_train <- train

  prediction <- function(tr) {
    return(sum(tr) / length(tr))
  }

  environment()
}

Model_2 <- function(train) {
  this_train <- train

  prediction <- function(tr) {
    return(sum(tr) / 2  * length(tr))
  }

  environment()
}


model1 <- Model_1(c(5, 6, 7, 12, 9, 2))
model1$prediction(model1$this_train)

model2 <- Model_2(c(5, 6, 7, 12, 9, 2))
model2$prediction(model2$this_train)


print_preds <- function(model, data) {
  return(model$prediction(data))
}

print_preds(model1, data = c(5, 6, 7))
