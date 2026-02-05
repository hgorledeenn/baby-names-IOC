library(tidyverse)

df = read_csv("~/Downloads/Popular_Baby_Names_20260203.csv")

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


df_only_mandf %>%
  ggplot() +
  aes(x=reorder(name, -pct_diff), y=pct_diff, fill=diff_size) +
  geom_col() +
  labs(
    title="% Difference in occurrences of names between females and males",
    subtitle = str_wrap("Positive values show a name is more common among women, negative show a name is more common among men.", width=65)
  ) +
  theme(
    axis.text.x = element_text(size = 10, angle=270)
    )
