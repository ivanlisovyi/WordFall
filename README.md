# WordFall

## Requirements
- Swift 5.1
- iOS 13+

## Idea
Write a small game. The player will see a word in language „one“ on the screen. While this word is displayed, a word in language „two“ will fall down on the screen. The player will have to choose if the falling word is the correct translation or a wrong translation. The player needs to answer, before the word reaches the bottom of the screen. A counter that gives the player feedback should be included.

## Concept
- Game will choose `10` (by default) random words from a words souce
- Game will give user `2` (by default) chances (lifes) to make an error
- Every time user makes an error, user loses a life
- If user lost all lifes by missing translation, user lose
- User will confirm translation by tapping on a falling word
- User will see action/no actionfeedback when:
  - Taps on a `word` to confirm translation - `word` becomes **green**
  - Doesn't tap on a `word` and `word` reaches boundary - `word` becomes **red**
- User will see his/her score in the top left corner
- User will see his/her lifes count in the right corner

## Time Distribution
| Design/Concept | Model | Views | Game Mechanics |
| --- | --- | --- | --- |
| ~1.5h | ~1h | 1h | ~2h |

## Technical Desicions

### Architecture
`MVVM-C` has been choosen as an app architecture for an assignment. `MVVM-C` plays very nicely with the `Combine` framework and allows to have a clear separation between the `View` and `ViewModel`. Also, it shall pretty straightforward to refactor the UI layer to `SwiftUI` without changing the view models at all.

### Coordinators for routing
`Coordinator` pattern is being used because there was a plan to implement multiple screen (e.g. Settings Screen).

### Dependecy Injection
All the dependencies are injected using `constructor injection`. This makes it easier to replace concrete implementation with mocks for unit testing or have a different implementation of some functionality depending on the actual need. For example, we can have multiple implementation of the `WordsSource` protocol, one for loading the data from a local resource and another one for loading the data from a remote resource.

### Game Implementation
The following options were considered:
- `SpriteKit` - probably the most obvious choice for any 2D game if iOS platform is the only target. `SpriteKit` wasn't used cuz it feels a little bit too heavy for such a small game.
- `UIKit Dynamics` - very easy to use, provides all the game functionality out of the box, almost no setup required, easy to extend with a new functionality. Feels like a good compromise between `UIView Animation\CoreAnimation` and `SpriteKit`.
- `UIView Animations\CoreAnimation` - will require an additional setup in comparison to `UIKit Dynamics`, lots of code overhead, `CADisplayLink` requirement for a smooth animations, hard to extend with a new functionality.

### Decisions Made bacause of resticted time and Improvements
- There was an idea to implement an additional screen like settings that would allow to configure certain game parameters like `game speed`, `number of lifes per fame` and `number of words per game`.
- Dependency Injection is done in the Coordinator. I would prefer to have a separate depdency container. I also like the idea of utilizing the property wrappers which make the DI very straightforward. The proper container implementation either requires external dependencies and additional time.
- There was an idea to implement `RemoteWordsSource` and use `words.json` from the `Github` gist and use `LocalWordsSource` as a backup if there is no internet connection or any other error occured.
- I guess, game state management could be better. I really like the behind the [RxFeedback](https://github.com/NoTests/RxFeedback.swift) or [CombineFeedback](https://github.com/sergdort/CombineFeedback) and I think a similar approach could be used there to improve state management.
- `UITests` to make sure that everything works end to end.
