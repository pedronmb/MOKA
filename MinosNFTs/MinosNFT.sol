// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 *  @title IUbi
 *  Inteface is for calling POH methods.
 */
interface IUbi{
    function isRegistered(address) external view returns (bool);
}

/**
 *  @title MokaNft
 *  This contract is a colletcion of NFTs for the project Minos Of Kazordoon.
 *  21000 of NFT only for people registered in POH 
 */

contract MokaNft is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    //Address POH Kovan contract '0x73bcce92806bce146102c44c4d9c3b9b9d745794'
    //Address POH Mainet contract '0xC5E9dDebb09Cd64DfaCab4011A0D5cEDaf7c9BDb'
    address private _ubi = 0xC5E9dDebb09Cd64DfaCab4011A0D5cEDaf7c9BDb;
    //Blacklist Mapping
    mapping(address => bool) private _blackList;

    constructor() ERC721("Minos of Kazordoon", "MOKA") {_tokenIdCounter.increment();}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmQqs5vDm2xWgGWnRHcHdbSK7x8nPbPj3YChD15pXuaX9u/";
    }

    modifier maxSupply() {
        require(_tokenIdCounter.current() < 21000, "Max supply it's superated");
        _;
    }
    /** @dev Sets the address in blacklist.
     *  @param _to The address to add to the blacklist.
     */
    function addBlacklist(address _to) private{
        _blackList[_to] = true;
    }
    /** @dev Gets if the address has already called method safeMint.
     *  @param _to The address of the queried submission.
     *  @return The value of mapping _blacklist.
     */
    function isBlacklist(address _to) public view returns (bool) {
        return _blackList[_to];
    }
    /** @dev Gets if the address is registered in POH.
     *  @param _to The address of the queried submission.
     *  @return The result of POH method isRegistered, True or false.
     */
    function isRegestry(address _to) public view returns (bool) {
        return IUbi(_ubi).isRegistered(_to);
    }
    
    function safeMint() public maxSupply {
        //Verify if the wallert has not already called safeMint
        require(!_blackList[_msgSender()], "Address already mint a NFT");
        //Verify if the wallet has registered in POH
        require(isRegestry(_msgSender()), "Address not registered in POH");
        uint256 tokenId = _tokenIdCounter.current();

        _tokenIdCounter.increment();
        _safeMint(_msgSender(), tokenId);
        addBlacklist(_msgSender());
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId),".json")) : "";
    }

}
