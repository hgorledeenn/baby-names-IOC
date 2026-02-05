library(tidyverse)

df = read_csv("~/Desktop/CJS/0126algorithms/HW-in-one-chart-1/BABY NAMES/Popular_Baby_Names_20260203.csv")

df_no_yrs <- df %>%
  mutate(name = str_to_title(`Child's First Name`)) %>%
  group_by(Gender, name) %>%
  summarize(sum_count = sum(Count))
  
df_wider <- df_no_yrs %>%
  pivot_wider(names_from = Gender, values_from = sum_count, values_fill = 0)

df_only_mandf <- df_wider %>%
  filter(FEMALE>0 & MALE>0) %>%
  mutate(pct_diff = (FEMALE-MALE)/(FEMALE+MALE)) %>%
  mutate(total_count = FEMALE+MALE) %>%
  mutate(diff_size = abs(FEMALE-MALE)) %>%
  arrange(desc(pct_diff))


vertical_cols <- df_only_mandf %>%
  ggplot() +
  aes(x=reorder(name, -pct_diff), y=pct_diff, fill=diff_size) +
  geom_col() +
  labs(
    title="% Difference in occurrences of names between females and males",
    subtitle = str_wrap("Positive values show a name is more common among women, negative show a name is more common among men.", width=65),
    x = "Names",
    y = "Percent difference in occurrences of name by gender",
    fill = str_wrap("Total Name Count", width=15)
  ) +
  theme(
    axis.text.x = element_text(size = 10, angle=270)
    )

horizontal_bars <- df_only_mandf %>%
  ggplot() +
  aes(x=reorder(name, -pct_diff), y=pct_diff, fill=diff_size) +
  geom_bar(stat="identity") +
  coord_flip() +
  labs(
    title = str_wrap("% Difference in occurrences of names between females and males", width=65),
    subtitle = str_wrap("Positive values show a name is more common among women, negative show a name is more common among men.", width=65),
    x = "Names",
    y = "Percent difference in occurrences of name by gender",
    fill = str_wrap("Total Name Count", width=15)
  ) +
  theme(
    axis.text.y = element_text(size = 10, angle=0)
  )

ggsave("column_chart_1.png", 
       plot = vertical_cols, 
       width = 8, 
       height = 6, 
       units = "in", 
       dpi = 300)

ggsave("bar_chart_1.png", 
       plot = horizontal_bars, 
       width = 7, 
       height = 8, 
       units = "in", 
       dpi = 300)
