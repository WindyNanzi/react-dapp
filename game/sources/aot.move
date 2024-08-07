module game::aot {
  use std::ascii::{String, string};
  use sui::balance::Balance;
  use sui::coin::{ Self, balance };
  use sui::object;
  use sui::transfer;
  use sui::url;

  /// 初始纪元
  const EAlreadyMinted: u64 = 0;
  /// Sender is not @0x0 the system address.
  // const ENotSystemAddress: u64 = 1;

  // const TOTAL_SUPPLY_AOT: u64 = 1_000_000;
  // 1 million
  const TOTAL_SUPPLY_MIST: u64 = 1_000_000_000_000; // 1 million * 10^9

  const IMG_URL:vector<u8> = b"https://i0.hdslb.com/bfs/article/b6d4f19f9fbcdc3845fafb1471eaba02208952558.png";

  public struct Aot_Data has key,store {
    id: UID,
    balance: Balance<AOT>,
    house: address,
  }

  public struct AOT has drop {}
  fun init(otw: AOT, ctx: &mut TxContext) {

    let (mut treasury, metadata) = coin::create_currency(
      otw,
      6,
      b"AOT",
      b"AOT",
      b"WindyNanzi Coin",
      option::some(url::new_unsafe(string(IMG_URL))),
      ctx
    );

    transfer::public_freeze_object(metadata);
    let coin = coin::mint(&mut treasury, TOTAL_SUPPLY_MIST, ctx);
    let total_aot = coin::into_balance(coin);


    transfer::public_transfer(treasury, ctx.sender());
    let house_data = Aot_Data {
      id: object::new(ctx),
      balance: total_aot,
      house: ctx.sender()
    };
    transfer::share_object(house_data);
  }


  public(package) fun house(aot_data: &mut Aot_Data):address {
    aot_data.house
  }

  public(package) fun get_balance_val(aot_data: &mut Aot_Data):u64 {
    aot_data.balance.value()
  }

  public(package) fun take_balance(aot_data: &mut Aot_Data):Balance<AOT> {
    let free_coins:u64 = 1_000_000_000; // 1000 AOT
    let balance = aot_data.balance.split(free_coins);
    balance
  }

}
