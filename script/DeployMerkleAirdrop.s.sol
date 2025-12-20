// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {SisoMerkleAirdrop} from "../src/SisoMerkleAirdrop.sol";

contract DeployMerkleAirdrop is Script {
    function run() external returns (SisoMerkleAirdrop) {
        address TOKEN = 0xc8C711CDf3fD162b00F3447C6963C52aF3d44AAb;

        bytes32 MERKLE_ROOT = 0x021f2f9668207e33e7ff61f294868a1ca6a46039c68bd10a3814c8f851fd8fb7;

        vm.startBroadcast();

        SisoMerkleAirdrop airdrop = new SisoMerkleAirdrop(TOKEN, MERKLE_ROOT);

        vm.stopBroadcast();

        return airdrop;
    }
}
