# install.packages("bslib")
# install.packages("bsicons")
# install.packages("htmlwidgets")
# install.packages("shiny")
# install.packages("googletraffic")

google_api = "AIzaSyCIOozYm0gtLrFVwoyCa-0RVXbf0dQh-zs" 

## Load package
library(googletraffic)

## Load additional packages to run below examples
library(tidyverse)
library(raster)

## Set API key
google_key <- "AIzaSyCIOozYm0gtLrFVwoyCa-0RVXbf0dQh-zs" #"GOOGLE-KEY-HERE"


## Make raster
r <- gt_make_raster(location   = c(40.712778, -74.006111),
                    height     = 2000,
                    width      = 2000,
                    zoom       = 16,
                    google_key = google_key)

## Plot
r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
names(r_df) <- c("value", "x", "y")

ggplot() +
  geom_raster(data = r_df, 
              aes(x = x, y = y, 
                  fill = as.factor(value))) +
  labs(fill = "Traffic\nLevel") +
  scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
  coord_quickmap() + 
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))






install.packages("webshot")
webshot::install_phantomjs()






