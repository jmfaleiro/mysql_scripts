#!/usr/bin/env Rscript
library("argparse")
library("dplyr")
library("forcats")
library("ggplot2")
library("ggsci")
library("readr")
library("scales")
library("tidyr")

parser <- ArgumentParser()

parser$add_argument("-o", "--out", type = "character", help = "out file for plot")
parser$add_argument("csvs",
  metavar = "csv", type = "character", nargs = "+",
  help = "list of csv files to read in"
)

args <- parser$parse_args()

out <- args$out

data <- tibble()
for (csv in args$csvs) {
  data <- bind_rows(data, read_csv(csv))
}

bar_chart <- function(data, x = x, y = y, se = se, fill = fill,
                      ylims = NULL, ybreaks = NULL,
                      xtitle = NULL, ytitle = NULL, filltitle = NULL) {
  g <- ggplot(
    data,
    aes(
      x = as.factor(!!enquo(x)),
      y = !!enquo(y),
      fill = as.factor(!!enquo(fill)),
    )
  )

  if (is.null(ybreaks)) {
    ybreaks <- waiver()
  } else if (is.numeric(ybreaks) && length(ybreaks) == 1) {
    ybreaks <- pretty_breaks(n = ybreaks)
  }

  barwidth <- 0.9
  errorwidth <- 0.4

  g <- g +
    geom_col(position = position_dodge(width = barwidth), color = "black") +
    ## geom_errorbar(position = position_dodge(width = barwidth), width = errorwidth) +
    scale_y_continuous(
      limits = ylims,
      breaks = ybreaks,
      expand = c(0, 0)
    ) +
    scale_fill_brewer(type = "div", palette = "Paired") +
    labs(
      x = xtitle,
      y = ytitle,
      fill = filltitle
    ) +
    # guides(fill = guide_legend(nrow = 2)) +
    theme_classic(
      base_size = 28,
      base_family = "serif"
    ) +
    theme(
      axis.text = element_text(size = 28, color = "black"),
      axis.title = element_text(size = 32, color = "black"),
      legend.text = element_text(size = 28, color = "black"),
      legend.title = element_text(size = 32, color = "black"),
      legend.position = "top",
      legend.justification = "left",
      legend.margin = margin(0, 0, -10, 0),
      panel.grid.major.y = element_line(color = "black", linetype = 2),
      panel.spacing = unit(0, "mm"),
      plot.margin = margin(5, 5, 10, 5),
    )

  return(g)
}

summary <- data %>%
    filter(server != "Primary") %>%
    group_by(server, n_clients, n_workers, n_roclients) %>%
    summarize(
        med_relative_commit_rate = median(relative_commit_rate),
        mean_relative_commit_rate = mean(relative_commit_rate),
        sd = sd(relative_commit_rate),
        se = sd(relative_commit_rate) / sqrt(n())
    ) %>%
    ungroup() %>%
    mutate(
        server = fct_relevel(server, c("FDR", "FDR+fRO", "FDR+kRO", "FDR+CO", "KuaFu", "KuaFu+kRO", "KuaFu+CO"))
    )

summary

p <- bar_chart(summary,
  x = n_roclients, y = med_relative_commit_rate, fill = server,
  ylims = c(0, 1.02), ybreaks = 6,
  xtitle = "# RO Clients", ytitle = "Relative Commit Rate"
)

# Output
width <- 10 # inches
height <- (9 / 16) * width

ggsave(out, plot = p, height = height, width = width, units = "in")
