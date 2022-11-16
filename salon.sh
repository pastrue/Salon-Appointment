#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Welcome to the Salon! ~~~~~\n"

SALON_MENU(){
if [[ $1 ]]
then
  echo -e "\n$1"
fi
echo -e "\nWhat service would you like?"
SALON_SERVICES=$($PSQL "Select service_id, name from services order by service_id")
MAX_SID=$($PSQL "Select max(service_id) from services")
if [[ -z $SALON_SERVICES ]]
then
  echo -e "Sorry, we are fully booked"
else
  echo "$SALON_SERVICES" | while read SERVICE_ID BAR NAME #sed 's/^[ \t]*\(.*$\)/\1/' | sed 's/ *|/)/g'
    do
      echo "$SERVICE_ID) $NAME"
    done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SALON_MENU "Please select a valid service"
  else
    SS=$($PSQL "Select service_id from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SS ]]
    then
      SALON_MENU "Please select a valid service"
    else
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "Select name from customers where phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        INSERT_NEW_CUSTOMER=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      CID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
      SN=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED'")
      echo -e "\nWhat time would you like your service?"
      read SERVICE_TIME
      INSERT_NEW_APPOINTMENT=$($PSQL "insert into appointments(time, customer_id, service_id) values('$SERVICE_TIME', '$CID', '$SERVICE_ID_SELECTED')")
      echo -e "\nI have put you down for a $SN at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
fi 

}

SALON_MENU