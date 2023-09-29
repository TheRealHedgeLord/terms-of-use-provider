// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interfaces/IGovernanceProvider.sol';


contract Governable {

	address public governanceProvider;

	modifier ownerOnly {
		require(
			msg.sender == IGovernanceProvider(governanceProvider).owner(),
			"Governance: Access denied"
		);
		_;
	}

	function setGovernanceProvider(
		address newGovernanceProvider
	) public ownerOnly {
		governanceProvider = newGovernanceProvider;
	}

}