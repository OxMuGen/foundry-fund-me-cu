Original code : https://github.com/Cyfrin/foundry-fund-me-cu

## Foundry

```shell
$ forge build
$ forge test
$ forge test -vvvvv # -v : visibility of logging
$ forge fmt

$ forge snapshot    # know gas of every functions
```


### code setup
Foundry does not have access to `npm` package lib, we need to download manually to source : https://github.com/smartcontractkit/chainlink-brownie-contracts

```shell
$ forge install smartcontractkit/chainlink-brownie-contracts@1.2.0 --no-commit
```

foundry.toml
```toml
remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/"]
```

### Convention
```javascript
error FundMe__NotOwner()   // name of the Contract __ error

// Create constant variables instead of letting "Magic variables" with no explanation
uint256 public constant MINIMUM_USD = 5 * 1e18;
```
```shell
# file naming convention
$ FundMeTest.t.sol   # .t  for test files
$ FundMeTest.s.sol   # .s  for script files
```


### Test

```javascript
assertEq($VARIABLE, Value);     // check if $VARIABLE is equal to Value
assert(condition);              // check if condition is met

address USER = makeAddr("user");    // return an address from the given name
vm.deal(USER, STARTING_BALANCE);    // deal : give balance to USER
vm.prank(USER);                     // the next TX will be sent by USER 
hoax(address(i), SEND_VALUE);       // hoax : prank + deal  ---  i should be a uint160 number 

uint256 gasStart = gasleft();       // solidity function : get gas left
uint256 gasEnd = gasleft();
uint256 gasUsed = (gasEnd - gasStart) * tx.gasprice; // tx.gasprice : solidity data of current gas price

vm.txGasPrice(GAS_PRICE);           // apply gas usage to transaction
```
```shell
$ forge test testPriceFeedVersionIsAccurate -vvvvv --fork-url $SEPOLIA_RPC_URL # fork test
$ forge coverage --fork-url $SEPOLIA_RPC_URL # how much of our code is actually tested
```

### Chisel

```shell
$ chisel    # write solidity directly in shell
```

### Gas optimization
https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html
```
Default variables to private
```
```shell
$ forge inspect FundMe storageLayout
$ cast storage CA storageSlot
```

### integration tests
https://github.com/Cyfrin/foundry-devops

```javascript
skipZkSync          // modifier to use in test file
onlyZkSync
onlyVanillaFoundry 
```