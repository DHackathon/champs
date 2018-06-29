pragma solidity ^0.4.19;
contract HackathonState {
    enum State { Created, CrowFound, SignUp, Match, Vote, Final, Failed } // Enum
    State public state;
    // Modifiers can receive arguments:
    modifier requireState(State _state) {
        require(state == _state);
        _;
    }
    
    function HackathonState() public {
        state = State.Created;
    }
}