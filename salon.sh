#!/bin/bash

PSQL="psql -X -A --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_MENU() {
  while true; do
    echo "Welcome to My Salon, how can I help you?"

    # Fetch and display services
    SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services")
    echo "Available services:"
    echo "$SERVICES_AVAILABLE" | while IFS="|" read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    # Ask for user's choice of service
    echo -e "\nPlease choose a service by entering the number:"
    read SERVICE_ID_SELECTED

    # Check if choice exists in the services
    if echo "$SERVICES_AVAILABLE" | grep -q "^$SERVICE_ID_SELECTED|"; then
      echo "You have selected a valid service."
      break
    else
      echo -e "\nInvalid selection. Please try again.\n"
    fi
  done

  # Prompt for customer's phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if the phone number exists in the database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]; then
    # Phone number doesn't exist, prompt for name and insert into database
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Insert new customer into the database
    INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id")
    CUSTOMER_ID=$(echo "$INSERT_RESULT" | head -n 1)
    echo "Customer added successfully."
  else
    echo "Welcome back, customer!"
  fi

  # Prompt for service time
  echo -e "\nPlease enter your preferred time for the service:"
  read SERVICE_TIME

  # Insert new appointment into the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  # Fetch the service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

  echo -e "\nYou've entered:\nService ID: $SERVICE_ID_SELECTED\nPhone: $CUSTOMER_PHONE\nName: $CUSTOMER_NAME\nTime: $SERVICE_TIME"
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

# Call the function
SERVICE_MENU