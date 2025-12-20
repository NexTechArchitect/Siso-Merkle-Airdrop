-include .env

.PHONY: clean build test anvil deploy fund sign claim balance help

# --------------------------------------------------
# LOCAL (ANVIL DEFAULTS)
# --------------------------------------------------

ANVIL_RPC := http://localhost:8545
ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# --------------------------------------------------
# REQUIRED ENV (FAIL FAST)
# --------------------------------------------------

ifndef AIRDROP_ADDRESS
$(error AIRDROP_ADDRESS not set)
endif

ifndef TOKEN_ADDRESS
$(error TOKEN_ADDRESS not set)
endif

# claim-related (only needed for make claim)
ifndef TOTAL_ALLOCATION
$(warning TOTAL_ALLOCATION not set – claim will fail)
endif

# --------------------------------------------------
# HELP
# --------------------------------------------------

help:
	@echo "make anvil        -> start local node"
	@echo "make build        -> compile"
	@echo "make test         -> run tests"
	@echo "make deploy       -> deploy airdrop"
	@echo "make fund         -> send tokens to airdrop"
	@echo "make sign         -> sign claim hash"
	@echo "make claim        -> claim (ONLY for testing)"
	@echo "make balance      -> token balance"

# --------------------------------------------------
# CORE
# --------------------------------------------------

clean:
	forge clean

build:
	forge build

test:
	forge test

anvil:
	anvil --block-time 1

# --------------------------------------------------
# DEPLOY
# --------------------------------------------------

deploy:
	forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop \
	--rpc-url $(ANVIL_RPC) \
	--private-key $(ANVIL_KEY) \
	--broadcast -vv

# --------------------------------------------------
# FUND AIRDROP
# --------------------------------------------------

fund:
	cast send $(TOKEN_ADDRESS) \
	"transfer(address,uint256)" \
	$(AIRDROP_ADDRESS) \
	10000000000000000000000000 \
	--rpc-url $(ANVIL_RPC) \
	--private-key $(ANVIL_KEY)

# --------------------------------------------------
# SIGN (EIP-712) – TESTING ONLY
# --------------------------------------------------

sign:
	cast call $(AIRDROP_ADDRESS) \
	"getMessageHash(address,uint256)" \
	$$SIGNER_ADDRESS \
	$(TOTAL_ALLOCATION) \
	--rpc-url $(ANVIL_RPC)

# --------------------------------------------------
# CLAIM – STRICT & SAFE
# --------------------------------------------------

claim:
ifndef V
	$(error V not set)
endif
ifndef R
	$(error R not set)
endif
ifndef S
	$(error S not set)
endif
ifndef PROOF
	$(error PROOF not set. Example: export PROOF='[0xabc,0xdef]')
endif

	cast send $(AIRDROP_ADDRESS) \
	"claim(uint256,bytes32[],uint8,bytes32,bytes32)" \
	$(TOTAL_ALLOCATION) \
	'$(PROOF)' \
	$(V) $(R) $(S) \
	--rpc-url $(ANVIL_RPC) \
	--private-key $(ANVIL_KEY)

# --------------------------------------------------
# BALANCE
# --------------------------------------------------

balance:
	cast call $(TOKEN_ADDRESS) \
	"balanceOf(address)" \
	$$SIGNER_ADDRESS \
	--rpc-url $(ANVIL_RPC)
