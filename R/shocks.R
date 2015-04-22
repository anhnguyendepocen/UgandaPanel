# --- Plotting LSMS/RIGA panel data for map products
# Date: 2015.04
# By: Tim Essam, Phd
# For: USAID GeoCenter

# --- Clear workspace, set library list
remove(list = ls())
libs <- c ("reshape", "ggplot2", "dplyr", "RColorBrewer", "grid", "scales", "stringr", "directlabels")

# --- Load required libraries
lapply(libs, require, character.only=T)

# --- Set working directory for home or away
wd <- c("U:/UgandaPanel/Export/")
wdw <- c("C:/Users/Tim/Documents/UgandaPanel/Export")
wdh <- c("C:/Users/t/Documents/UgandaPanel/Export")
setwd(wdw)

# --- Read in as a dplyr data frame tbl
d <- tbl_df(read.csv("UGA_201504_all.csv"))

# --- Tabulation statistics of interest
shktab <- table(d$year, d$hazardShk, d$stratumP)
ftable(shktab)

# Lab RGB colors
redL   <- c("#B71234")
dredL  <- c("#822443")
dgrayL <- c("#565A5C")
lblueL <- c("#7090B7")
dblueL <- c("#003359")
lgrayL <- c("#CECFCB")

# --- Setting predefined color schema; and dpi settings
clr = "YlOrRd"
dpi.out = 500

# --- Set plot specifications for reuse throughout file
g.spec <- theme(legend.position = "none", legend.title=element_blank(), 
                panel.border = element_blank(), legend.key = element_blank(), 
                legend.text = element_text(size = 14), #Customize legend
                plot.title = element_text(hjust = 0, size = 17, face = "bold"), # Adjust plot title
                panel.background = element_rect(fill = "white"), # Make background white 
                panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #remove grid    
                axis.text.y = element_text(hjust = -0.5, size = 14, colour = dgrayL), #soften axis text
                axis.text.x = element_text(hjust = .5, size = 14, colour = dgrayL),
                axis.ticks.y = element_blank(), # remove y-axis ticks
                axis.title.y = element_text(colour = dgrayL),
                #axis.ticks.x=element_blank(), # remove x-axis ticks
                #plot.margin = unit(c(1,1,1,1), "cm"),
                plot.title = element_text(lineheight = 1 ), # 
                panel.grid.major = element_blank(), # remove facet formatting
                panel.grid.minor = element_blank(),
                strip.background = element_blank(),
                strip.text.x = element_text(size = 13, colour = dgrayL, face = "bold"), # format facet panel text
                panel.border = element_rect(colour = "black"),
                panel.margin = unit(2, "lines")) # Move plot title up

# --- Group and summarise shock data
shkH <- group_by(d, year, stratumP) %>%
    summarise(shock = mean(hazardShk, na.rm = TRUE), # create mean values for shock
            shock.n = n(), 
            shock.se = sqrt(shock*(1-shock)/shock.n)) %>% # calculate standard error
    filter(stratumP !="") # Filter missing values of stratum variable

# --- Round off and convert to percentage
shkH$rdshock <- percent(round(shkH$shock, digits = 2)) 

# Re-order factors for plotting in order
shkH$stratumP <- factor(shkH$stratumP, levels = c("North Rural", "Central Rural", "West Rural", 
                                                  "East Rural", "Other Urban", "Kampala"))
# --- Create ggplot of data
p <-ggplot(shkH, aes(x = year, y = shock, colour = stratumP)) + 
      geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
      facet_wrap(~ stratumP, ncol = 6) + 
      geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
      geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
      
  #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
      g.spec + 
      scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
      scale_y_continuous(limits = c(0,1)) + # customize y-axis
      labs(x = "", y = "Percent of households reporting shock\n", # label y-axis and create title
         title = "Natural hazards (droughts, floods & fires) are the most common  household shocks across Uganda", size = 13) +
      scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p)


# Run same analysis for health shocks
shkHlth <- group_by(d, year, stratumP) %>%
      summarise(shock = mean(healthShk, na.rm = TRUE),
                shock.n = n(),
                shock.se = sqrt(shock*(1-shock)/shock.n)) %>%
      filter(stratumP !="")
# Re-order factors for plotting in order
shkHlth %>% arrange(desc(shock, year))
shkHlth$stratumP <- factor(shkHlth$stratumP, levels = c("East Rural", "Central Rural", "North Rural", 
                                                  "West Rural", "Other Urban", "Kampala"))


# --- Create ggplot of data
p <-ggplot(shkHlth, aes(x = year, y = shock, colour = stratumP)) + 
  geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
  facet_wrap(~ stratumP, ncol = 6) + 
  geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
  
  #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
  g.spec + 
  scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
  scale_y_continuous(limits = c(0,1)) + # customize y-axis
  labs(x = "", y = "Percent of households reporting shock\n", # label y-axis and create title
       title = "Health shocks are second most common type of shock.", size = 13) +
  scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p)

# Run same analysis for crime shocks
shkCr <- group_by(d, year, stratumP) %>%
  summarise(shock = mean(crimeShk, na.rm = TRUE),
            shock.n = n(),
            shock.se = sqrt(shock*(1-shock)/shock.n)) %>%
  filter(stratumP !="")
# Re-order factors for plotting in order
shkCr %>% arrange(desc(shock, year))
shkCr$stratumP <- factor(shkCr$stratumP, levels = c("Central Rural", "East Rural", "Other Urban", 
                                                        "North Rural", "Kampala", "West Rural"))

# --- Create ggplot of data
p <-ggplot(shkHlth, aes(x = year, y = shock, colour = stratumP)) + 
  geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
  facet_wrap(~ stratumP, ncol = 6) + 
  geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
  
  #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
  g.spec + 
  scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
  scale_y_continuous(limits = c(0,1)) + # customize y-axis
  labs(x = "", y = "Percent of households reporting shock\n", # label y-axis and create title
       title = "Crime shocks have steadily declined since 2009.", size = 13) +
  scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p)


# --- Look at mosquito net use in the household (does anyone use nets?)
mosq <- group_by(d, year, stratumP) %>%
  summarise(shock = mean(mosqNet, na.rm = TRUE),
            shock.n = n(),
            shock.se = sqrt(shock*(1-shock)/shock.n)) %>%
  filter(stratumP !="")
# Re-order factors for plotting in order
mosq %>% arrange(desc(shock, year))

# rearrange factor variables to show trends in order
mosq$stratumP <- factor(mosq$stratumP, levels = c("Kampala", "East Rural", "North Rural", 
                                                        "Other Urban", "Central Rural", "West Rural"))
# Plot use overtime
p <-ggplot(mosq, aes(x = year, y = shock, colour = stratumP)) + 
  geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
  facet_wrap(~ stratumP, ncol = 6) + 
  geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
  
  #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
  g.spec + 
  scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
  scale_y_continuous(limits = c(0,1)) + # customize y-axis
  labs(x = "", y = "Percent of households using mosquito nets\n", # label y-axis and create title
       title = "Mosquito net use.", size = 13) +
  scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p)







# --- Explort food consumption scores
# Create mean value by statrum for each year

d$FCSmean <- group_by(d, year, stratumP) %>% mutate(mean(FCS, na.omit = TRUE))

c <- ggplot(d, aes(FCS, fill = stratumP)) + facet_wrap(stratumP ~ year)
pp <- c + geom_density(aes(y = ..count..)) + 
  geom_vline(d, aes(xintercept = FCSmean ), linetype = "dashed", size = 1)









