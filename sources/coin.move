module coin::my_coin;

use sui::coin;

public struct MY_COIN has drop {}

#[error]
const INSUFFICIENT_BALANCE: vector<u8> = b"Insuffiencent balance in your account to transfer";

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
