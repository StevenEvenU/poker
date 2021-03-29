open Deck
open Table

(* Types of user action *)
type action =
  | Check
  | Call
  | Raise
  | Fold

(* Checks whether another player has raised *)
let is_raised state = failwith "Not implemented yet"

(* Get the user's next action based on the current state *)
let rec get_action state =
  if is_raised state then (
    print_string "Do you wish to Call, Raise, or Fold?";
    match read_line () with
    | "Call" -> Call
    | "Raise" -> Raise
    | "Fold" -> Fold
    | _ ->
        print_string "Not Valid. Try again";
        get_action state)
  else (
    print_string "Do you wish to Check, Raise, or Fold?";
    match read_line () with
    | "Check" -> Check
    | "Raise" -> Raise
    | "Fold" -> Fold
    | _ ->
        print_string "Not Valid. Try again";
        get_action state)

let string_of_suit suit =
  match suit with
  | Spades -> "♠"
  | Hearts -> "♥"
  | Diamonds -> "♦"
  | Clubs -> "♣"

let string_of_value value =
  match value with
  | Two -> "2"
  | Three -> "3"
  | Four -> "4"
  | Five -> "5"
  | Six -> "6"
  | Seven -> "7"
  | Eight -> "8"
  | Nine -> "9"
  | Ten -> "10"
  | Jack -> "J"
  | Queen -> "Q"
  | King -> "K"
  | Ace -> "A"

let string_of_card card = 
  (string_of_value (card.value)) ^ string_of_suit card.suit

let rec string_of_cards_rec str cards =
  match cards with 
  | [] -> str 
  | h::[] -> str ^" "^ string_of_card h 
  | h::t -> let s = str ^" "^ string_of_card h in (string_of_cards_rec s t)

let string_of_cards cards = 
  string_of_cards_rec "" cards

let print_hand (state : Table.state) = 
  let hand = state.users_hand in
  if hand <> []
    then let s = string_of_cards hand in print_string ("Your hand is: \n " ^ s ^"\n")
    else print_string ("Your hand is empty. \n")

let print_table (state : Table.state) = 
  let table_cards = state.cards_on_table in 
  if table_cards <> [] 
    then print_string ("The current cards on the table are: \n" ^ (string_of_cards table_cards) ^ "\n") 
    else print_string "Table is empty. \n"

let main =
  (* Get Number of players *)
  print_string
    "Welcome to Poker! How many people do you want to play against?\n";
  let num_players = read_int () in
  print_int num_players;
  print_string "\n";

  let state = active_state in
  delegate state;
  print_hand state;
  deal state;
  print_table state;