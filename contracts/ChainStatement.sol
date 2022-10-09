//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/// @title ChainStatement contract.
/// @dev This contract is the main contract of our ChainStatement dApp
contract ChainStatement  is Ownable{

    ISemaphore public semaphore;

    uint256 public groupId;

    address RELAYER_ADDRESS;
    // identity commitment to addresses of user
    mapping(uint256 => address []) userAddresses;
    // identity commitment to time window 
    mapping(uint256 => uint256) claimWindow;
    // address registered check
    mapping(address => bool) addressRegistered;
    // identity registered check
    mapping(uint256 => bool) identityRegistered;

    uint256 TIME_WINDOW = 2 minutes;

    // modifier
    modifier onlyRelayer(){
        // only Relayer can call the function
        // require(msg.sender == RELAYER_ADDRESS,"should be address from relayer");
        require(msg.sender ==RELAYER_ADDRESS,"should be address from relayer");
        _;
    }

    function setRelayer(address addr) external onlyOwner{
        RELAYER_ADDRESS= addr;
    }
    // generate group
    constructor(address semaphoreAddress,address relay, uint256 _groupId) {
        semaphore = ISemaphore(semaphoreAddress);
        groupId = _groupId;
        RELAYER_ADDRESS = relay;

        semaphore.createGroup(groupId, 20, 0, address(this));
    }

    // add new user to group merkle tree
    function addNewUser(uint256 identityCommitment, address userAddr) external onlyRelayer {
        
        //Uncomment this
        // require(addressRegistered[userAddr] == false, "Address already in our protocol");
        if(!identityRegistered[identityCommitment]){
            // add new member
            semaphore.addMember(groupId, identityCommitment);
            identityRegistered[identityCommitment] = true;
        }
        userAddresses[identityCommitment].push(userAddr);
        addressRegistered[userAddr] = true;


        // emit NewUser(identityCommitment, username);
    }



/** 
signal: claimed record? like hash("ZH claimed x 1")
**/

    function claimStatement(
        uint256 identityCommitment,
        bytes32 signal,
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public onlyRelayer{
        // claimWindow[identityCommitment] = block.timestamp + TIME_WINDOW;
        semaphore.verifyProof(groupId, merkleTreeRoot, signal, nullifierHash, groupId, proof);
    }

    function getAddresses(uint256 identityCommitment) public view onlyRelayer returns (address[] memory){
        require(block.timestamp <= claimWindow[identityCommitment] , "should wait for more than 2 minutes to claim the statement!");
        return userAddresses[identityCommitment];
    }
    function getTimeStamp(uint256 identityCommitment) external view returns(uint256, uint256){
        return  (block.timestamp,claimWindow[identityCommitment]);
    }
}