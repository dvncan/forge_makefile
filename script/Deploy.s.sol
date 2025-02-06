// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
// import {Contract} from "../src/path";


contract DeploySc is Script {

// -- declare global contract here -- //
// Contract myContract;

    function run() public {
        vm.broadcast();
        // myContract = new Contract(constructor_args);
        // uint256 returnNumber = myContract.myTransaction_1(args);
        // address returnAddress = myContract.myTransaction_2(args);
        vm.stopBroadcast();
    }
}
