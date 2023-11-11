// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract AlchemonNft is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    // Set price for the genesis NFTs
    uint public constant PRICE = 0.0005 ether;

    constructor() ERC721("Alchemon", "Alch") {}

    // Mint Genesis NFTs
    function mintGenesis(uint _count) public payable {
        require(msg.value >= PRICE, "Not enough ether to purchase genesis NFT.");

        // Genesis NFTs are generation 0
        for (uint i = 0; i < _count; i++) {
            string memory metadata = generateMetadata(_tokenIds.current(), 0);
            _mintSingleNft(metadata);
        }
        
    }

    // Generate NFT metadata
    function generateMetadata(uint tokenId, uint generation) public pure returns (string memory) {
        string memory svg = string(abi.encodePacked(
            "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinyMin meet' viewBox='0 0 350 350'>",
            "<style>.base { fill: white; font-family: serif; font-size: 25px; }</style>",
            "<rect width='100%' height='100%' fill='blue' />",
            "<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>",
            "<tspan y='40%' x='50%'>Alchemon #",
            Strings.toString(tokenId),
            "</tspan>",
            "<tspan y='50%' x='50%'>Generation ",
            Strings.toString(generation),
            "</tspan></text></svg>"
        ));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Alchemon #',
                        Strings.toString(tokenId),
                        '", "description": "An in-game monster", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '", "attributes": [{"trait_type": "Generation", "value": "',
                        Strings.toString(generation),
                        '"}]}'
                    )
                )
            )
        );

        string memory metadata = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return metadata;
    }

    // Breed a new NFT
    function breed(uint parent1Id, uint parent2Id) public {
        require(parent1Id != parent2Id, "Parents must be different");
        require(ownerOf(parent1Id) == msg.sender && ownerOf(parent2Id) == msg.sender, "Sender doesn't own NFTs");

        // Get generations of each parent and compute new generation
        // New Generation = Max(Parent 1, Parent 2) + 1
        uint newGen;

        if (parent1Id >= parent2Id) {
            newGen = parent1Id + 1;
        } else {
            newGen = parent2Id + 1;
        }

        // Generate metadata
        string memory metadata = generateMetadata(_tokenIds.current(), newGen);

        // Mint offspring
        _mintSingleNft(metadata);
    }

    // Mint a single NFT with on-chain metadata
    function _mintSingleNft(string memory _tokenURI) private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _setTokenURI(newTokenID, _tokenURI);
        _tokenIds.increment();
    }

    // Get tokens of an owner
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {

        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    // Withdraw ether
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}