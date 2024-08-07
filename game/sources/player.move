module game::player {
  use sui::balance;
  use sui::balance::Balance;
  use sui::coin;
  use sui::object;
  use game::aot::{AOT};

  public struct Player has key,store {
    id:UID,
    free_time: u64,
    balance: Balance<AOT>,
  }

  public(package) fun generate_player(
    ctx: &mut TxContext,
  ):Player {
    Player {
      id:object::new(ctx),
      free_time: 5,
      balance: balance::zero()
    }
  }


  public(package) fun get_free_time(player: &mut Player):u64 {
    player.free_time
  }

  public(package) fun get_balance_val(player: &mut Player): u64 {
    player.balance.value()
  }


  public(package) fun add_balance(balance: Balance<AOT>, player: &mut Player) {
    player.balance.join(balance);
    player.free_time - 1;
  }

  public(package) fun pay_for_balance(player: &mut Player, house: address, ctx: &mut TxContext) {
    let b = player.balance.split(100_000_000);
    let coin = coin::from_balance(b,ctx);
    transfer::public_transfer(coin, house);
  }
}