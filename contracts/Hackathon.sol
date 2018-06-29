pragma solidity ^0.4.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./State.sol";

contract Hackathon is Ownable, HackathonState {
    using SafeMath for uint256;

    uint256 public initFound;
    uint256 public totalCrowdFound;
    uint256 public totalFound;
    mapping(address => uint256) internal crowdFound;


    uint256 public crowdFoundTarget;
    uint256 public crowdFoundPeriod;

    uint256 public signUpPeriod;
    uint256 public matchPeriod;
    uint256 public votePeriod;
    
    
    uint256 public closingCrowdFound;
    uint256 public closingSignUp;
    uint256 public closingMatch;
    uint256 public closingVote;

    uint256 public deposit;
    uint256 public signUpFee;
    
    uint256 public champBonus;
    uint256 public secondBonus;
    uint256 public thirdBonus;
    uint256 public voteBonus;
    
    address [] registers;
    mapping(address => bool) internal registersMap;

    mapping(address => bool) internal voted;
    address [] voters;
    mapping(address => address) internal voteTargets;
    mapping(address => uint256) internal votes;
    
    uint256 public registerUpperLimit;
    uint256 public registerLowerLimit;
    
    
    address public champ;
    address public second;
    address public third;
    mapping(address => uint256) internal bonus;
    address [] voteWiners;

    function Hackathon(
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
        require(_crowdFoundPeriod > 0);
        require(_signUpPeriod > 0);
        require(_matchPeriod > 0);
        require(_votePeriod > 0);

        require(_champBonus <= 100);
        require(_secondBonus <= 100);
        require(_thirdBonus <= 100);
        require(_voteBonus <= 100);
        require(_champBonus.add(_secondBonus).add(_thirdBonus).add(_voteBonus) == 100); 
        
        require(_registerUpperLimit >= _registerLowerLimit);
        require(_registerLowerLimit > 0);

        initFound = msg.value;
        totalFound = msg.value;

        crowdFoundTarget = _crowdFoundTarget;

        crowdFoundPeriod = _crowdFoundPeriod;
        signUpPeriod = _signUpPeriod;
        matchPeriod = _matchPeriod;
        votePeriod = _votePeriod;
        deposit = _deposit;
        signUpFee = _signUpFee;
        
        champBonus = _champBonus;
        secondBonus = _secondBonus;
        thirdBonus = _thirdBonus;
        voteBonus = _voteBonus;
        
        registerUpperLimit = _registerUpperLimit;
        registerLowerLimit = _registerLowerLimit;
    }
    
    function startCrowdFound() public requireState(State.Created) onlyOwner {
        state = State.CrowFound;
        closingCrowdFound = block.timestamp.add(crowdFoundPeriod);
    }
    
    function buy(address _beneficiary) public payable requireState(State.CrowFound) {
        require(totalCrowdFound.add(msg.value) <= crowdFoundTarget);
        require(block.timestamp  <= closingCrowdFound);
        
        totalCrowdFound = totalCrowdFound.add(msg.value);
        totalFound = totalFound.add(msg.value);
        crowdFound[_beneficiary] = crowdFound[_beneficiary].add(msg.value);
    }
    
    function crowdFoundGoalReached() public view returns (bool) {
        return totalCrowdFound >= crowdFoundTarget;
    }
    
    function startSignUp() public requireState(State.CrowFound) onlyOwner {
        require(block.timestamp > closingCrowdFound);
        require(totalCrowdFound >= crowdFoundTarget);

        state = State.SignUp;
        closingSignUp = block.timestamp.add(signUpPeriod);
    }
    
    function signUp(address _register) public payable requireState(State.SignUp) {
        require(block.timestamp <= closingSignUp);
        require(msg.value == deposit.add(signUpFee));
        require(registers.length < registerUpperLimit);
        
        totalFound = totalFound.add(signUpFee);
        registers.push(_register);
        registersMap[_register] = true;
    }
    
    function signUpGoalReached() public view returns (bool) {
        return registers.length >= registerLowerLimit;
    }
    
    function votable(address _person) internal returns (bool) {
        if ((crowdFound[_person] > 0 || msg.sender == owner) && (!voted[_person]) ) {
            voted[_person] = true;
            return true;
        }
        return false;
    }
    
    function is_failed() public view returns (bool) {
        if (state == State.CrowFound && block.timestamp > closingCrowdFound && totalCrowdFound < crowdFoundTarget){
            return true;
        }
        
        if (state == State.SignUp && block.timestamp > closingSignUp && registers.length < registerLowerLimit){
            return true;
        }
        return false;
    }
    
    function failed() public {
        require(is_failed());
        state = State.Failed;
    }
    
    function startMatch() public requireState(State.SignUp) onlyOwner {
        require(block.timestamp > closingSignUp);
        require(registers.length >= registerLowerLimit);

        state = State.Match;
        closingMatch = block.timestamp.add(matchPeriod);
    }
    
    
    function startVote() public requireState(State.Match) onlyOwner {
        require(block.timestamp > closingMatch);

        state = State.Vote;
        closingVote = block.timestamp.add(votePeriod);
    }
    
    
    function vote(address _target) public requireState(State.Vote) {
        require(block.timestamp <= closingVote);
        require(registersMap[_target]);

        // change voted
        require(votable(msg.sender));

        if (msg.sender == owner) {
            votes[_target] = votes[_target].add(initFound);
        }
        
        if (crowdFound[msg.sender] > 0) {
            votes[_target] = votes[_target].add(crowdFound[msg.sender]);
        }
        
        voteTargets[msg.sender] = _target;
        voters.push(msg.sender);
    }
    
    
    function finalize() public requireState(State.Vote) {
        require(block.timestamp > closingVote);
        state = State.Final;
        
        address _champ = registers[0];
        address _second = registers[0];
        address _third = registers[0];
        
        for (uint i = 0; i < registers.length; i++) {
            
            if (votes[registers[i]] > votes[_champ]) {
                _champ = registers[i];
            }
            
            if (votes[registers[i]] > votes[_second] && votes[registers[i]] < votes[_champ]) {
                _second = registers[i];
            }
            
            if (votes[registers[i]] > votes[_third] && votes[registers[i]] < votes[_second]) {
                _third = registers[i];
            }
        }
        
        champ = _champ;
        second = _second;
        third = _third;
        
        bonus[champ] = totalFound.mul(champBonus).div(100);
        bonus[second] = totalFound.mul(secondBonus).div(100);
        bonus[third] = totalFound.mul(thirdBonus).div(100);
        
        uint256 voteBonusFound = totalFound.sub(bonus[champ]).sub(bonus[second]).sub(bonus[third]);
        
        
        
        for (uint j = 0; j < voters.length; j++) {
            if (voteTargets[voters[j]] == champ) {
                voteWiners.push(voters[j]);
            }
        }
        
        uint num = voteWiners.length;
        for (uint k = 0; k < voteWiners.length; k++) {
            bonus[voteWiners[k]] = bonus[voteWiners[k]].add(voteBonusFound.div(num));
            voteBonusFound.sub(voteBonusFound.div(num));
        }
        
        if (voteBonusFound > 0) {
            bonus[owner] = voteBonusFound;
        }
    }
    
    // Remember to zero the pending refund before
    function withdraw() public {
        require(state == State.Final || state == State.Failed);
        require(owner == msg.sender || crowdFound[msg.sender] > 0);
        if (state == State.Failed) {
            if (owner == msg.sender && initFound > 0) {
                uint256 owner_amount = initFound;
                initFound = 0;
                msg.sender.transfer(owner_amount);
            }
            
            if (crowdFound[msg.sender] > 0) {
                uint256 amount = crowdFound[msg.sender];
                crowdFound[msg.sender] = 0;
                msg.sender.transfer(amount);
            }
            
            if (registersMap[msg.sender]) {
                registersMap[msg.sender] = false;
                msg.sender.transfer(deposit);
            }
        }
        
        if (state == State.Final) {
            if (registersMap[msg.sender]) {
                registersMap[msg.sender] = false;
                msg.sender.transfer(deposit);
            }
            
            if (bonus[msg.sender] > 0 ) {
                uint256 bonus_amount = bonus[msg.sender];
                bonus[msg.sender] = 0;
                msg.sender.transfer(bonus_amount);
            }
        }
        
    }
}