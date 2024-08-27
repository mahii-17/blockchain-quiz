// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract QuizToken {
    string public name = "QuizToken";
    string public symbol = "QTZ";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** uint256(decimals)); // 1 million tokens

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public hasParticipated;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CorrectAnswer(address indexed participant, uint256 reward);

    address public owner;

    struct Quiz {
        string question;
        string correctAnswer;
        bool isActive;
    }

    Quiz[] public quizzes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
    }

    // Function to add new quizzes (Only owner can add quizzes)
    function addQuiz(string memory question, string memory correctAnswer) public onlyOwner {
        quizzes.push(Quiz({
            question: question,
            correctAnswer: correctAnswer,
            isActive: true
        }));
    }

    // Function to answer a quiz
    function answerQuiz(uint256 quizIndex, string memory answer) public {
        require(quizIndex < quizzes.length, "Quiz does not exist");
        require(quizzes[quizIndex].isActive, "Quiz is not active");
        require(!hasParticipated[msg.sender], "You have already participated");

        if (keccak256(abi.encodePacked(answer)) == keccak256(abi.encodePacked(quizzes[quizIndex].correctAnswer))) {
            uint256 reward = 10 * (10 ** uint256(decimals)); // 10 tokens as a reward
            require(balanceOf[owner] >= reward, "Not enough tokens in the contract");
            balanceOf[owner] -= reward;
            balanceOf[msg.sender] += reward;
            emit Transfer(owner, msg.sender, reward);
            emit CorrectAnswer(msg.sender, reward);
        }
        
        hasParticipated[msg.sender] = true;
    }

    // Function to check quiz question
    function getQuiz(uint256 quizIndex) public view returns (string memory) {
        require(quizIndex < quizzes.length, "Quiz does not exist");
        return quizzes[quizIndex].question;
    }
}
