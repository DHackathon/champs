pragma solidity ^0.4.19;
contract Auth {
    mapping(address => bytes32) internal verification;
    
    function submit(bytes32 code) public {
        verification[msg.sender] = code;
    }
    
    function getVerificationCode(address _person) public view returns (bytes32) {
        return verification[_person];
    }
}