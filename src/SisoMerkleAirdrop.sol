// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    IERC20,
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {
    MerkleProof
} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract SisoMerkleAirdrop is EIP712, Ownable {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error InvalidMerkleProof();
    error InvalidSignature();
    error NothingToClaim();
    error ClaimWindowClosed();

    /*//////////////////////////////////////////////////////////////
                              CONSTANTS
    //////////////////////////////////////////////////////////////*/
    uint256 public constant BPS = 10_000;
    uint256 public constant PHASE1_BPS = 5_000; // 50% unlock

    bytes32 private constant CLAIM_TYPEHASH =
        keccak256("Claim(address account,uint256 totalAllocation)");

    /*//////////////////////////////////////////////////////////////
                             IMMUTABLES
    //////////////////////////////////////////////////////////////*/
    IERC20 public immutable token;
    bytes32 public immutable merkleRoot;

    uint256 public immutable deployTime;
    uint256 public immutable phase1End;    // deploy + 30 days
    uint256 public immutable phase2Start;  // deploy + 90 days
    uint256 public immutable phase2End;    // phase2Start + 7 days

    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/
    mapping(address => uint256) public claimedAmount;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claimed(address indexed user, uint256 amount);
    event UnclaimedWithdrawn(uint256 amount);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        address _token,
        bytes32 _merkleRoot
    ) EIP712("SisoMerkleAirdrop", "1") Ownable(msg.sender) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;

        deployTime = block.timestamp;
        phase1End = deployTime + 30 days;
        phase2Start = deployTime + 90 days;
        phase2End = phase2Start + 7 days;
    }

    /*//////////////////////////////////////////////////////////////
                             CLAIM FUNCTION
    //////////////////////////////////////////////////////////////*/
    function claim(
        uint256 totalAllocation,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // ---- Signature verification (EIP-712) ----
        bytes32 digest = _hashClaim(msg.sender, totalAllocation);
        address signer = ECDSA.recover(digest, v, r, s);
        if (signer != msg.sender) revert InvalidSignature();

        // ---- Merkle proof verification ----
        bytes32 leaf = keccak256(
            abi.encodePacked(msg.sender, totalAllocation)
        );
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert InvalidMerkleProof();
        }

        // ---- Vesting calculation ----
        uint256 maxClaimable = _maxClaimableNow(totalAllocation);
        uint256 alreadyClaimed = claimedAmount[msg.sender];
        if (maxClaimable <= alreadyClaimed) revert NothingToClaim();

        uint256 amountToSend = maxClaimable - alreadyClaimed;

        claimedAmount[msg.sender] += amountToSend;
        token.safeTransfer(msg.sender, amountToSend);

        emit Claimed(msg.sender, amountToSend);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL VIEW HELPERS
    //////////////////////////////////////////////////////////////*/
    function _maxClaimableNow(
        uint256 totalAllocation
    ) internal view returns (uint256) {
        if (block.timestamp <= phase1End) {
            return (totalAllocation * PHASE1_BPS) / BPS;
        }

        if (
            block.timestamp >= phase2Start &&
            block.timestamp <= phase2End
        ) {
            return totalAllocation;
        }

        revert ClaimWindowClosed();
    }

    function _hashClaim(
        address account,
        uint256 totalAllocation
    ) internal view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    CLAIM_TYPEHASH,
                    account,
                    totalAllocation
                )
            )
        );
    }

    /*//////////////////////////////////////////////////////////////
                        PUBLIC VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns current claim phase
    /// 0 = closed, 1 = phase1 (50%), 2 = phase2 (100%)
    function currentPhase() external view returns (uint8) {
        if (block.timestamp <= phase1End) return 1;
        if (
            block.timestamp >= phase2Start &&
            block.timestamp <= phase2End
        ) return 2;
        return 0;
    }

    /// @notice Whether claim is currently open
    function isClaimOpen() external view returns (bool) {
        return
            block.timestamp <= phase1End ||
            (block.timestamp >= phase2Start &&
                block.timestamp <= phase2End);
    }

    /// @notice Max claimable amount at current time
    function maxClaimableNow(
        uint256 totalAllocation
    ) external view returns (uint256) {
        return _maxClaimableNow(totalAllocation);
    }

    /// @notice Remaining amount user can claim right now
    function pendingClaim(
        address user,
        uint256 totalAllocation
    ) external view returns (uint256) {
        uint256 maxClaimable = _maxClaimableNow(totalAllocation);
        uint256 claimed = claimedAmount[user];

        if (maxClaimable <= claimed) return 0;
        return maxClaimable - claimed;
    }

    /// @notice Whether user has fully claimed allocation
    function hasFullyClaimed(
        address user,
        uint256 totalAllocation
    ) external view returns (bool) {
        return claimedAmount[user] >= totalAllocation;
    }

    /*//////////////////////////////////////////////////////////////
                          OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function withdrawUnclaimed(address to) external onlyOwner {
        uint256 bal = token.balanceOf(address(this));
        token.safeTransfer(to, bal);
        emit UnclaimedWithdrawn(bal);
    }
}
