library(tidyverse)
library(ggrepel)
library(scales)
setwd("~/Desktop/CJS/0126algorithms/HW-in-one-chart-1/")


## Read in the data (which doesn't have headers) and assign column names
df <- read.csv("~/Desktop/CJS/0126algorithms/HW-in-one-chart-1/namesbystate/NY.TXT",
               header = FALSE, col.names = c('state', 'gender', 'year', 'name', 'count'))

#########################################################################
#/////////////////////////////  Exploratory  ///////////////////////////#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\  Data         \\\\\\\\\\\\\\\\\\\\\\\\\\\#
#/////////////////////////////  Analysis     ///////////////////////////#
#########################################################################

EDA_year_sum_count <- df %>%
  group_by(year) %>%
  summarise(sum_count = sum(count)) %>%
  mutate(pct_total = (sum_count/sum(sum_count))*100)

# It looks like the above dataframe has a somewhat equal distrobution of pct_total
# (the min is 0.18% of total for a given year in 1910, and the max is 1.365% in 1957)

## Google told me this make a global setting to prefer raw numbers for ggplot axes
## over scientific notation
options(scipen = 999)

EDA_year_bygender_sum_count <- df %>%
  group_by(year, gender) %>%
  summarise(sum_count = sum(count)) %>%
  mutate(pct_total = (sum_count/sum(sum_count))*100)

EDA_year_sum_count %>%
  ggplot() +
  aes(x=year, y=sum_count) +
  geom_line()

EDA_year_bygender_sum_count %>%
  ggplot() +
  aes(x=year, y=sum_count, color=gender) +
  geom_line() +
  scale_color_manual(values = c("F" = "red", "M" = "blue"))

## Also, the distrobution by gender seems to be roughly the same between the two genders
## in the dataset. These plots also seem to be similar to national birth rate plots like
## from the Pew Research Center (https://www.pewresearch.org/short-reads/2013/09/06/chart-of-the-week-big-drop-in-birth-rate-may-be-levelling-off/)
## from the St. Louis Fed (https://fred.stlouisfed.org/series/SPDYNCBRTINUSA)
## and the CDC (https://www.cdc.gov/mmwr/volumes/69/wr/mm6901a5.htm)

EDA_year_sum_count %>%
  ggplot() +
  aes(x=year, y=pct_total) +
  geom_line()

EDA_year_bygender_sum_count %>%
  ggplot() +
  aes(x=year, y=pct_total, color=gender) +
  geom_line() + 
  scale_color_manual(values = c("F" = "red", "M" = "blue"))

## Plotting pct_of_total broken down by gender shows more clearly what the above by-gender
## chart also showed: this data also follows the expected trend of more male babies
## being born every year than female babies (https://www.bbc.com/news/health-46597323)

## It does show some weird quirk in the first few years of the data (>65% female births 
## as compared to male birth that year). Because of this oddity I'll focus more on later
## years (I want my analysis to look more at modern times anyways!)





################################################################################
#/////////////////////////////  Non-Exploratory     ///////////////////////////#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\  Data                \\\\\\\\\\\\\\\\\\\\\\\\\\\#
#/////////////////////////////  Analysis            ///////////////////////////#
################################################################################


## I made the df below to have one row now represent one name/year pairing and have
## columns with the counts for each gender for that name in that year. I also calculated
## another column that shows the pct_diff in the gender split of each name where an
## all female name = 1 and an all male name = -1.

## I decided, based partially on the findings of my EDA and partially from the goals of
## my project, to filter my dataset to only contain names after 1950. I'm not as interested
## in the gender divide of names from before that time period. My working data for the project
## will be in the aptly named `working_df`:
working_df <- df %>%
  filter(year>=1950)


## I created the below dataframe that:
##    1. Pivots the gender variable wider so one row represents one name in a given year
##       and it has 2 columns, one for female count and one for male count
##.   2. calculates the pct_diff of gender difference (1 = entirely female name
##                                                     2 = entirely male name)

df_one_row_per_name_yr <- working_df %>%
  select(-state) %>%
  pivot_wider(names_from = gender, values_from = count, values_fill = 0) %>%
  mutate(total_count = (F+M)) %>%
  mutate(pct_diff = (F-M)/total_count)


## The below dataframe pivots the pct_diff column to wide and then calculates
## the variance of the gender pct_diff per name across the years of the dataset.
## It preserves "na" values
wide_with_var <- df_one_row_per_name_yr %>%
  select(name, year, pct_diff) %>%
  pivot_wider(
    names_from = year,
    values_from = pct_diff
  ) %>%
  rowwise() %>%
  mutate(
    variance = var(c_across(`1950`:`2024`), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(name, variance, `1950`:`2024`)


## Plotting a histogram of the variance values yields what I would largely expect:
## most names have a variance near 0, very few have variance>0
wide_with_var %>%
  ggplot() +
  aes(x=variance) + 
  geom_histogram(bins = 10)


## I made this dataframe to serve as a reference that I can merge into the variance dataframe,
## which will allow me to further refine the names I analyze by their total counts
total_count_wide <- df_one_row_per_name_yr %>%
  select(name, year, total_count) %>%
  pivot_wider(
    names_from = year,
    values_from = total_count,
    values_fill = 0
  ) %>%
  rowwise() %>%
  mutate(
    sum_count = sum(c_across(`1950`:`2024`), na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(name, sum_count)


## I created the below dataframe that only selects the columns `name` and `variance`
only_var <- wide_with_var %>%
  select(name, variance)

## I made the below dataframe by combining the variance and sum_count columns from the
## above datasets on the name column. The resulting dataframe has 14970 rows, the same
## amount as the two intermediate dataframes
var_and_count_all <- inner_join(only_var, total_count_wide, by = "name")

var_and_count_all %>%
  ggplot() + 
  aes(x=variance, y=sum_count) + 
  geom_point(alpha=0.2)

## The above visualization is interesting, I think. It shows that the most popular names
## (pretty much anything above ~50,000 total occurrences across the dataset, or an average
## of 675 babies/year) have a variance equal to or very near 0.


var_over_zero <- var_and_count_all %>%
  filter(variance>0)

var_over_zero %>%
  ggplot() + 
  aes(x=variance, y=sum_count) + 
  geom_point(alpha=0.2)

## The above visualization looks *remarkably* similar to the one before it, though this one
## uses the `var_over_zero` dataframe, which only has datapoints with variance>0.

var_over_zero %>%
  ggplot() + 
  aes(x=sum_count) +
  geom_histogram(bins = 100)

var_over_zero %>%
  ggplot() + 
  aes(x=variance) +
  geom_histogram(bins = 100)

## This above histograms show that, even among names with variance>0, there are just a lot that
## have a count somewhat close to 0 and/or a variance close to 0. My next step in finding
## meaningful non-gendered names will be to further filter variance and sum_count

var_count_filtered <- var_over_zero %>%
  filter(variance>0.15) %>%
  filter(sum_count>5000)

list_of_names <- var_count_filtered$name

######################   When variance>0   ######################
## Filtering to   sum_count>10 returned       1060 names
## Filtering to   sum_count>100 returned      886 names
## Filtering to   sum_count>1000 returned     560 names
## filtering to   sum_count>10000 returned    265 names


######################   When variance>0,25   ###################
## Filtering to   sum_count>10 returned       300 names
## Filtering to   sum_count>100 returned      156 names
## Filtering to   sum_count>1000 returned     39 names
## filtering to   sum_count>10000 returned    8 names

var_count_filtered %>%
  ggplot() + 
  aes(x=variance, y=sum_count) +
  geom_point()

only_w_list_of_names <- df_one_row_per_name_yr %>%
  filter(name %in% list_of_names)

################################################################################
########################   FOR LOOP TO MAKE GRAPHICS   #########################
################################################################################

for (i in list_of_names) {
  ## 1. Define/find some variables for later
  title <- paste0("All names with variance>0.1 and count>5000 in the dataset with ", i, " highlighted")
  sum <- sum(var_count_filtered$sum_count[var_count_filtered$name == i])
  var <- sum(var_count_filtered$variance[var_count_filtered$name == i])
  subtitle <- paste0("The name ", i, " appeared ", sum, " times in the dataset and had a variance of ", var, ".")
  ## 2. Make the plot
  p <- ggplot(data = only_w_list_of_names) +
    aes(x=year, y=pct_diff, group=name) +
    ## 3. First geom_line adds all names as black lines
    geom_line(color="black", linewidth=0.5, alpha=0.25) + 
    ## 4. Second geom_line adds the particular name in a thicker red line on top
    geom_line(data = filter(only_w_list_of_names, name==i), color = "red", linewidth=1) +
    ## 5. Reference previously defined variables to add labels
    labs(
      title = title,
      subtitle = str_wrap(subtitle, 60)
    )
  filename <- paste0("plots/", i, ".png")
  ggsave(filename, plot=p, width = 6, height = 4, units = "in")
}

## The above for loop iterates through all the names in my df `var_count_filtered`
## and makes individual charts with each name that highlight that names variance over time

## I then went through myself in the folder to identify any names with interesting trends:
##    NAME       COUNT       VARIANCE
##    Ariel      9651        0.2335    
##    Avery      10779       0.3927
##    Casey      9063        0.1706
##    Joan       18944       0.3244
##    Morgan     11489       0.5916
##    Riley      10750       0.3444

## From this list, the name Morgan has the highest variance and the second highest count



## Want to:
## Visualize Morgan's pct_diff nicely:
###  Have to have one ggplot layer from the all-time df as a line
###  Add another layer that is EITHER the all-time df as a dot plot (so each data
###     point is clearly highlighted) OR from a filtered df that only has data for
###     something like every 5 years or only interesting years
###  Add another layer that is some filtered dataframe with only certain years as
###     point labels with ggrepel

only_morgan <- only_w_list_of_names %>%
  filter(name == "Morgan")


only_morgan <- only_morgan %>%
  mutate(real_pct_diff = (pct_diff/2)+0.5) %>%
  mutate(bigger_share = ifelse(F > M, "Female", "Male"))

only_morgan_longer <- only_morgan %>%
  pivot_longer(
    cols = c("F", "M"),
    names_to = "Gender",
    values_to = "Count"
  )

morgan_plot <- ggplot(data = only_morgan) +
  aes(x=year, y=real_pct_diff, color = bigger_share) +
  geom_line(color="black", size=0.5, alpha=0.5) +
  geom_point(size=2) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_hline(yintercept = 0.25, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "gray10", linewidth = 0.5, alpha = 0.75) +
  geom_hline(yintercept = 0.75, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_hline(yintercept = 1, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1950, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1965, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1980, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1995, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 2010, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 2025, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_hline(yintercept = 0.6825397, color = "hotpink", linewidth = 0.5, linetype = "dashed", alpha=0.5) +
  scale_y_continuous(breaks = c(0, .25, .5, .75, 1),
                     limits = c(0, 1),
                     labels = scales::label_percent(scale = 100)) +
  scale_x_continuous(breaks = c(1950, 1965, 1980, 1995, 2010, 2025)) +
  scale_color_manual(values = c("Female" = "hotpink", "Male" = "dodgerblue")) +
  annotate("text",
          x = 2025, y = 0.53,
          label = "More Female ↑",
          color = "black", size = 4,
          fontface = "bold", alpha=.75, hjust=1) +
  annotate("text",
           x = 2025, y = 0.47,
           label = "More Male ↓",
           color = "black", size = 4,
           fontface = "bold", alpha=.75, hjust=1) +
  annotate("text",
           x = 2023, y = 0.66,
           label = "68% Female",
           color = "hotpink", size = 3,
           fill = "white",
           fontface = "bold", alpha=.75, hjust=1) +
  labs(
    title = "The name 'Morgan' might be past its mostly-female peak",
    subtitle = "Share of babies named Morgan who were female from 1950-2024",
    x = "Year of Birth",
    y = "Percent Female",
    color = "Majority Gender",
    caption = "Created by Holden Green | Data source: SSA Baby Names"
  ) +
  theme_test() +
  theme(legend.position = "top",
        legend.justification = "left",
        legend.background = element_rect(color="gray15", linetype="solid", linewidth = 0.25),
        legend.margin = margin(3,5,3,5),
        legend.title = element_text(size=7),
        legend.text = element_text(size=7),
        legend.key.size = unit(0.75,"line")) +
  guides(color=guide_legend(override.aes = list(size=2)))

ggsave(paste0("~/Desktop/CJS/0126algorithms/HW-in-one-chart-1/morgan.png"), plot=morgan_plot, width = 6, height = 5, units = "in")



years = c(1950:2024)

for (i in years) {
  p <- ggplot(data = filter(only_morgan, year<=i)) +
    annotate("text",
             x = 1950, y = 0.95,
             label = i,
             color = "grey20", size = 26,
             fontface = "bold", alpha=0.6, hjust=0, vjust=1) +
  aes(x=year, y=real_pct_diff, color = bigger_share) +
  geom_line(color="black", size=0.5, alpha=0.5) +
  geom_point(size=2) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_hline(yintercept = 0.25, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black", linewidth = 0.5, alpha = 0.75) +
  geom_hline(yintercept = 0.75, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_hline(yintercept = 1, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1950, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1965, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1980, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 1995, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 2010, color = "black", linewidth = 0.25, alpha = 0.25) +
  geom_vline(xintercept = 2025, color = "black", linewidth = 0.25, alpha = 0.25) +
  scale_y_continuous(breaks = c(0, .25, .5, .75, 1),
                     limits = c(0, 1),
                     labels = scales::label_percent(scale = 100)) +
  scale_x_continuous(breaks = c(1950, 1965, 1980, 1995, 2010, 2025)) +
  scale_color_manual(values = c("Female" = "hotpink", "Male" = "dodgerblue")) +
  annotate("text",
           x = 2025, y = 0.53,
           label = "More Female ↑",
           color = "black", size = 4,
           fontface = "bold", alpha=.75, hjust=1) +
  annotate("text",
           x = 2025, y = 0.47,
           label = "More Male ↓",
           color = "black", size = 4,
           fontface = "bold", alpha=.75, hjust=1) +
  labs(
    title = "The name 'Morgan' might be past its mostly-female peak",
    subtitle = "Share of babies named Morgan who were female from 1950-2024",
    x = "Year of Birth",
    y = "Percent Female",
    color = "Majority Gender",
    caption = "Created by Holden Green | Data source: SSA Baby Names"
  ) +
  theme_test() +
  theme(legend.position = "top",
        legend.justification = "left",
        legend.background = element_rect(color="gray15", linetype="solid", linewidth = 0.25),
        legend.margin = margin(3,5,3,5),
        legend.title = element_text(size=7),
        legend.text = element_text(size=7),
        legend.key.size = unit(0.75,"line")) +
    guides(color=guide_legend(override.aes = list(size=2)))
  ggsave(paste0("~/Desktop/CJS/0126algorithms/HW-in-one-chart-1/year_plots_morgan/", i, ".png"), plot=p, width = 6, height = 5, units = "in")
}
