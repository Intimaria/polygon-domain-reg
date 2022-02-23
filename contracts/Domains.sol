// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {StringUtils} from "./libraries/StringUtils.sol";
// We import another help function
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract Domains is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string public tld;
	
	// We'll be storing our NFT images on chain as SVGs
  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#a)" d="M0 0h270v270H0z"/><defs><filter id="b" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="m79 105-29.39 15.45 5.615-32.725-23.78-23.175 32.86-4.775L79 30l14.695 29.775 32.86 4.775-23.775 23.175 5.615 32.725Z" stroke="#000" stroke-miterlimit="10" stroke-width="11.5"/><path d="M211 309 93.44 370.8l22.46-130.9-95.12-92.7 131.44-19.1L211 9l58.78 119.1 131.44 19.1-95.1 92.7 22.46 130.9Z" stroke="#000" stroke-miterlimit="10" stroke-width="22"/><defs><linearGradient id="a" x1="0" y1="0" x2="270" y2="279" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="30" y="230" font-size="25" fill="#cbeeee" filter="url(#b)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';

  mapping(string => address) public domains;
  mapping(string => string) public records;

  constructor(string memory _tld) payable ERC721("Astro Name Service", "ANS") {
    tld = _tld;
    console.log("%s name service deployed", _tld);
  }

  function register(string calldata name) public payable {
    require(domains[name] == address(0));

    uint256 _price = price(name);
    require(msg.value >= _price, "Not enough Matic paid");
		
		// Combine the name passed into the function  with the TLD
    string memory _name = string(abi.encodePacked(name, ".", tld));
		// Create the SVG (image) for the NFT with the name
    string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
    uint256 newRecordId = _tokenIds.current();
  	uint256 length = StringUtils.strlen(name);
		string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

		// Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "A domain on the Pattern name service", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '","length":"',
            strLen,
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

		console.log("\n--------------------------------------------------------");
	  console.log("Final tokenURI", finalTokenUri);
	  console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);
    domains[name] = msg.sender;

    _tokenIds.increment();
  }
		
  // This function will give us the price of a domain based on length
  function price(string calldata name) public pure returns(uint) {
    uint len = StringUtils.strlen(name);
    require(len > 0);
    if (len == 3) {
      return 5 * 10**17; 
    } else if (len == 4) {
      return 3 * 10**17; 
    } else {
      return 1 * 10**17;
    }   
  }


  function getAddress(string calldata name) public view returns (address) {
      return domains[name];
  }
  function setRecord(string calldata name, string calldata record) public {
      // only allows owner of the domain to modify it
      require(
          domains[name] == msg.sender,
          "Trying to modify a domain that has been registered to someone else."
      );
      records[name] = record;
  }
  function getRecord(string calldata name) public view returns(string memory) {
        return records[name];
  }
}