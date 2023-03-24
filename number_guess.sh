#!/bin/bash

SECRET=$(($RANDOM % 1000 + 1))
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:";
read USERNAME

USER_INFO=$($PSQL "select user_id, name, game_counter, best_guess from users where name = '$USERNAME'")
USER_ID=$(echo $USER_INFO | cut -d '|' -f 1)
USER_NAME=$(echo $USER_INFO | cut -d '|' -f 2)
GAME_COUNTER=$(echo $USER_INFO | cut -d '|' -f 3)
BEST_GUESS=$(echo $USER_INFO | cut -d '|' -f 4)

if [[ -z $USER_ID ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here.";
else
    echo "Welcome back, $USER_NAME! You have played $GAME_COUNTER games, and your best game took $BEST_GUESS guesses.";
fi

echo "Guess the secret number between 1 and 1000:";
GUESSES=0
GUESS=-1
while [[ $GUESS -ne $SECRET ]]; do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:";
    elif [[ $GUESS -lt $SECRET ]]; then
        ((GUESSES++))
        echo "It's higher than that, guess again:";
    elif [[ $GUESS -gt $SECRET ]]; then
        ((GUESSES++))
        echo "It's lower than that, guess again:";
    elif [[ $GUESS -eq $SECRET ]]; then
        ((GUESSES++))
        echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!";
    fi
done

if [[ -z $USER_ID ]]; then
    USER_INSERT=$($PSQL "insert into users(name, game_counter, best_guess) values('$USERNAME', 1, $GUESSES)")
else
    if [[ $GUESSES -lt $BEST_GUESS ]]; then
        USER_UPDATE=$($PSQL "update users set game_counter = game_counter + 1, best_guess = $GUESSES where user_id = $USER_ID")
    else
        USER_UPDATE=$($PSQL "update users set game_counter = game_counter + 1 where user_id = $USER_ID")
    fi
fi
