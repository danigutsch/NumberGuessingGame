#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

WELCOME_USER() {

  USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$1'")
  
  if [[ -z $USER_INFO ]]
  then

    echo "Welcome, $1! It looks like this is your first time here."
    INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$1')")

  else

    IFS='|' read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
    echo "Welcome back, $1! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  fi

}

PLAY_GAME() {

  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  GUESS=0
  NUMBER_OF_GUESSES=0

  echo "Guess the secret number between 1 and 1000:"

  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do

    read GUESS

    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then

      echo "That is not an integer, guess again:"
      continue

    fi

    ((NUMBER_OF_GUESSES++))

    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then

      echo "It's higher than that, guess again:"

    elif [[ $GUESS -gt $SECRET_NUMBER ]]; then

      echo "It's lower than that, guess again:"

    fi

  done

  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

  UPDATE_USER_DATA $1 $NUMBER_OF_GUESSES

}

UPDATE_USER_DATA() {

  A=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$1'")
  B=$($PSQL "UPDATE users SET best_game = LEAST(best_game, $2) WHERE username = '$1'")
  C=$($PSQL "UPDATE users SET best_game = $2 WHERE username = '$1'")

}

echo "Enter your username:"
read USERNAME

WELCOME_USER $USERNAME
PLAY_GAME $USERNAME
