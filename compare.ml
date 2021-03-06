open Deck
open State

let royal_rank = 10

let straight_flush_rank = 9

let four_kind_rank = 8

let full_house_rank = 7

let flush_rank = 6

let straight_rank = 5

let three_kind_rank = 4

let two_pair_rank = 3

let pair_rank = 2

let high_card_rank = 1

let no_card_rank = 0

type win_record = {
  player : players;
  rank : int;
  value : int;
}

let hand_of_rank = function
  | 1 -> "High Card"
  | 2 -> "Pair"
  | 3 -> "Two Pairs"
  | 4 -> "Three of a kind"
  | 5 -> "Straight"
  | 6 -> "Flush"
  | 7 -> "Full House"
  | 8 -> "Four of a kind"
  | 9 -> "Straight Flush"
  | 10 -> "Royal Flush"
  | _ -> "Error. Unknown hand!"

let int_of_val = function
  | Two -> 2
  | Three -> 3
  | Four -> 4
  | Five -> 5
  | Six -> 6
  | Seven -> 7
  | Eight -> 8
  | Nine -> 9
  | Ten -> 10
  | Jack -> 11
  | Queen -> 12
  | King -> 13
  | Ace -> 14

let str_of_suit suit =
  match suit with
  | Spades -> "♠"
  | Hearts -> "♥"
  | Diamonds -> "♦"
  | Clubs -> "♣"

let total_hand (pers_hand : Deck.card list) (table : Deck.card list) =
  pers_hand @ table

type card_check = {
  string_suit : string;
  int_value : int;
}

let rec hand_converter acc (cards : Deck.card list) : card_check list =
  match cards with
  | [] -> acc
  | h :: t ->
      hand_converter
        ({
           string_suit = str_of_suit h.suit;
           int_value = int_of_val h.value;
         }
         :: acc)
        t

let card_cmp_int fst_card snd_card =
  compare fst_card.int_value snd_card.int_value

let hand_sort_int (cards : card_check list) =
  List.rev (List.sort card_cmp_int cards)

exception GameNotOver

let high_card (cards : card_check list) (user : players) : win_record =
  match hand_sort_int cards with
  | [] -> raise GameNotOver
  | h :: t ->
      { player = user; rank = high_card_rank; value = h.int_value }

let rec one_pair_helper
    (cards : card_check list)
    (user : players)
    (hand_rank : int) : win_record =
  match hand_sort_int cards with
  | h1 :: h2 :: t ->
      if h1.int_value = h2.int_value then
        { player = user; rank = hand_rank; value = h1.int_value }
      else one_pair_helper (h2 :: t) user hand_rank
  | _ -> { player = user; rank = no_card_rank; value = 0 }

let one_pair (cards : card_check list) (user : players) =
  one_pair_helper cards user pair_rank

let rec snd_pair_check pair cards user =
  match hand_sort_int cards with
  | h1 :: h2 :: t ->
      if h1.int_value = h2.int_value && pair.value != h1.int_value then
        { player = user; rank = two_pair_rank; value = h1.int_value }
      else snd_pair_check pair (h2 :: t) user
  | _ -> pair

let two_pair (cards : card_check list) (user : players) : win_record =
  let fst_pair = one_pair cards user in
  snd_pair_check fst_pair cards user

let rec three_kind_helper
    (cards : card_check list)
    (user : players)
    (hand_rank : int) : win_record =
  match hand_sort_int cards with
  | h1 :: h2 :: h3 :: t ->
      if h1.int_value = h2.int_value && h2.int_value = h3.int_value then
        { player = user; rank = hand_rank; value = h1.int_value }
      else three_kind_helper (h2 :: h3 :: t) user hand_rank
  | _ -> { player = user; rank = no_card_rank; value = 0 }

let three_kind (cards : card_check list) (user : players) : win_record =
  three_kind_helper cards user three_kind_rank

let strt_hand_sort (cards : card_check list) =
  List.rev (List.sort_uniq card_cmp_int cards)

let rec straight (cards : card_check list) (user : players) : win_record
    =
  match strt_hand_sort cards with
  | h1 :: h2 :: h3 :: h4 :: h5 :: t ->
      if
        h1.int_value - 1 = h2.int_value
        && h2.int_value - 1 = h3.int_value
        && h3.int_value - 1 = h4.int_value
        && h4.int_value - 1 = h5.int_value
      then { player = user; rank = straight_rank; value = h1.int_value }
      else straight (h2 :: h3 :: h4 :: h5 :: t) user
  | _ -> { player = user; rank = no_card_rank; value = 0 }

let rec flush_helper
    (cards : card_check list)
    (user : players)
    (spades : int)
    (hearts : int)
    (diamonds : int)
    (clubs : int) : win_record =
  match hand_sort_int cards with
  (* FIND THE HIGHEST VALUE IN THE FLUSH *)
  | h :: t ->
      if h.string_suit = "♠" then
        flush_helper t user (spades + 1) hearts diamonds clubs
      else if h.string_suit = "♥" then
        flush_helper t user spades (hearts + 1) diamonds clubs
      else if h.string_suit = "♦" then
        flush_helper t user spades hearts (diamonds + 1) clubs
      else flush_helper t user spades hearts diamonds (clubs + 1)
  | [] ->
      if spades >= 5 || hearts >= 5 || diamonds >= 5 || clubs >= 5 then
        { player = user; rank = flush_rank; value = 0 }
      else { player = user; rank = high_card_rank; value = 0 }

let flush (cards : card_check list) (user : players) : win_record =
  flush_helper cards user 0 0 0 0

let rec full_house (cards : card_check list) (user : players) :
    win_record =
  match hand_sort_int cards with
  | h1 :: h2 :: h3 :: t
    when h1.int_value = h2.int_value && h2.int_value = h3.int_value ->
      one_pair_helper t user full_house_rank
  | h1 :: h2 :: t when h1.int_value = h2.int_value ->
      three_kind_helper t user full_house_rank
  | h :: t -> full_house t user
  | _ -> { player = user; rank = high_card_rank; value = 0 }

let rec four_kind (cards : card_check list) (user : players) :
    win_record =
  match hand_sort_int cards with
  | h1 :: h2 :: h3 :: h4 :: t ->
      if
        h1.int_value = h2.int_value
        && h2.int_value = h3.int_value
        && h3.int_value = h4.int_value
      then
        { player = user; rank = four_kind_rank; value = h1.int_value }
      else four_kind (h2 :: h3 :: h4 :: t) user
  | _ -> { player = user; rank = no_card_rank; value = 0 }

let rec straight_flush (cards : card_check list) (user : players) :
    win_record =
  match strt_hand_sort cards with
  | h1 :: h2 :: h3 :: h4 :: h5 :: t ->
      if
        h1.int_value - 1 = h2.int_value
        && h2.int_value - 1 = h3.int_value
        && h3.int_value - 1 = h4.int_value
        && h4.int_value - 1 = h5.int_value
        && h1.string_suit = h2.string_suit
        && h2.string_suit = h3.string_suit
        && h3.string_suit = h4.string_suit
        && h4.string_suit = h5.string_suit
      then
        {
          player = user;
          rank = straight_flush_rank;
          value = h1.int_value;
        }
      else straight_flush (h2 :: h3 :: h4 :: h5 :: t) user
  | _ -> { player = user; rank = no_card_rank; value = 0 }

let royal_flush (cards : card_check list) (user : players) : win_record
    =
  match strt_hand_sort cards with
  | h1 :: h2 :: h3 :: h4 :: h5 :: t ->
      if
        h1.int_value = 14 && h2.int_value = 13 && h3.int_value = 12
        && h4.int_value = 11 && h5.int_value = 10
        && h1.string_suit = "♠" && h2.string_suit = "♠"
        && h3.string_suit = "♠" && h4.string_suit = "♠"
        && h5.string_suit = "♠"
      then { player = user; rank = royal_rank; value = 14 }
      else { player = user; rank = no_card_rank; value = 0 }
  | _ -> { player = user; rank = no_card_rank; value = 0 }

let hand_fun_list (cards : card_check list) (user : players) =
  [
    royal_flush cards user;
    straight_flush cards user;
    four_kind cards user;
    full_house cards user;
    flush cards user;
    straight cards user;
    three_kind cards user;
    two_pair cards user;
    one_pair cards user;
  ]

let rank_list =
  [
    royal_rank;
    straight_flush_rank;
    four_kind_rank;
    full_house_rank;
    flush_rank;
    straight_rank;
    three_kind_rank;
    two_pair_rank;
    pair_rank;
  ]

let rec result
    (hand_funcs : win_record list)
    (rank_list : int list)
    (cards : card_check list)
    (user : players) : win_record =
  match (hand_funcs, rank_list) with
  | [], [] -> high_card cards user
  | h_func :: t_func, h_rank :: t_rank ->
      if h_func.rank = h_rank then h_func
      else result t_func t_rank cards user
  | _ -> failwith "Error: List should be equal size"

let best_hand (cards : card_check list) (user : players) : win_record =
  let hand_check = hand_fun_list cards user in
  result hand_check rank_list cards user

let find_best_hand (state : state) (player : players) : win_record list
    =
  let f hand person =
    best_hand
      (hand_converter [] (total_hand hand state.cards_on_table))
      person
  in
  if player = Player then [ f state.users_hand player ]
  else
    let ( -- ) i j =
      let rec aux n acc =
        if n < i then acc else aux (n - 1) (n :: acc)
      in
      aux j []
    in
    let hands = 0 -- (Array.length state.cpu_hands - 1) in
    List.map
      (fun x -> f (Array.get state.cpu_hands x) (Computer 1))
      hands
