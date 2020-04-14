/**
 * @title Whitelist
 * @author DecentralizedPlanetarian <connorpersonal@protonmail.com>
 * @dev Whitelist contract with whitelist/unwhitelist functionality for particular addresses.  
            Only executable by prividled users, known as admins.
 */

pragma solidity 0.5.0;

import "../role/Operators.sol";

contract Whitelist is Operators {
    mapping(address => bool) public whitelisted;

    event WhitelistToggled(address indexed account, bool whitelisted);

    /**
     * @dev Reverts if msg.sender is not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "Whitelist: account is not whitelisted.");
        _;
    }

    /**
     * @dev Reverts if address is empty.
     * @param _address address to validate.
     */
    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "Whitelist: invalid address.");
        _;
    }

    /**
    * @dev Getter to determine if address is whitelisted.
    * @param _account address to determine if whitelisted or not.
    * @return bool is whitelisted
    */
    function isWhitelisted(address _account) public view returns (bool) {
        return whitelisted[_account];
    }

    /**
     * @dev Admin can add '_account' address to whitelist.
     * @param _account address that should be added to whitelist.
     */
    function addWhitelist(address _account)
        public
        onlyAdmin
    {
        _toggleWhitelist(_account, true);
    }

    /**
     * @dev Admin can remove '_account' address from whitelist.
     * @param _account address that should be removed from whitelist.
     */
    function removeWhitelist(address _account)
        public
        onlyAdmin
    {
        _toggleWhitelist(_account, false);
    }

    /**
     * @dev Batch whitelisted/unwhitelist multiple addresses, with _toggled being true/false.
     * @param _addresses address array.
     * @param _toggled whitelist/unwhitelist.
     */
    function batchToggleWhitelist(address[] memory _addresses, bool _toggled)
        public
        onlyAdmin
    {
        require(_addresses.length <= 256, "Whitelist: batch count is greater than 256");
        for (uint256 i = 0; i < _addresses.length; i++) {
            _toggleWhitelist(_addresses[i], _toggled);
        }
    }

    /* --------------- INTERNAL --------------- */
    function _toggleWhitelist(address _account, bool _toggle)
        internal
    {
        require(whitelisted[_account] != _toggle, "Whitelist: account is already desired outcome");
        whitelisted[_account] = _toggle;
        emit WhitelistToggled(_account, _toggle);
    }
}
