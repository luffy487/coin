module coin::my_coin;

use sui::coin::{Self, TreasuryCap};
use sui::test_scenario::{Self, next_tx, ctx};

public struct MY_COIN has drop {}

#[error]
const INSUFFICIENT_BALANCE: vector<u8> = b"Insuffiencent balance in your account to transfer";

#[error]
const MINT_AND_TRANSFER_FAILED: vector<u8> = b"Mint and transfer of My Coin is failed";

#[error]
const TRANSFER_FAILED: vector<u8> = b"My Coin transfer failed";

fun init(witness: MY_COIN, ctx: &mut TxContext) {
    let (treasury, metadata) = coin::create_currency(
        witness,
        6,
        b"STRAW_HATS",
        b"Straw Hats",
        b"This coin is related to the Straw hat pirates of the One Piece",
        option::none(),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury, ctx.sender());
}

public fun transfer(
    transfer_coin: &mut coin::Coin<MY_COIN>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    assert!(coin::value(transfer_coin) >= amount, INSUFFICIENT_BALANCE);
    let transfer_portion = coin::split(transfer_coin, amount, ctx);
    transfer::public_transfer(transfer_portion, recipient);
}

#[test]
public fun test_coin_create_and_transfer() {
    let owner = @0x0010;
    let user = @0x0020;
    let user2 = @0x0030;

    let mut scenario = test_scenario::begin(owner);

    let witness = MY_COIN {};

    init(witness, ctx(&mut scenario));

    next_tx(&mut scenario, owner);
    {
        let mut cap = test_scenario::take_from_sender<TreasuryCap<MY_COIN>>(&scenario);
        sui::coin::mint_and_transfer(&mut cap, 10, user, ctx(&mut scenario));
        transfer::public_transfer(cap, owner);
    };

    next_tx(&mut scenario, user);
    {
        let mut user_cap = test_scenario::take_from_sender<coin::Coin<MY_COIN>>(&scenario);
        assert!(coin::value(&user_cap) == 10, MINT_AND_TRANSFER_FAILED);
        transfer(&mut user_cap, 5, user2, ctx(&mut scenario));
        assert!(coin::value(&user_cap) == 5, TRANSFER_FAILED);
        transfer::public_transfer(user_cap, user);
    };

    next_tx(&mut scenario, user2);
    {
        let user2_cap = test_scenario::take_from_sender<coin::Coin<MY_COIN>>(&scenario);
        assert!(coin::value(&user2_cap) == 5, TRANSFER_FAILED);
        transfer::public_transfer(user2_cap, user2);
    };
    test_scenario::end(scenario);
}
