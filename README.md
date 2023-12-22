# CoreDataFavoriteMovies
## Get Familiar
- Start from the main branch of the project
- It already has some basic pieces in place. 
- We didn't want to waste too much time with setting this project up and not be able to get to the Core Data stuff
- Run the project and see how incredible it is!
    - Who doesn't want an app that ignores your search string and always returns the same 3 movies?! 
- Then, take a look at each of the files and see how everything works. 
- First we'll get the API to actually start returning the correct search results
- Then we'll start adding our favorite movies to Core Data

## Movie API
### Postman
- I always like to see the response I'm going to get from API before I try and code it up
- The api we'll be using can be found [here](http://www.omdbapi.com)
- Click on the `API Key` tab and get yourself an API key. You'll need it to be able to use the api
- Once you've got your API key we're going to try and test out the api
- If you don't have the `Postman` app downloaded already, download it [here](https://www.postman.com/downloads/)
- Grab the example url from the omdb documentation
- Insert your api key as a parameter
- Add the search parameter `s` to your query and search for a movie title (whatever you want)
- Check out the response it gives you. 
- I searched for `batman` and this is the first result I got:
```
{
    "Title": "Batman Begins",
    "Year": "2005",
    "imdbID": "tt0372784",
    "Type": "movie",
    "Poster": "https://m.media-amazon.com/images/M/MV5BOTY4YjI2N2MtYmFlMC00ZjcyLTg3YjEtMDQyM2ZjYzQ5YWFkXkEyXkFqcGdeQXVyMTQxNzMzNDI_V1_SX300.jpg"
 }
```

### Swift
- Now that we know what this API looks like, lets write the networking code to fetch a movie
- Go to the `MovieAPIController.swift` file and see what its doing right now. 
    - Its not even going up to the api! Its just returning those same 3 fake movies every time
    - Lets fix that
- Find this function: `func fetchMovies(with searchTerm: String) async throws -> [APIMovie]`
- We won't tell you everything that will go in this function, you'll need to do some of it on your own. But here's some help:
    - Don't call the `fakeMovies()` function anymore. We're going to go up to the api
    - Put your real api key into the apiKey variable
    - Start with the base url
    - Add the two query items to the url:
         - `let apiKeyItem = URLQueryItem(name: "apiKey", value: apiKey)`
         - `let searchItem = URLQueryItem(name: "s", value: searchTerm)`
    - Use `URLSession.shared.data(from: url)` to get the data at the url
    - At this point we have the data from the api. What do we do with it? Well we want to decode it into our `APIMovie`
    - Go ahead and try to decode the data using a JSONDecoder into `[APIMovie]`
    
- . . . And when that doesn't work:
- Take another close look at the response from postman. What is the top level object?
    ```
    {
    "Search": [
        {
            "Title": "Batman Begins",
            "Year": "2005",
    ```
    - So there is a top level object that has one property call `Search` which is an array of movies
    - So if we want Codable to work its magic for us we need to copy that format exactly
    - Add another struct above `APIMovie` called `SearchResponse`
        - Give it one property `let movies: [APIMovie]`
    - Then add this enum so the coding keys will match up with the api:
    ```
    enum CodingKeys: String, CodingKey {
        case movies = "Search"
    }
    ```
    - Update the decoding to decode `SearchResponse.self` instead of `[APIMovie].self`
    - `return searchResponse.movies`
### Now what?
- Build and Run
- Makesure your new movies show up properly from the app
- But the favorite button doesn't work! It just prints that dump phrase about liking a movie
- What do we WANT it to do?
    - When a user hits the heart, we are going to take the `APIMovie` and save an identical core data `Movie`
    - Then the search view will show api search results, and the favorites view will show Core Data favorites
    - Lets add that
 
#### Core Data Model
- So we have a`APIMovie` and we want to save it to Core Data. 
- First off, we don't even have a Core Data Entity in our Model. Let's do that first.
- Add an Entity called `Movie`
- Make it match the `APIMovie`
    - The only exception being `posterURLString` we will save this image url as a string. 
    - Go to `APIMovie.swift` and write an extension on `Movie` called `posterURL: URL?` that takes the string from core data and initializes a URL

### Saving APIMovies to Core Data
- Now we have a core data entity to use. Let's write a function to save an `APIMovie` to core data
- If you don't remember how, go take a look at the `ToDoist` app for a clue
- Go to the `MovieController` and write a new function that will take in an `APIMovie` and create a CD `Movie`:
    - `favoriteMovie(_ movie: APIMovie)`
- Then in the `MovieSearchViewController` go to the `toggleFavorite` function and call this new function to save the movie to core data
- Great, now we're saving APIMovies to Core Data when we hit the favorite button. . . at least, we think we are. How can we tell?
- This whole secret Core Data sql database thing probably still feels a little mysterious I'm guessing. 
- Let's take a little detour to show you something cool. Its a mac app called `CoreDataLab` made to help with exactly this kind of thing

## Core Data Lab (Detour) - OPTIONAL
- The app can be found [here](https://apps.apple.com/us/app/core-data-lab/id1460684638?mt=12)
- Download it and open it up
- Click on `Browse iOS simulators`
- Make sure `CoreDataFavoriteMovies` is running in one of your simulators
- Select the simulator your running and the `CoreDataFavoriteMovies` app and click `Select`
- You'll see a window that looks a little like xcode
- It shows the entity types on the left and all the instances of that type as rows in the main section
- if you click on a record, you'll see all the details on the right. 
- If you did it right, you'll see all your favorited movies here in core data lab without ever having to build the UI to show them!
- So what is this app doing?
    - Remember Core Data basically is just a framework to host a `.sqlite` file that stores a text representation of your data to that file
    - This app just finds that sqlite file in the simulator and reads the data inside it
- We won't go into it too much but this is a great reference for anyone that utilizes Core Data in their group or capstone project

## Favorites UI
- So now we are saving Favorites to Core Data, let's show them in the Favorites View Controller
- Add the diffable datasource just like the other view controller
    - This data source will be displaying the `MovieTableViewCell` the same, but will be based on core data `Movie` instead of `APIMovie`
    - Write another func called `applyNewSnapshot(from movies: [Movie])`
        - It will create a snapshot, append the new movies, and apply the snapshot`
        - It should also show and hide the tableview background view just like in the other view controller
- We need to make our `MovieTableViewCell` adapt to be able to show an `APIMovie` or a `Movie`
    - Write a new func just like `update(with: APIMovie)` but instead -> `update(with Movie)`
    - Now our data source can show cells based on either movie type
- Add the search controller with the delegate just like in the search view controller
- Add `func fetchFavorites` 
    - It will create a fetch request to fetch all the favorite movies
    - if the search controller's search text is not empty, it will also filter the results using an `NSPredicate`
        - If you don't remember how to do a fetch request check out [this article](https://www.advancedswift.com/fetch-requests-core-data-swift/)
        - If you don't remember hwo to do a predicate check out [this article](https://www.advancedswift.com/core-data-string-query-examples-in-swift/)
    - once you get the results of the fetch request, don't forget to call `applyNewSnapshot`
- What about if the user changes their mind about a favorite movie?
    - They will hit the heart button from the favorites view controller to unfavorite a movie
    - Write a function in the `MovieController` called `unfavoriteMovie(_ movie: Movie)` which deletes the movie from Core Data
    - Then write a function called `removeFavorite(_ movie: Movie)` in the favorites view controller that calls that function 👆
    - It should delete that movie from core data and apply a new snapshot deleting that item from the existing snapshot. 
    - It should look like this:
    ```
    func removeFavorite(_ movie: Movie) {
        MovieController.shared.unFavoriteMovie(movie)
        var snapshot = datasource.snapshot()
        snapshot.deleteItems([movie])
        datasource?.apply(snapshot, animatingDifferences: true)
    }

    ```
- Build and run!

## Search Favorites
- Go a head make sure you can:
    - Build and run, 
    - search and display movies from the api
    - Favorite a movie and have it show up in the favorites tab
    - Unfavorite a movie from the favorite tab and have it removed from core data
- What happens if you go back to the search view though? Does that movie still show up as a favorite?
- What about if you try and unfavorite a movie from the search view? 
- These are inconsistencies between these two views. Lets see if we can fix that. 
- First is updating unfavorites
    - This one is fairly easy. 
    - In the search view, in `viewWillAppear` just use this code to reload the snapshot for any stale data:
    ```
    var snapshot = datasource.snapshot()
    guard !snapshot.sectionIdentifiers.isEmpty else { return }
    snapshot.reloadSections([0])
    datasource?.apply(snapshot, animatingDifferences: true)

    ```
- How about unfavorite from the search view?
    - This one is a little tricker. Because the api doesn't know about what we have in core data
    - How can we tell if an `APIMovie` has a favorite counterpart in Core Data?
    - We need to do a fetch request for a specific movie to see if that APIMovie exists in Core Data as a `Movie` with the same `imdbID`
    - Add this function to the `MovieController`: 
        - `func favoriteMovie(from movie: APIMovie) -> Movie? {`
        - Its a normal Movie fetch request but there is a predicate for a specific `imdbID`
    - Then, check out `toggleFavorite` in the search view controller. What is it doing?
    - Its ALWAYS favoriting a movie. But if its already a favorite we want to UNFAVORITE
    - So use that new function to do an `if else`
        - If the movie has a favorite, call `MovieController.unfavoriteMovie()` if not, call `MovieController.favoriteMovie()`
        - Then call the `reload(movie: APIMovie)` func to update the heart on the search cell
    - Last thing, making sure the cells stay up to date
        - Go inside the `MovieTableViewCell.update(with: APIMovie)` function
        - We need to know if the movie we're showing is already favorited or not
        - At the bottom of the function add this: 
        ```
        if MovieController.shared.favoriteMovie(from: movie) != nil {
            setFavorite()
        } else {
            setUnFavorite()
        }

        ```
### That's it!

## Black Diamond
- Add a movie detail view
- Use the other parameter from the api to fetch a specific movie. api docs [here](http://www.omdbapi.com)
- When you tap on a movie, use the `imdbID` of the movie to fetch that specific movie. It returns a lot more data. 
- This is a sample of some of the data from the other api:
```
 "Title": "Batman v Superman: Dawn of Justice",
    "Year": "2016",
    "Rated": "PG-13",
    "Released": "25 Mar 2016",
    "Runtime": "152 min",
    "Genre": "Action, Adventure, Sci-Fi",
    "Director": "Zack Snyder",
    "Writer": "Chris Terrio, David S. Goyer, Bob Kane",
    "Actors": "Ben Affleck, Henry Cavill, Amy Adams",
    "Plot": "Fearing that the actions of Superman are left unchecked, Batman takes on the Man of Steel, while the world wrestles with what kind of a hero it really needs.",
    etc.
```
- Then you could show additional data on the detail view. 
- Update the `APIMovie` and `Movie` models. Add the fields you think are interesting or would want to display in the detail view
- When a user taps the favorite button, you could fetch the full movie from the api and save all the additional data to core data. 
- Make sure there is a heart button in the detail that can also add and remove the movie from favorites
