// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/SisoMerkleAirdrop.sol";
import "../../src/SisoToken.sol";

contract SisoMerkleAirdropTest is Test {
    SisoMerkleAirdrop airdrop;
    SisoToken token;

    address user = address(0x123);
    uint256 TOTAL = 100 ether;

    uint8 v;
    bytes32 r;
    bytes32 s;

    // ✅ EMPTY MERKLE PROOF (DECLARED ONCE)
    bytes32[] emptyProof;

    function setUp() public {
        token = new SisoToken(1_000_000 ether);

        airdrop = new SisoMerkleAirdrop(
            address(token),
            keccak256("dummy-root")
        );

        token.transfer(address(airdrop), 1_000 ether);

        (v, r, s) = vm.sign(1, keccak256("dummy"));

        // ✅ explicitly clear proof (no allocation)
        delete emptyProof;
    }

    /*//////////////////////////////////////////////////////////////
                            UNIT TESTS
    //////////////////////////////////////////////////////////////*/

    function testInvalidMerkleProofReverts() public {
        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(TOTAL, emptyProof, v, r, s);
    }

    function testClaimBeforePhase2Reverts() public {
        vm.warp(block.timestamp + 10 days);

        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(TOTAL, emptyProof, v, r, s);
    }

    function testClaimAfterPhase2WindowReverts() public {
        vm.warp(block.timestamp + 120 days);

        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(TOTAL, emptyProof, v, r, s);
    }

    function testCannotOverClaim() public {
        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(1_000_000 ether, emptyProof, v, r, s);
    }
}
