import { describe, it, expect } from "vitest";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const wallet1 = accounts.get("wallet_1")!;
const wallet2 = accounts.get("wallet_2")!;

describe("Oluwa-Coin basics", () => {
  it("exposes metadata", () => {
    const { result: name } = simnet.callReadOnlyFn("oluwa-coin", "get-name", [], wallet1);
    expect(name).toBeOk();
    expect(name).toBeAscii("Oluwa-Coin");

    const { result: symbol } = simnet.callReadOnlyFn("oluwa-coin", "get-symbol", [], wallet1);
    expect(symbol).toBeOk();
    expect(symbol).toBeAscii("OLC");

    const { result: decimals } = simnet.callReadOnlyFn("oluwa-coin", "get-decimals", [], wallet1);
    expect(decimals).toBeOk();
    expect(decimals).toBeUint(8n);
  });

  it("initializes owner once and enforces minting rights", () => {
    // Before initialization, mint should fail
    let call = simnet.callPublicFn("oluwa-coin", "mint", [1000n, wallet1], wallet1);
    expect(call.result).toBeErr(100n);

    // Initialize owner as deployer
    const init = simnet.callPublicFn("oluwa-coin", "initialize-owner", [], deployer);
    expect(init.result).toBeOk(true);

    // Non-owner cannot mint
    call = simnet.callPublicFn("oluwa-coin", "mint", [500n, wallet1], wallet1);
    expect(call.result).toBeErr(101n);

    // Owner can mint within cap
    const mint = simnet.callPublicFn("oluwa-coin", "mint", [1000n, wallet1], deployer);
    expect(mint.result).toBeOk(true);

    const bal1 = simnet.callReadOnlyFn("oluwa-coin", "get-balance", [wallet1], wallet1);
    expect(bal1.result).toBeOk(1000n);
  });

  it("transfers between users", () => {
    // Precondition: ensure some balance exists (idempotent if already minted)
    const init = simnet.callPublicFn("oluwa-coin", "initialize-owner", [], deployer);
    // ignore if already initialized

    simnet.callPublicFn("oluwa-coin", "mint", [1000n, wallet1], deployer);

    const tx = simnet.callPublicFn("oluwa-coin", "transfer", [200n, wallet1, wallet2], wallet1);
    expect(tx.result).toBeOk(true);

    const b1 = simnet.callReadOnlyFn("oluwa-coin", "get-balance", [wallet1], wallet1);
    const b2 = simnet.callReadOnlyFn("oluwa-coin", "get-balance", [wallet2], wallet2);
    expect(b1.result).toBeOk(800n);
    expect(b2.result).toBeOk(200n);
  });
});