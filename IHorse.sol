pragma solidity ^0.5.5;

import "./ITRC721.sol";

/**
 * @dev Required interface of an TRC721 compliant contract.
 */
contract IHorse is ITRC721 {

    function spawnHorse(uint256 _genes, address _owner) external returns (uint256);

    function getHorse(uint256 token_id) external returns (uint256, uint256);

}
