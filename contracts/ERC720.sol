// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Goraya is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 public maxSupply = 2000;
    mapping (address => bool) public allowList;

    bool publicMintOpen = false;
    bool allowListMintOpen = false;

    constructor() ERC721("Goraya", "GRY") Ownable(msg.sender) {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen)
        external
        onlyOwner
    {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    function setAllowList(address[] calldata addresses) external onlyOwner {
        for (uint i=0; i<addresses.length; i++) 
        {
            allowList[addresses[i]]= true;
        }
    }

    function publicMint() public payable {
        require(publicMintOpen, "publicMint is not open");
        require(msg.value == 0.01 ether, "Not Enough Value");
        internalMint();
    }

    function allowListMint() public payable {
        require(allowListMintOpen, "allowList mint is not open");
        require(allowList[msg.sender], "Not Allowed");
        require(msg.value == 0.001 ether, "Not Enough Value");
       internalMint();
    }

    function internalMint() internal  {
        require(totalSupply() < maxSupply, "We Sold Out!!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }


    function withdraw(address _address) external onlyOwner {
        payable(_address).transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
