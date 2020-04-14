/**
 * @title Operators
 * @author DecentralizedPlanetarian <connorpersonal@protonmail.com>
 * @dev For managing admins.
 */

pragma solidity 0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

contract Operators {
    using Roles for Roles.Role;

    Roles.Role private _admins;

    event AdminAdded(address indexed caller, address indexed account);
    event AdminRemoved(address indexed caller, address indexed account);

    /**
     * @dev Reverts if caller does not have admin role assigned.
     */
    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Operators: caller does not have the admin role");
        _;
    }

    constructor(address _admin) public {
        _addAdmin(_admin);
    }

    /**
     * @return If '_account' has operator privileges.
     */
    function isAdmin(address _account) public view returns (bool) {
        return _admins.has(_account);
    }

    /**
     * @dev Admin can give '_account' address admin privileges.
     * @param _account address that should be given admin privileges.
     */
    function addAdmin(address _account) public onlyAdmin {
        _addAdmin(_account);
    }

    /**
     * @dev Admin can revoke '_account' address admin privileges.
     * @param _account address that should be revoked admin privileges.
     */
    function removeAdmin(address _account) public onlyAdmin {
        require(_account != msg.sender, "BaseOperators: admin can not remove himself");
        _removeAdmin(_account);
    }

    function _addAdmin(address _account) internal {
        _admins.add(_account);
        emit AdminAdded(msg.sender, _account);
    }

    function _removeAdmin(address _account) internal {
        _admins.remove(_account);
        emit AdminRemoved(msg.sender, _account);
    }
}