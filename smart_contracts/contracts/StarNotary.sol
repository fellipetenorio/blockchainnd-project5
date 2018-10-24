pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721 { 

    struct Star { 
        string name;
        string dec;
        string mag;
        string cent;
        string story;
    }

    /*
    createStar() - OK
    putStarUpForSale() - OK
    buyStar() - OK   
    checkIfStarExist() - OK
        Utilizing star coordinates, this function will check if the coordinates have already been claimed. The return type is boolean.
    mint() - OK
    approve()
    safeTransferFrom()
    SetApprovalForAll()
    getApproved()
    isApprovedForAll()
    ownerOf() - ok
    starsForSale() - ok
    tokenIdToStarInfo() - ok
    Expected response:
    ["Star power 103!", "I love my wonderful star", "ra_032.155", "dec_121.874", "mag_245.978"]
     */

    // create inverse map
    mapping(string => uint256) internal starToToken;
    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;

    event log(string log);
    event logint(uint256 log);

    function mint(uint256 _tokenId) public { 
        require(tokenToOwner[_tokenId] == address(0), "this token belongs to someone else already");

        tokenToOwner[_tokenId] = msg.sender; 
        ownerToBalance[msg.sender] += 1;

        emit Transfer(address(0), msg.sender, _tokenId);
    }

    modifier uniqueStar(string _dec, string _mag, string _cent) {
        string memory starId = createStarId(_dec, _mag, _cent);
        emit log(starId);
        emit logint(starToToken[starId]);
        require(starToToken[starId] == 0, "Star already exists");
        _;
    }

    function createStar(string _name, string _dec, string _mag, string _cent, string _story, uint256 _tokenId) public uniqueStar(_dec, _mag, _cent) { 
        // verify star
        Star memory newStar = Star(_name, _dec, _mag, _cent, _story);
        string memory starId = createStarId(_dec, _mag, _cent);
        // verify if this star already exists
        tokenIdToStarInfo[_tokenId] = newStar;
        starToToken[starId] = _tokenId;

        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender, "Only the owner can put Start for sale");

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0, "Star not for sale");
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost, "Not enough balance to buy");

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function checkIfStarExist(string _dec, string _mag, string _cent) public returns (bool) {
        return starToToken[createStarId(_dec, _mag, _cent)] > 0;
    }

    function createStarId(string _dec, string _mag, string _cent) public returns (string){
        return strConcat(_dec, _mag, _cent);
    }

    // concat strings
    // ref: https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    // concat strings
    // ref: https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
    
    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }
    // concat strings
    // ref: https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
    
    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }
    // concat strings
    // ref: https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
    
    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    }
}