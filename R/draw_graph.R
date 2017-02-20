library(tidyverse)

overflow = 0.02
cbdg= tibble(
  x = seq(0.0, 1.0, length.out = 100),
  y = x ^ 0.34 - 1
)

p = ggplot(cbdg) + geom_line(aes(x, y))

x_axis = function(...) {
  # Draw x-axis
  # This funtion assumes that the data has columns named x and y
  geom_segment(aes(x = min(x), xend = max(x),
                   y = min(y), yend = min(y)),
               arrow = arrow(length = unit(0.02, "npc")),
               inherit.aes = FALSE)
}

y_axis = function(...) {
  # Draw x-axis
  # This funtion assumes that the data has columns named x and y
  geom_segment(aes(x = min(x), xend = min(x),
                   y = min(y), yend = max(y)),
                 arrow = arrow(length = unit(0.02, "npc")),
                 inherit.aes = FALSE)
}
show(p + x_axis() + y_axis() + theme_void())
