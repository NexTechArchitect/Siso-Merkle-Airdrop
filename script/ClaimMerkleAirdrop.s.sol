// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {SisoMerkleAirdrop} from "../src/SisoMerkleAirdrop.sol";

contract ClaimMerkleAirdrop is Script {
    /*//////////////////////////////////////////////////////////////
                            CONFIG
    //////////////////////////////////////////////////////////////*/

    address private constant AIRDROP =
        0x4587896472ff694C94296ADCE0cB809276284119;

    uint256 private constant TOTAL_ALLOCATION = 1000000000000000000000; // 1000 tokens (18 decimals)

    /*/////////////////////////////////////////////////////////////
                        MERKLE PROOF (STATIC) 
    /////////////////////////////////////////////////////////////*/

    bytes32 private constant P0 =
        0x0a3e6290c0d1fed672c4d57015477479cd408279ba082b78b5dcf39c73eb95fe;
    bytes32 private constant P1 =
        0x446e8ffafd35e60f4e5b04c778bdc7453487c4c2887a4c783b2d69a827be8a73;
    bytes32 private constant P2 =
        0xd6c8d8793ec7395b68473dd1c8da6805c3c75c7261876baaf0255882e9f9b4af;
    bytes32 private constant P3 =
        0x289263ed94225d37aea36f3d61c0f68b2efdd174ea562c97187ed168557846a1;
    bytes32 private constant P4 =
        0x4629625338dea09484f2dbfecc7cdaedd26abab7ef33c01cd0a5d4bf0c2d66a5;
    bytes32 private constant P5 =
        0x6691ed54e74fb640292f9ad6450853649ae17bae6552058e63f7098d250da920;
    bytes32 private constant P6 =
        0xf9a064a72a3c48fd68085f8318702cbc5ce7a3e534522876df367db93ae6c396;

    bytes32[] private proof = [P0, P1, P2, P3, P4, P5, P6];

    /*//////////////////////////////////////////////////////////////
                        SIGNATURE
    //////////////////////////////////////////////////////////////*/

    uint8 private constant V = 28;
    bytes32 private constant R =
        0xbcb309cb0de5cf3dc906270a0d9bf3a926bbf269ad06dd9b7da8dca5c4ad61e5;
    bytes32 private constant S =
        0x77f5ccc6f857d1b404b14bf3df5e5af97ca06d4a2272095c91b398bec5a949e7;

    /*/////////////////////////////////////////////////////////////
                            RUN
    /////////////////////////////////////////////////////////////*/

    function run() external {
        vm.startBroadcast();

        SisoMerkleAirdrop(AIRDROP).claim(TOTAL_ALLOCATION, proof, V, R, S);

        vm.stopBroadcast();

        console.log("Airdrop claimed successfully");
    }
}
