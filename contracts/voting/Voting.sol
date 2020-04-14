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
    uint24 constant STALL_PERIOD = VOTE_PERIOD + 5 days; // no need for safe math, no way of overflow.

    HitchensUnorderedKeySetLib.Set set;
    mapping(bytes32 => Vote) public votes;
    mapping(bytes32 => Proposal) public proposals;

    struct Vote {
        address voter;
        bytes32 proposal;
        bool voted;
    }

    struct Proposal {
        string description;
        address creator;
        uint256 voteCount;
    }

    event ProposalCreated(address indexed account, bytes32 indexed identifier, uint256 period);
    event ProposalRevoked(address indexed account, bytes32 indexed identifier, uint256 period);

    event VoteCasted(address indexed account, bytes32 indexed voter, bytes32 indexed identifier, uint256 period);
    event NewPeriod(address indexed account, uint256 indexed period);

    /**
    * @dev Reverts if not in voting time range.
    */
    modifier onlyWhileOpen {
        require(block.timestamp >= currentPeriod && block.timestamp <= currentRange(), "Voting: not within voting range.");
        _;
    }

    /**
    * @dev Reverts if in voting time range, and greater than stall period.
    */
    modifier onlyWhileClosed {
        require(block.timestamp >= currentRange() && block.timestamp <= STALL_PERIOD, "Voting: still within voting range.");
        _;
    }

    /**
    * @dev Whitelisted 'msg.sender' can propose new topic of discussion.
    * @param _description description of what will be discussed/demo'd.
    */
    function propose(string memory _description)
        public
        onlyWhitelisted
        onlyWhileOpen
    {
        require(bytes(_description).length != 0, "Voting: Description should not be empty.");

        bytes32 _proposal = getHash(currentPeriod, msg.sender);
        _insertProposal(_proposal, _description);

        emit ProposalCreated(msg.sender, _proposal, currentPeriod);
    }

    /**
    * @dev Whitelisted 'msg.sender' can revoke their proposal.
    * @param _proposal unique identifier associated to proposal.
    */
    function revokeProposal(bytes32 _proposal)
        public
        onlyWhitelisted
        onlyWhileOpen
    {
        require(getCreator(_proposal) == msg.sender, "Voting: caller is not creator.");

        _revokeProposal(_proposal);

        emit ProposalRevoked(msg.sender, _proposal, currentPeriod);
    }

    /**
    * @dev Whitelisted 'msg.sender' can vote upon an existing proposal.
    * @param _proposal unique identifier associated to proposal.
    */
    function vote(bytes32 _proposal)
        public
        onlyWhitelisted
        onlyWhileOpen
    {
        require(getCreator(_proposal) != msg.sender, "Voting: caller can not be creator.");

        bytes32 _voter = getHash(currentPeriod, msg.sender);
        _insertVote(_voter, _proposal);

        emit VoteCasted(msg.sender, _voter, _proposal, currentPeriod);
    }

    /**
    * @dev Start new period when demo/presentation has occured.
    */
    function startNewPeriod()
        public
        onlyWhileClosed
    {
        set.nukeSet();
        currentPeriod = STALL_PERIOD;

        emit NewPeriod(msg.sender, currentPeriod);
    }

    /**
    * @dev Get voting end of current period.
    * @return uint256 voting end epoch time.
    */
    function currentRange()
        public
        view
        returns(uint256)
    {
        return (currentPeriod.add(VOTE_PERIOD));
    }

    /**
    * @dev Get generating unique proposal hash from currentPeriod, and account.
    * @return bytes32 unique identifier.
    */
    function getHash(uint256 _proposal, address _account)
        public
        pure
        returns(bytes32)
    {
        return keccak256(abi.encodePacked(_proposal, _account));
    }

    /**
    * @dev Get creator of proposal via proposal identifier.
    * @return bytes32 unique identifier.
    */
    function getCreator(bytes32 _proposal)
        public
        view
        returns(address)
    {
        return proposals[_proposal].creator;
    }

    /* --------------- INTERNAL --------------- */
    function _insertProposal(bytes32 _proposal, string memory _description)
        internal
    {
        set.insert(_proposal); // will revert if exists
        proposals[_proposal] = Proposal(_description, msg.sender, 1);
    }

    function _revokeProposal(bytes32 _proposal)
        internal
    {
        set.remove(_proposal); // will revert if does not exist
        delete proposals[_proposal];
    }

    function _insertVote(bytes32 _voter, bytes32 _proposal)
        internal
    {
        require(set.exists(_proposal), "Voting: proposal does not exist");

        set.insert(_voter); // will revert if exists
        votes[_voter] = Vote(msg.sender, _proposal, true);

        uint256 _votes = proposals[_proposal].voteCount;
        proposals[_proposal].voteCount = _votes.add(1);
    }
}
