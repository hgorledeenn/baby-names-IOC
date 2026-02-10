# Baby Names In-One-Chart

An *in-one-chart* story about baby names <br>
***View the full story [here](#)***

Created by **[Holden Green](https://www.holdengreen.me)** in February 2026 <br>
Columbia Journalism School, Algorithms class

![baby-names-gif](animation/individual_names.gif)

## The Project

I first came across **[this dataset of popular baby names](https://data.cityofnewyork.us/Health/Popular-Baby-Names/25th-nujf/about_data)** from the NYC Open Data portal, then came up with the idea for the story.

I was particularly interested in the topic of names that had a shift in their gender divide over time (names that were associated, over time, with both male and female babies).

After exploratory data anlysis of all the (36) names in the dataset with some variance in the gender divide of the name, I decided to focus on the name Milan.

![Milan-gender-divide-chart](plots/19-Milan.png)

In this data set, the name Milan fluctuated from being only assigned to female babies in 2011 and 2012, to only assigned to male babies in 2017, and was closer to an even split at the end of the data. While some other names had 

## Data Wrangling and Visualization
All of the data wrangling and visualization was done in R. The annotated rScript file can be found at [baby_names.R](baby_names.R). All of the data wrangling and visualization happened in that rScript file, and all the data for the story came from [this csv](Popular_Baby_Names_20260203.csv).

I put to work a lot of concepts I'd learned from R-based classwork in undergrad and graduate classes. The clearest example of this is a for loop I create that iterates through baby names with a variance>0 in the gender divide of the name over time, and creates one plot per name highlighting that name's line. The below example is how I generated individual plots that I later put together in Photoshop to create the animation [individual_names.gif](individual_names.gif).

```R
for (i in variance_list) {
## 1. Define current rank for file naming later
  current_rank <- wide_with_var %>%
    filter(name == i) %>%
    pull(rank)
  p <- ggplot(data = df_with_var) +
    aes(x=`Year of Birth`, y=pct_diff, group=name) +
## 2. Add all names as gray lines in the background
    geom_line(color="grey50", linewidth=0.5) +
## 3. Highlight the y=0 line in black to improve readability of later text annotations
    geom_hline(yintercept = 0, color = "black", linewidth = 0.5) +
## 4. Add highlighted name as thicker red line on top
    geom_line(data = filter(df_with_var, name==i), color = "red", linewidth=1) +
## 5. Add "More Female" and "More Male" text annotations in black to improve readability of chart
    annotate("text",
             x = 2021, y = 0.1,
             label = "More Female ↑",
             color = "black", size = 5,
             fontface = "bold", alpha=0.9, hjust=1) +
    annotate("text",
             x = 2021, y = -0.1,
             label = "More Male ↓",
             color = "black", size = 5,
             fontface = "bold", alpha=0.9, hjust=1) +
## 6. Add the highlighted name as a text annotation    
    annotate("text",
             x = 2011.25, y = 0.8,
             label = i,
             color = "grey20", size = 26,
             fontface = "bold", alpha=0.6, hjust=0, vjust=1) +
    labs(
      x = "Year of Birth",
      y = "Gender Difference"
    )
  filename <- paste0("for_animating/", current_rank, "-", i, ".png")
  ggsave(filename, plot=p, width = 6, height = 4, units = "in")
}
```

## Non-Data Sources
In addition to my data analysis, I spoke to multiple people named Milan for my reporting.

