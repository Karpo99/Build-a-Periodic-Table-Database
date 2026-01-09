#!/bin/bash

PSQL="sudo -u postgres psql -d periodic_table -t --no-align -c"
INPUT=$1

if [[ -z $INPUT ]]; then
  echo "Please provide an element as an argument."
  exit
fi

call_db() {
  IFS="|" read -r atomic_number name symbol atomic_mass melting_point_celsius boiling_point_celsius type <<<"$(
    $PSQL "SELECT e.atomic_number,
                  e.name,
                  e.symbol,
                  p.atomic_mass,
                  p.melting_point_celsius,
                  p.boiling_point_celsius,
                  t.type
           FROM elements e
           JOIN properties p USING(atomic_number)
           JOIN types t USING(type_id)
           WHERE $1 = $2;"
  )"

  if [[ -z $atomic_number ]]; then
    echo "I could not find that element in the database."
    exit
  fi

  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
}

if [[ $INPUT =~ ^[0-9]+$ ]]; then
  call_db "e.atomic_number" "$INPUT"
elif [[ $INPUT =~ ^[A-Za-z]{1,2}$ ]]; then
  call_db "e.symbol" "'$INPUT'"
else
  call_db "e.name" "'$INPUT'"
fi
