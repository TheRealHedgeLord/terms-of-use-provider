// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interfaces/IGovernanceProvider.sol';


contract Governable {

	address private governanceProvider;

	modifier ownerOnly {
		require(
			msg.sender == IGovernanceProvider(governanceProvider).getOwner(),
			"Governance: Access denied"
		);
		_;
	}

    constructor(
        address initialGovernanceProvider
    ) {
        governanceProvider = initialGovernanceProvider;
    }

	function getGovernanceProvider() public view returns(address) {
		return governanceProvider;
	}

	function setGovernanceProvider(
		address newGovernanceProvider
	) public ownerOnly {
		governanceProvider = newGovernanceProvider;
	}

}