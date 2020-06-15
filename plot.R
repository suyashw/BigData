library(ggplot2)
library(readr)

d <- read_csv("plot.csv")

# To plot time taken for different frameworks.
ggplot(d, aes(x = n, y = Time, color = Tool)) +
  geom_point() + geom_line() + scale_x_log10(breaks = c(0.01,0.1,1)) + scale_y_log10()

# To plot AUC for different frameworks.
ggplot(d, aes(x = n, y = AUC, color = Tool)) +
  geom_point() + geom_line() + scale_x_log10(breaks = c(0.01,0.1,1))

# To plot memory footprint for different framework.
ggplot(d, aes(x = n, y = RAM, color = Tool)) +
  geom_point() + geom_line() + scale_x_log10(breaks = c(0.01,0.1,1))
