# Community-Voting-Contracts

**Community voting Smart Contracts used by [DeFiAssociation.io](https://www.defiassociation.io), and [DeFiSwitzerland.io](https://www.defiswitzerland.io)** Built on a solid foundation of community-vetted code, utilizing [open-zeppelin industry standards](https://github.com/OpenZeppelin/openzeppelin-contracts), and storage optimization techniques known as [UnorderedKeySet](https://github.com/rob-Hitchens/UnorderedKeySet) implemented by [Rob Hitchens](https://about.me/hitchens).
 

 * [Voting](contracts/voting/Voting.sol) is built with a time limitation upon voting and proposals.  A vote or proposal can occur within 9 days of the period initializing.  Once this period has been completed, a stall(cooling off period) will occur for 5 days, ensuring that once the winner has been decided they have 5 days to prepare their presentation/demo for the next meet-up.
 * Utilizes [role-based permissioning](contracts/role/Operators.sol) scheme from [openzeppelin roles](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7acd60d152ea83dbc776265ca4a44a3c680b9caf/contracts/access/Roles.sol).  At this time, admins can only add/remove members from the whitelist.
 * [whitelist](contracts/helpers/Whitelist.sol) ensures only authorized parties can propose and vote upon proposals.  This is to minimize parties creating multiple accounts and spam vote.


## Security

This project is maintained by [DefiSwitzerland members](https://www.defiswitzerland.io), and developed following our high standards for code quality and security. Please use common sense when doing anything that deals with real money! We take no responsibility for your implementation decisions and any security problems you might experience.

No audit has been undertaken on version 0.0.1.

Please report any security issues you find to connor@defiSwitzerland.io.


## License

Community-Voting-Contracts is released under the [MIT License](LICENSE).



**DO NOT USE: HAS NOT BEEN TESTED ¯\_(ツ)_/¯**
