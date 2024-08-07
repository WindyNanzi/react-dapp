module game::game {

  use sui::object;
  use sui::random;
  use sui::random::{Random};
  use sui::table;
  use sui::table::Table;
  use game::aot;
  use game::player;
  use game::aot::Aot_Data;
  use game::player::Player;


  const ENotSystemAddress:u64 = 0;
  const ENoPoolBalance: u64 = 1;
  const ENoFreeTime: u64 = 2;
  const ENoUserBalance: u64 = 3;


  public struct Game_Info has key, store {
    id: UID,
    player: Player,
    count: u64, // 第几次游玩
    point: u64, // 当前点数
  }

  public struct Game_Record has key, store {
    id: UID,
    record: Table<address, Game_Info>,
  }

  public struct Game_Data has key {
    id: UID,
  }

  fun init (ctx: &mut TxContext) {
    let record = Game_Record {
      id: object::new(ctx),
      record: table::new<address, Game_Info>(ctx),
    };

    transfer::share_object(record);
  }

  // 注册用户
  public fun register(
    ctx: &mut TxContext,
    aot_data: &mut Aot_Data,
    r: &mut Game_Record,
  ):bool {
    let sender = ctx.sender();
    assert!(aot::house(aot_data) == sender, ENotSystemAddress);

    let state = if(!table::contains(&r.record, sender)) {
      let player = player::generate_player(ctx);
      let game_ifon = generate_game_info(ctx, player);
      table::add(&mut r.record, sender, game_ifon);
      false
    } else  {
      true
    };
    state
  }

  // 用户获得免费的代币
  public fun get_free_coins(
    ctx: &mut TxContext,
    aot_data: &mut Aot_Data,
    r: &mut Game_Record,
  ) {
    assert!(aot::get_balance_val(aot_data) <= 500_000_000, ENoPoolBalance);
    let game_info = table::borrow_mut(&mut r.record, ctx.sender());
    assert!(player::get_free_time(&mut game_info.player) <=0 , ENoFreeTime);

    let balance = aot::take_balance(aot_data);
    player::add_balance(balance, &mut game_info.player);
  }

  // 改变点数
  fun change_point(
    ctx: &mut TxContext,
    aot_data: &mut Aot_Data,
    r: &mut Game_Record,
    random: &Random,
    isUp: bool
  ) {
    let mut game_info = table::borrow_mut(&mut r.record, ctx.sender());
    assert!(player::get_balance_val(&mut game_info.player) <=0 , ENoPoolBalance);
    let roll = roll(random,  ctx);
    let point = (
      if(isUp) {
        game_info.point + roll
      } else {
        game_info.point - roll
      }
    );

    // 不知道是否会生效
    game_info.point = point;
    player::pay_for_balance(
      &mut game_info.player,
      aot::house(aot_data),
      ctx,
    );
  }

  // 生成游戏信息
  fun generate_game_info(
    ctx: &mut TxContext,
    player: Player,
  ):Game_Info {
    Game_Info {
      id:object::new(ctx),
      player,
      count: 0,
      point: 100, // 针对可能存在的负数做处理
    }
  }

  // 摇骰子
  fun roll(r: &Random, ctx: &mut TxContext):u64 {
    random::generate_u64_in_range(&mut random::new_generator(r, ctx), 1, 6)
  }
}
