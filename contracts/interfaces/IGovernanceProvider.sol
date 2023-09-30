// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGovernanceProvider {

	function getOwner() external view returns(address);

}