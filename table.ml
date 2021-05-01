open Deck
open State
open Compare

let table_deck = create

let start_income = 1000

let init_state (num : int) =
  {
    users_hand = [];
    cpu_hands = Array.make num [];
    cards_on_table = [];
    deck_rem = table_deck;
    turn = Player;
    user_money = start_income;
    cpu_moneys = Array.make num start_income;
    dealer = Player;
    current_bet = 0;
  }

let active_state (num : int) = init_state num

let delegate state =
  Random.self_init ();
  state.deck_rem <- shuffle state.deck_rem (Random.int 100000);
  for j = 0 to Array.length state.cpu_hands - 1 do
    for i = 0 to 1 do
      state.cpu_hands.(j) <-
        (match top_card state.deck_rem with
        | Some card -> card :: state.cpu_hands.(j)
        | none -> state.cpu_hands.(j));
      state.deck_rem <- remove_top state.deck_rem
    done
  done;
  for i = 0 to 1 do
    state.users_hand <-
      (match top_card state.deck_rem with
      | Some card -> card :: state.users_hand
      | none -> state.users_hand);
    state.deck_rem <- remove_top state.deck_rem
  done

let deal state =
  for i = 0 to 2 do
    state.cards_on_table <-
      (match top_card state.deck_rem with
      | Some card -> card :: state.cards_on_table
      | none -> state.cards_on_table);
    state.deck_rem <- remove_top state.deck_rem
  done

let flop state =
  state.cards_on_table <-
    (match top_card state.deck_rem with
    | Some card -> card :: state.cards_on_table
    | none -> state.cards_on_table);
  state.deck_rem <- remove_top state.deck_rem

let bet players amt state =
  match players with
  | Computer x ->
      let idx = x - 1 in
      let max = state.cpu_moneys.(idx) - state.current_bet in
      let bet_amt = state.current_bet + Random.int (max + 1) in
      Pot.add bet_amt (Computer idx);
      bet_amt
  | Player ->
      Pot.add amt Player;
      amt

let rec distr int_arr state player_count =
  if player_count = 0 then state.user_money <- int_arr.(player_count) else
  state.cpu_moneys.(player_count) <- int_arr.(player_count);
  match player_count with 0 ->  () | _ -> distr int_arr state (player_count - 1)

let winner (state : state) : win_record =
  let best_player = find_best_hand state Player in
  let best_computers = find_best_hand state (Computer 1) in
  let hands = List.append best_player best_computers in
  let sf x y =
    if x.rank > y.rank then -1
    else if x.rank = y.rank then
      if x.value > y.value then -1
      else if x.value = y.value then 0
      else 1
    else 1
  in
  let sorted = List.sort sf hands in
  (* List.sort (fun x y -> if x.value > y.value then 1 else -1) *)
  List.hd sorted

(* let round_check state = if List.length state.cards_on_table = 5 then
   winner state else flop state *)
