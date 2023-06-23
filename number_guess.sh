#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUM=$(($RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_ROW=$($PSQL "SELECT * FROM guesses WHERE username='$USERNAME'")

if [[ -z $USER_ROW ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO guesses(username) VALUES ('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM guesses WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM guesses WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
guess_count=0
until [[ $GUESS == $RANDOM_NUM ]]
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUM ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $RANDOM_NUM ]]
  then
    echo "It's higher than that, guess again:"
  fi
  ((guess_count++))
done

echo "You guessed it in $guess_count tries. The secret number was $RANDOM_NUM. Nice job!"

GAMES_PLAYED=$($PSQL "SELECT games_played FROM guesses WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM guesses WHERE username='$USERNAME'")

if [[ -z $GAMES_PLAYED ]]
then
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE guesses SET games_played=1 WHERE username='$USERNAME'")
  UPDATE_BEST_GAME=$($PSQL "UPDATE guesses SET best_game=$guess_count WHERE username='$USERNAME'")
else
  ((GAMES_PLAYED++))
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE guesses SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  if [[ $BEST_GAME -gt $guess_count ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE guesses SET best_game=$guess_count WHERE username='$USERNAME'")
  fi
fi
