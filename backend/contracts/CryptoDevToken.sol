// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ICryptoDevs.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CryptoDevToken is ERC20, Ownable{
    uint public constant tokenPrice = 0.001 ether;
    uint public constant tokenPerNFT = 10 * 10 ** 18;
    uint public constant maxTotalSupply = 10000 * 10 ** 18;
    ICryptoDevs CryptoDevNFT;
    mapping (uint256 => bool) public tokenIdsClaimed;

    constructor (address _cryptodevscontract) ERC20("CryptoDevs","CD"){
        CryptoDevNFT = ICryptoDevs(_cryptodevscontract);
    }

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount,"Sent Ethers not sufficient !");
        uint256 amountWithDecimals = amount * 10**18;
        require (
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max token supply available."
        );
        _mint(msg.sender,amountWithDecimals);
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = CryptoDevNFT.balanceOf(sender);
        require(balance > 0, "You dont own any Crypto Dev NFT");
        uint amount = 0;
        
        for( uint i = 0; i < balance; i++){
            uint256 tokenId = CryptoDevNFT.tokenOfOwnerByIndex(sender,i);
            if (!tokenIdsClaimed[tokenId]){
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        require(amount > 0, "You have already claimed all the tokens");

        _mint(msg.sender, amount*tokenPerNFT);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require (sent, "Failed to send ether");
    }

    receive() external payable{}
    fallback() external payable{}
}
