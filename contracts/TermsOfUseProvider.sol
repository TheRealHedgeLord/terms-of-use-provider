// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Governable.sol';


contract TermsOfUseProvider is Governable {

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    string[] private termsOfUse;
    mapping(uint256 => mapping(address => bool)) private userStatus;
    mapping(uint256 => mapping(address => Signature)) private signatures;

    constructor(
        address initialGovernanceProvider
    ) {
        governanceProvider = initialGovernanceProvider;
    }

    function recoverSigner(
        string message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns(address) {
        string memory header = "\x19Ethereum Signed Message:\n000000";
        uint256 lengthOffset;
        uint256 length;
        assembly {
            length := mload(message)
            lengthOffset := add(header, 57)
        }
        require(length <= 999999);
        uint256 lengthLength = 0;
        uint256 divisor = 100000;
        while (divisor != 0) {
            uint256 digit = length / divisor;
            if (digit == 0) {
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }
            lengthLength++;
            length -= digit * divisor;
            divisor /= 10;
            digit += 0x30;
            lengthOffset++;
            assembly {
                mstore8(lengthOffset, digit)
            }
        }
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }
        assembly {
            mstore(header, lengthLength)
        }
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return ecrecover(check, v, r, s);
    }

    function getMaxIndex() public view returns(uint256) {
        return termsOfUse.length;
    }

    function getTermsOfUseByIndex(
        uint256 index
    ) public view returns(string memory) {
        return termsOfUse[index];
    }

    function isSigned(
        uint256 index,
        address userAddress
    ) public view returns(bool) {
        return userStatus[index][userAddress];
    }

    function getSignature(
        uint256 index,
        address userAddress
    ) public view returns(Signature memory) {
        return signatures[index][userAddress];
    }

    function createTermsOfUse(
        string memory text
    ) public ownerOnly returns(uint256) {
        termsOfUse.push(text);
        return getMaxIndex();
    }

    function sendSignature(
        address singer,
        uint256 index,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        address recoveredSigner = recoverSigner(termsOfUse[index], v, r, s);
        require(
            signer != address(0) && recoveredSigner == signer,
            "TermsOfUseProvider: Invalid signature"
        );
        signatures[index][recoveredSigner] = Signature(v, r, s);
        userStatus[index][recoveredSigner] = true;
    }

}