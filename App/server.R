shinyServer(function(input, output, session){
  
  observe({
    if(input$update_user_data == 0 && !initial_user) {
      return()
    }
    isolate({
      initial_user = FALSE
      username <- input$username
      recent_pictures <- recent_pictures_for_user(input, session)
      picture_number <- length(recent_pictures)
      output$user_chart <- renderChart({
        progress <- shiny::Progress$new(session, min=0, max=2)
        progress$set(message = "Preparing Data", value = 1)
        likes_comments_df = data.frame( number=1:length(recent_pictures))
        
        for (i in 1:length(recent_pictures))
        {
          likes_comments_df$comments[i] = recent_pictures[[i]]$comments$count
          likes_comments_df$likes[i] = recent_pictures[[i]]$likes$count
          likes_comments_df$date[i] <- toString(as.POSIXct(as.numeric(recent_pictures[[i]]$created_time), origin="1970-01-01"))
        }
        progress$set(message = "Building Chart", value = 2)
        h1 <- Highcharts$new()
        h1$set(dom="user_chart")
        h1$chart(type="spline")
        h1$title(text="Likes and Comments")
        h1$subtitle(text=paste0(picture_number, " Most Recent Posts by ", username))
        h1$series(data=likes_comments_df$likes,name="Likes")
        h1$series(data=likes_comments_df$comments,name="Comments")
        h1$yAxis(title = list(text="Number of Interactions"))
        h1$xAxis(title = list(text="Individual Posts"))
        progress$close()
        h1
      })
      
      output$user_map <- renderMap({
        progress <- shiny::Progress$new(session, min=0, max=2)
        map <- Leaflet$new()
        map$setView(c(0,0), zoom=1)
        locations <- get_locations(recent_pictures, progress)
        progress$set(message="Building Map", value=2)
        if(!is.null(locations)){
          apply(locations, 1, function(location){
            map$marker(c(location$Latitude[[1]], location$Longitude[[1]]), bindPopup = location$Text)
          })
        }
        progress$close()
        map
      })
    })
  })
  
  observe({
    if (input$update_hashtag_data == 0 && !initial_hashtag)
    {
      return()
    }
    
    isolate({
      initial_hashtag = FALSE
      recent_pictures <- recent_pictures_for_hashtag(input, session)
      output$map2 <- renderMap({
        progress <- shiny::Progress$new(session, min=0, max=2)
        map <- Leaflet$new()
        map$setView(c(0,0), zoom=1)
        locations <- get_locations(recent_pictures, progress)
        progress$set(message="Building Map", value=2)
        if(!is.null(locations)){
          apply(locations, 1, function(location){
            map$marker(c(location$Latitude[[1]], location$Longitude[[1]]), bindPopup = location$Text)
          })
        }
        progress$close()
        map
      })
    })
  })
})