pragma solidity ^0.4.19;
import "./Ownable.sol";
import "./Hackathon.sol";

contract HackathonFactory is Ownable {
    event HackathonCreated(
        address indexed _owner,
        address indexed _contract
    );
    
    function HackathonFactory() public {
    }
    
    function CreateHackathon( 
        uint256 _crowdFoundTarget,
        uint256 _crowdFoundPeriod,
        uint256 _signUpPeriod,
        uint256 _matchPeriod,
        uint256 _votePeriod,
        uint256 _deposit,
        uint256 _signUpFee,
        uint256 _champBonus,
        uint256 _secondBonus,
        uint256 _thirdBonus,
        uint256 _voteBonus,
        uint256 _registerUpperLimit,
        uint256 _registerLowerLimit
    ) public payable {
        Hackathon hackathon = new Hackathon(
            msg.value,
            _crowdFoundTarget,
            _crowdFoundPeriod,
            _signUpPeriod,
            _matchPeriod,
            _votePeriod,
            _deposit,
            _signUpFee,
            _champBonus,
            _secondBonus,
            _thirdBonus,
            _voteBonus,
            _registerUpperLimit,
            _registerLowerLimit
        );
        hackathon.transfer(msg.value);
        hackathon.transferOwnership(msg.sender);
        HackathonCreated(msg.sender, address(hackathon));
    }
}
