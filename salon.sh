#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only  -c"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  
  ##SERVICE_ID_MAX=$($PSQL "select max(service_id) from services")
  ##SERVICE_ID=$($PSQL "select service_id from services order by service_id limit 1")
  ##I=1
  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$SERVICES" | while IFS=" | " read SERVICE_ID SERVICE_NAME
  do
    echo -e "$SERVICE_ID) "$SERVICE_NAME""
  done


      #while [[ $SERVICE_ID -lt $SERVICE_ID_MAX ]]
      #do
      #SERVICE_ID=$($PSQL "select service_id from services where service_id=$I")
      #SERVICE_NAME=$($PSQL "select name from services where service_id=$I")
      #SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //')
      #echo -e $SERVICE_ID\) $SERVICE_NAME #_FORMATTED
      #I=$(($I+1))
      #done
      #echo "$I) Exit"
  read SERVICE_ID_SELECTED
  
  
  if [[ $SERVICE_ID_SELECTED = $I ]]
  then 
    EXIT
  elif [[ ! $SERVICE_ID_SELECTED =~ [0-9]+ ]]
  then  
    MAIN_MENU "Please insert a number next time."
  else
    SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      MAKE_APPOINTMENTS
    fi
  fi
}



MAKE_APPOINTMENTS() {
  CHOSEN_SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED") 
 
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # check if customer not already in database
  CUSTOMER_ID=$($PSQL "Select customer_id from customers where phone='$CUSTOMER_PHONE' ")
  # if customer not in database, ask all possible questions
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert in database
    INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")
    # if customer already in database 
  fi
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE' ")
  echo -e "\nWhat time would you like your$CHOSEN_SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "Insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME') ")
  echo -e "\nI have put you down for a$CHOSEN_SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
      
}

EXIT() {
  echo "Thanks for using our app!"
}
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU

