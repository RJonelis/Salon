#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My SALON ~~~~~\n"

SERVICES_MENU() {
    if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  #get servises
  SERVICES=$($PSQL "SELECT service_id, name  FROM services ORDER BY service_id")
  #if not services 
  if [[ -z $SERVICES ]]
  then
    echo -e "\nNo services"
  else
    #display services
    echo -e "\nWelcome to My Salon, how can I help you?"
    echo "$SERVICES" | while read ID BAR NAME
    do
      echo "$ID) $NAME"
    done

    # ask for book service
    echo -e "\nWhich  service would you like to book?"
    read SERVICE_ID_SELECTED

    #get booked service
    BOOKED_SERVICE=$($PSQL "SELECT service_id, name  FROM services WHERE service_id='$SERVICE_ID_SELECTED' ORDER BY service_id")
    #if not available service
    if [[ -z $BOOKED_SERVICE ]]
    then
      SERVICES_MENU "That is not a valid service number."
    else
      #Ask phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      #Check number
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        #Ask Customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        #CREATE CUSTOMER
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")
      fi
      NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #Ask time
      echo -e "\nWhat time would you like your cut,$CUSTOMER_NAME?"
      read SERVICE_TIME
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($NEW_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME' )")
      if [[ INSERT_APPOINTMENT_RESULT ]]
      then
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
}

SERVICES_MENU
