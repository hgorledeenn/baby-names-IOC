# Baby Names In-One-Chart

An *in-one-chart* story about baby names <br>
***View the full story [here](#)***

Created by **[Holden Green](https://hgorledeenn.github.io)** in February 2026 <br>
Columbia Journalism School, Algorithms class

![morgan-over-time-gif](morgan_over_time.gif)

## Contents:
1. [The Project](#the-project)
2. [Data Wrangling and Visualization](#data-wrangling-and-visualization)
3. [Survey Design](#survey-design)
4. [Setbacks](#setbacks)


## The Project

I used **[this dataset of popular baby names](https://www.ssa.gov/oact/babynames/limits.html)** from the Social Security Administration.

I was particularly interested in the topic of names that had a shift in their gender divide over time (names that were associated, over time, with both male and female babies).

After exploratory data anlysis of all the names in the dataset with some variance in the gender divide of the name, I decided to focus on the name Morgan.

![Morgan-gender-divide-chart](morgan.png)

In this data set, the name Morgan fluctuated from being only assigned to male babies in the 1950s and 60s, to almost exclusively assigned to female babies in the 1990s and 2000s. Recently, it's gotten closer to a 50/50 split than its been in more than 40 years.

## Data Wrangling and Visualization
All of the data wrangling and visualization was done in R. The annotated rScript file can be found at [baby_names_2.R](baby_names_2.R). All of the data wrangling and visualization happened in that rScript file, and all the data for the story came from [this .txt file](/namesbystate/NY.TXT).

I put to work a lot of concepts I'd learned from R-based classwork in undergrad and graduate classes. The clearest example of this is a for loop I created that iterates through each year of data for the gender divide of the name Morgan and creates one plot per new year. The below example is how I generated individual plots that I later put together in Photoshop to create the animation at the top of this file [morgan_over_time.gif](morgan_over_time.gif).

```R
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

```

## Survey Design
In addition to my data analysis, I designed a short survey about living with the name Morgan and sent it to people named Morgan who I found in the Columbia University Directory. I got 12 responses (an 18% response rate) and the anonimyzed data from the survey is in [anon-survey-data.csv](anon-survey-data.csv).


## Setbacks
I first tried my data analysis using **[this dataset of popular baby names](https://data.cityofnewyork.us/Health/Popular-Baby-Names/25th-nujf/about_data)** from the NYC Open Data portal. I did not do enough exploratory data analysis on the dataset and, only after submitting a draft to my professor, was it pointed out that the data might have some issues.

Indeed, the 
<p align="center">
<img src="old-data-year-count.png" width=50%>
</p>