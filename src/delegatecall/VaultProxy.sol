// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VaultProxy {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);

    constructor(address impl, address admin_, bytes memory initData) payable {
        require(admin_ != address(0), "Zero admin");
        bytes32 slot = ADMIN_SLOT;
        assembly {sstore(slot, admin_)}
        emit AdminChanged(address(0), admin_);
        _setImplementation(impl);
        require(initData.length > 0, "Missing initialization");
        (bool ok, bytes memory data) = impl.delegatecall(initData);
        if (!ok) {
            assembly {revert(add(data, 32), mload(data))}
        }
    }

    function implementation() public view returns(address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly { impl := sload(slot) }
    }

    function admin() public view returns(address admin_) {
        bytes32 slot = ADMIN_SLOT;
        assembly {admin_ := sload(slot)}
    }

    function upgradeTo(address newImplementation) external {
        require(msg.sender == admin(), "Not admin");
        _setImplementation(newImplementation);
    }

    function _setImplementation(address impl) private {
        require(impl.code.length > 0, "Implementation has no code");
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly { sstore(slot, impl) }
        emit Upgraded(impl);
    }

    fallback() external payable {
        _delegate(implementation());
    }

    receive() external payable {
        _delegate(implementation());
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let ok := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch ok
            case 0 { return(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
        
    }

}