/**
 * @title Voting
 * @author DecentralizedPlanetarian <connorpersonal@protonmail.com>
 * @dev For proposing/voting on what the topic of discussion the following meet-up should be.
 */

pragma solidity 0.5.0;

import "../helpers/Whitelist.sol";
import "../helpers/HitchensUnorderedKeySetLib.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract Voting is Whitelist {
    using SafeMath for uint256;
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;


    uint256 public currentPeriod;
    uint24 constant VOTE_PERIOD = 1 weeks + 2 days; // no need for safe math, no way of overflow.

    HitchensUnorderedKeySetLib.Set set;
    mapping(bytes32 => Proposal) public proposals;

    struct Proposal {
        string description;
        address creator;
        uint256 voteCount;
    }

    event ProposalCreated(address indexed account, bytes32 indexed identifier, uint256 indexed period);
    event ProposalRevoked(address indexed account, bytes32 indexed identifier, uint256 indexed period);

    /**
     * @dev Reverts if not in voting time range.
     */
    modifier onlyWhileOpen {
        require(block.timestamp >= currentPeriod && block.timestamp <= currentRange(), "Voting: not within voting range.");
        _;
    }

    function propose(string memory _description)
        public
        onlyWhitelisted
        onlyWhileOpen
    {
        require(bytes(_description).length != 0, "Voting: Description should not be empty.");
        bytes32 _identifier = getHash(currentPeriod, msg.sender);
        _insertProposal(_identifier, _description);
        emit ProposalCreated(msg.sender, _identifier, currentPeriod);
    }

    function revokeProposale(bytes32 _identifier)
        public
        onlyWhitelisted
        onlyWhileOpen
    {
        require(getCreator(_identifier) == msg.sender, "Voting: caller is not creator.");
        _revokeProposal(_identifier);
        emit ProposalRevoked(msg.sender, _identifier, currentPeriod);
    }

    function currentRange()
        public
        view
        returns(uint256)
    {
        return (currentPeriod.add(VOTE_PERIOD));
    }

    function getHash(uint256 _currentPeriod, address _creator)
        public
        view
        returns(bytes32)
    {
        return keccak256(abi.encodePacked(_currentPeriod, _creator));
    }

    function getCreator(bytes32 _identifier)
        public
        view
        returns(address)
    {
        return proposals[_identifier].creator;
    }

    /* --------------- INTERNAL --------------- */
    function _insertProposal(bytes32 _identifier, string memory _description)
        internal
    {
        set.insert(_identifier); // will revert if exists
        proposals[_identifier] = Proposal(_description, msg.sender, 0);
    }

    function _revokeProposal(bytes32 _identifier)
        internal
    {
        set.remove(_identifier); // will revert if does not exist
        delete proposals[_identifier];
    }

}
