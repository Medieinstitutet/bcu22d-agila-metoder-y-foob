// SPDX-License-Identifier: CBT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import "@openzeppelin/contracts@4.8.0/token/ERC1155/extensions/ERC1155Supply.sol";

contract CryptoBar is ERC1155, Ownable, ERC1155Supply {
    uint256 constant TOKEN_PRICE = 0.02 ether; //Mint price
    uint256 public constant MAX_TOKENS = 100; //Max supply

    mapping(address => bool) public userClaimed;

    constructor() ERC1155("https://gateway.pinata.cloud/ipfs/QmWHBAv1eAnph3UaM5oAnyJCq2MhZcAd1EqsuM1bB8FTaG/cryptobar.json {id}") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint() public payable {
        require(totalSupply(0) + 1 <= MAX_TOKENS, 'Purchase would exceed max supply of tokens');
        require(TOKEN_PRICE == msg.value, 'Ether value sent is not correct');
        _mint(msg.sender, 0, 1, '');
    }

    function onSaleMint(bytes32[] calldata proof) external payable {
        require(totalSupply(0) + 1 <= MAX_TOKENS, 'Purchase would exceed max supply of tokens');
        require(!userClaimed[msg.sender], 'Adress already claimed');

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, msg.value));

        _mint(msg.sender, 0, 1, '');

        userClaimed[msg.sender] = true;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}