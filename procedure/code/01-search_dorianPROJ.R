# search geographic twitter data for Hurricane Dorian
# by Joseph Holler, 2019,2021
# This code requires a twitter developer API token!
# See https://cran.r-project.org/web/packages/rtweet/vignettes/auth.html

# install packages for twitter querying and initialize the library
packages = c("rtweet","here","dplyr","rehydratoR")
setdiff(packages, rownames(installed.packages()))
install.packages(setdiff(packages, rownames(installed.packages())),
                 quietly=TRUE)

library(rtweet)
library(here)
library(dplyr)
library(rehydratoR)

############# SEARCH TWITTER API ############# 

#<<<<<<< HEAD
#reference for search_tweets function: https://rtweet.info/reference/search_tweets.html 
#don't add any spaces in between variable name and value. i.e. n=1000 is better than n = 1000
#the first parameter in quotes is the search string, searching tweet contents and hashtags
#n=10000 asks for 10,000 tweets
#if you want more than 18,000 tweets, change retryonratelimit to TRUE and wait 15 minutes for every batch of 18,000
#include_rts=FALSE excludes retweets.
#token refers to the twitter token you defined above for access to your twitter developer account
#geocode is equal to a string with three parts: longitude, latidude, and distance with the units mi for miles or km for kilometers

install.packages("RPostgres")
#load("C:/Users/jofia/github/RE-Dorian/data/derived/private/dorian.RData")

#set up twitter API information
#this should launch a web browser and ask you to log in to twitter
#replace app, consumer_key, and consumer_secret data with your own developer acct info
twitter_token <- create_token(
  app = "naturaldisasterspatialclustering",  					#replace yourapp with your app name
  consumer_key = "",  		#replace yourkey with your consumer key
  consumer_secret = "")  #replace yoursecret with your consumer secret
#=======
# reference for search_tweets function: 
# https://rtweet.info/reference/search_tweets.html 
# don't add any spaces in between variable name and value for your search
# e.g. n=1000 is better than n = 1000
# the first parameter in quotes is the search string
# n=10000 asks for 10,000 tweets
# if you want more than 18,000 tweets, change retryonratelimit to TRUE and 
# wait 15 minutes for every batch of 18,000
# include_rts=FALSE excludes retweets.
# token refers to the twitter token you defined above for access to your twitter
# developer account
# geocode is equal to a string with three parts: longitude, latitude, and 
# distance with the units mi for miles or km for kilometers

# set up twitter API information with your own information for
# app, consumer_key, and consumer_secret
# this should launch a web browser and ask you to log in to twitter
# for authentication of access_token and access_secret
twitter_token = create_token(
  app = "naturaldisasterspatialclustering",                     #enter your app name in quotes
  consumer_key = "",  		      #enter your consumer key in quotes
  consumer_secret = "",         #enter your consumer secret in quotes
#>>>>>>> upstream/main
  access_token = NULL,
  access_secret = NULL
)

#<<<<<<< HEAD
#get tweets for tornado, searched on 5/4/21
tweets <- search_tweets("tornado OR tornado warning OR debris", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-87,500mi", retryonratelimit=TRUE)

write.table(tweets$status_id,
            here("data","derived","public","tweetids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

#get tweets without any text filter for the same geographic region in late Apr/early May, searched on 5/4/21
#the query searches for all verified or unverified tweets, so essentially everything
tweetsTotal <- search_tweets("-filter:verified OR filter:verified", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-87,500mi", retryonratelimit=TRUE)

write.table(tweetsTotal$status_id,
            here("data","derived","public","tweetsTotalids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)


#load(here("data","derived","private","dorian.RData"))

# In the following code, you can practice running the queries on dorian3

############# FIND ONLY PRECISE GEOGRAPHIES ############# 

#reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
#adds a lat and long field to the data frame, picked out of the fields you indicate in the c() list
#sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))
install.packages("tidyverse")
load("tidyverse")


# list unique/distinct place types to check if you got them all
unique(tweets$place_type) #city, admin, poi, neighborhood, NA
#=======


############# FILTER DORIAN FOR CREATING PRECISE GEOMETRIES ############# 

# reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
# adds a lat and long field to the data frame, picked out of the fields
# that you indicate in the c() list
# sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))
#>>>>>>> upstream/main

# list and count unique place types
# NA results included based on profile locations, not geotagging / geocoding.
# If you have these, it indicates that you exhausted the more precise tweets 
# in your search parameters and are including locations based on user profiles
count(tweets, place_type)

#  <chr>        <int>
#1 admin          464
#2 city           319
#3 neighborhood     1
#4 poi              7
#5 NA            7700


# convert GPS coordinates into lat and lng columns
# do not use geo_coords! Lat/Lng will be inverted
tweets = lat_lng(tweets, coords=c("coords_coords"))
tweetsTotal = lat_lng(tweetsTotal, coords=c("coords_coords"))

# select any tweets with lat and lng columns (from GPS) or 
# designated place types of your choosing
tweets = subset(tweets, 
                place_type == 'city'| place_type == 'neighborhood'| 
                  place_type == 'poi' | !is.na(lat))
#752
tweetsTotal = subset(tweetsTotal,
                  place_type == 'city'| place_type == 'neighborhood'| 
                    place_type == 'poi' | !is.na(lat))
#8914

# convert bounding boxes into centroids for lat and lng columns
tweets = lat_lng(tweets,coords=c("bbox_coords"))
tweetsTotal = lat_lng(tweetsTotal,coords=c("bbox_coords"))

# re-check counts of place types
count(tweets, place_type)

#place_type       n
#<chr>        <int>
#  1 admin          425
#2 city           319
#3 neighborhood     1
#4 poi              7

############# SAVE FILTERED TWEET IDS TO DATA/DERIVED/PUBLIC ############# 

write.table(tweetsTotal$status_id,
            here("data","derived","public","tweettotalfiltids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

write.table(tweets$status_id,
            here("data","derived","public","tweetfiltids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

############# SAVE TWEETs TO DATA/DERIVED/PRIVATE ############# 

saveRDS(tweets, here("data","derived","private","tweets.RDS"))
saveRDS(tweetsTotal, here("data","derived","private","tweetsTotal.RDS"))


