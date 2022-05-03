#!/bin/bash
clear
rm delegators.log 2>/dev/null
rm votes.log 2>/dev/null

yes="0"
no="0"
abstain="0"
node="https://osmosis.validator.network:443"

printf "\n\n"
read -p "Enter the active prop # to query (must be an active prop):  " prop
read -p "Enter the validator address (osmovaloper1vmkt...)  : " valAddress
valAddress=${valAddress:-osmovaloper1vmkt6ysppk8m4rhlq78tpqyh429lhlsah4mn3y}

printf "\n\nLooking for delegators..."
osmosisd query staking delegations-to $valAddress --node $node | grep delegator_address | awk '{print $2}' > delegators.log

num="$(wc -l < delegators.log)"
printf "\n\nGetting votes from $num delegators...\n\n"

while read p; do
  printf "\nCheck delegator $p..."
  osmosisd query gov vote $prop $p --node $node | grep option | head -1 >> votes.log
done <delegators.log

yes="$(grep -o -i YES votes.log | wc -l)"
printf $yes > /dev/null

no="$(grep -o -i NO votes.log | wc -l)"
printf $no > /dev/null

ABSTAIN="$(grep -o -i ABSTAIN votes.log | wc -l)"
printf $abstain > /dev/null

printf "\n\n...$yes delegators voted YES"

printf "\n...$no delegators voted NO"

printf "\n...$abstain delegators voted ABSTAIN\n\n"

rm delegators.log 2>/dev/null
rm votes.log 2>/dev/null
