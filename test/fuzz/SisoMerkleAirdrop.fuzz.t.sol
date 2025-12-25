// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/SisoMerkleAirdrop.sol";
import "../../src/SisoToken.sol";

contract SisoMerkleAirdropFuzzTest is Test {
    SisoMerkleAirdrop airdrop;
    SisoToken token;

    // empty proof (no allocation, no new)
    bytes32[] emptyProof;

    function setUp() public {
        token = new SisoToken(1_000_000 ether);



        airdrop = new SisoMerkleAirdrop(
            address(token),
            keccak256("dummy-root")
        );

        token.transfer(address(airdrop), 500_000 ether);

        // explicitly empty (safe)
        delete emptyProof;
    }
    
    /*//////////////////////////////////////////////////////////////
                          FUZZ TESTS
    //////////////////////////////////////////////////////////////*/

    /// @notice user can NEVER claim more than allocation
    function testFuzzCannotOverClaim(address user, uint256 allocation) public {
        allocation = bound(allocation, 1 ether, 100_000 ether);

        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(allocation, emptyProof, 0, bytes32(0), bytes32(0));
    }

    /// @notice claim outside any valid window always fails
    function testFuzzClaimOutsideWindow(
        address user,
        uint256 allocation,
        uint256 jump
    ) public {
        allocation = bound(allocation, 1 ether, 10_000 ether);
        jump = bound(jump, 120 days, 500 days);

        vm.warp(block.timestamp + jump);

        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(allocation, emptyProof, 0, bytes32(0), bytes32(0));
    }

    /// @notice invalid signature must always revert
    function testFuzzInvalidSignatureAlwaysFails(
        address user,
        uint256 allocation
    ) public {
        allocation = bound(allocation, 1 ether, 50_000 ether);

        vm.prank(user);
        vm.expectRevert();
        airdrop.claim(
            allocation,
            emptyProof,
            27, // fake v
            bytes32(0), // fake r
            bytes32(0) // fake s
        );
    }
}
