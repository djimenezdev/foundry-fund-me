// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

contract StorageExp {
    uint256[] public numbers;
    mapping(address user => uint256 number) public mappingValue;

    constructor(address _user) {
        numbers.push(1);
        numbers.push(2);
        numbers.push(3);
        numbers.push(4);
        numbers.push(5);
        mappingValue[_user] = 5;
    }

    function getLengthYul() external view returns (uint256 length) {
        assembly {
            length := sload(numbers.slot)
        }
    }

    function getMappingValue(
        address _userKey
    ) external view returns (uint256 value) {
        uint256 slot;
        assembly {
            slot := mappingValue.slot
        }

        bytes32 location = keccak256(abi.encode(_userKey, slot));

        assembly {
            value := sload(location)
        }
    }

    /* function getLength(uint256 slot) external pure returns (uint256 length) {
        return uint256(keccak256(slot));
    } */

    function getValue(uint256 index) external view returns (uint256 value) {
        uint256 slot;

        assembly {
            slot := numbers.slot
        }

        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            value := sload(add(location, index))
        }
        /*  assembly {
            let arraySlot := sload(numbers.slot)
            let dataSlot := keccak256(arraySlot, 32)

            // Calculate the final slot for the desired index
            let targetSlot := add(dataSlot, index)

            // Load the value at the calculated slot
            value := sload(targetSlot)
        } */
    }
}
