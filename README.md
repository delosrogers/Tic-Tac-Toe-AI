A web based Tic-Tac-Toe game written in Elm.

In order to run the built version start a webserver on the root of the working tree for example with `Python -m http.server` and navigate to elm.html.

In order to develop you must install elm and you can build the code using `elm make src/Main.elm --output elm.js`

In order to switch from a 3 by 3 to a 4 by 4 board change the repeat in the `init` function in Main.elm to 15 so it makes a board with 16 spaces.
