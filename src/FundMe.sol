// Get funds from users
// withdraw funds
// set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

// ================================================================= GAS ====
// 2 keywords that makes contract use less gas fee
// constant and immutable
// 21.415 gas - constant
// 23.515 gas - non-constant
// 21.415 * 141000000000 wei = 3 019 515 000 000 000 * 3000 = $9.058545
// 23.415 * 141000000000 wei = $9.946845
// 21.508 gas - immutable
// 23.644 gas - non-immutable
// storage variable use more gas than function variable

// capitalized variable is a convention for constant variable
// s_ is a convention for state variable
// i_ is a convention for immutable variable

// public - all can access
// external - Cannot be accessed internally, only externally (and less gas)
// internal - only this contract and contracts deriving from it can access
// private - can be accessed only from this contract

// view no data will be saved/changed.
// pure not save any data to the blockchain, also doesn't read any data from the blockchain.
// no gas to call externally from outside the contract (but cost gas if called internally by another function).

contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // variables
    // default to private variables as it is more gas efficient
    // so make getter functions to return private variables
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;
    address[] private s_funders;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 1e18; // 5e18  or 5 * 10 ** 18
    AggregatorV3Interface private s_priceFeed;

    // Events (we have none!)

    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner, FundMe__NotOwner());
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _; // executing the code of the function modified
    }

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "didn't send enough ETH"
        ); // 1e18 = 1 ETH = 1000000000000000000 = 1 * 10 **(power or exponent) 18
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        // reset mapping
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset array
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        // reset mapping
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset array
        s_funders = new address[](0);

        // // withdraw funds: 3 types to withdraw (transfer, send, call)
        // msg.sender = address
        // payable(msg.sender) = payable address
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // // call is the recommanded method right now, watch for gas fees
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    /** Getter Functions */

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

// Enums
// Events
// Try / catch
// Function Selectors
// abi.encode / decode
// Hashing
// Yul // Assembly
