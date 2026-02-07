library(tidyverse)
library(glue)
setwd("~/Desktop/CJS/0126algorithms/HW-in-one-chart-1/BABY NAMES")

df = read_csv("~/Desktop/CJS/0126algorithms/HW-in-one-chart-1/BABY NAMES/Popular_Baby_Names_20260203.csv")

df <- df %>%
  mutate(name = str_to_title(`Child's First Name`))

df_no_ethn <- df %>%
  group_by(`Year of Birth`, Gender, name) %>%
  summarize(sum_count = sum(Count)) %>%
  pivot_wider(names_from = Gender, values_from = sum_count, values_fill = 0) %>%
  mutate(pct_diff = (FEMALE-MALE)/(FEMALE+MALE)) %>%
  mutate(total_count = (FEMALE+MALE))

wide_with_var <- df_no_ethn %>%
  select(name, `Year of Birth`, pct_diff) %>%
  pivot_wider(
    names_from = `Year of Birth`,
    values_from = pct_diff
  ) %>%
  rowwise() %>%
  mutate(
    variance = var(c_across(`2011`:`2021`), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(name, variance, `2011`:`2021`)

only_w_variance <- wide_with_var %>%
  filter(variance>0)

variance_list <- only_w_variance$name

df_with_var <- df_no_ethn %>%
  filter(name %in% variance_list)

for (i in variance_list) {
    title <- paste0("All names with variance>0 in the dataset with ", i, " highlighted")
    sum <- sum(df_with_var$total_count[df_with_var$name == i])
    subtitle <- paste0("The name ", i, " appeared ", sum, " times in the dataset.")
    p <- ggplot(data = df_with_var) +
      aes(x=`Year of Birth`, y=pct_diff, group=name) +
      geom_line(color="black", linewidth=0.5) + 
      geom_line(data = filter(df_with_var, name==i), color = "red", linewidth=1) +
      labs(
        title = title,
        subtitle = subtitle
      )
      filename <- paste0("plots/all_dist", i, ".png")
      ggsave(filename, plot=p, width = 6, height = 4, units = "in")
}


df_with_var %>%
  ggplot() +
  aes(x=`Year of Birth`, y=pct_diff, group=name, color=name) +
  geom_line(color="black", linewidth=0.5) + 
  geom_line(data = filter(df_with_var, name=="Jamie"), color = "red", linewidth=1)


df_wide_for_var <- df_no_ethn %>%
  pivot_wider(names_from = name, values_from = pct_diff) %>%
  select(-FEMALE, -MALE, -total_count)

## Create naother df where i calculate variance for each name and filter where 
## variance is not 0 (or is some value) then save the name column a a list and
## then filter my original dataframe to only be that list

### I HAve to pivot wide I think? So each column is a name and each row is a year.

## list_of_names <- df$name_column

## then

##.df_other %>%
##    filter(name==c(list_of_names)) OR SOEMTHING LIKE THAT


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
