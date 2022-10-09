pragma solidity ^0.8.4;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
struct Station {
    uint256 pricePerHour;
    string location;
    address owner;
    bytes3[8] availability;
    bool isActive;
}

contract JomEV is Ownable{

    using Counters for Counters.Counter; 
    using SafeMath for uint256;

    event UserJoined(address userAddr);
    event ProviderJoined(address providerAddr);
    event BookingSubmited( uint256 chargingPointIndex,uint256 connectorIndex, uint256 fee, uint256 day, bytes3 bookingSlot);
    event StationAdded(uint256 chargingPointId, uint256 connectorIndex, uint256 index, string cid, uint256 price);
    event ChargingPointAdded(uint256 index, string cid, uint256 price, uint256 amountStaked);
    event ConnectorDesactivated(uint256 charginPointIndex, uint256 connectorIndex);

    mapping(address => bool) public isMember;
    mapping(address => bool) public isProvider;
    mapping(uint256 => Station) public stationsMap;
    mapping(uint256 => uint256) public station_time_lower_bound;
    mapping(address => mapping (address => uint256)) public stakes;
    mapping (address => bool) public isAcceptedPayment;
    mapping(uint256 => mapping(uint256 => uint256)) public ChargingPointToStation;
    mapping(uint256 => uint256) public StationCounterInChargingPoint;

    uint256 private TIMESTAMP_PER_DAY = 86400;
    uint256 internal contract_time_lower_bound;
    Counters.Counter public stationIDs;
    Counters.Counter public bookingIDs;
    Counters.Counter public ChargingPointIDs;
    constructor () {
        contract_time_lower_bound = block.timestamp;
    }
    modifier onlyUser() {
        require(isMember[msg.sender], "This Feature is only for users");
        _;
    }
    modifier onlyProvider() {
        require(isProvider[msg.sender], "To become a provider you need to be a user of JomEV");
        _;
    }

    //dummy function for now, we will use worldcoin to upgrade this
    function joinAsUser() external {
        //worldcoin verification
        isMember[msg.sender] = true;
        emit UserJoined(msg.sender);
    } 
    function joinAsProvider() external onlyUser {
        isProvider[msg.sender] = true;
        emit ProviderJoined(msg.sender);
    }
    function addChargingPoint ( uint256 _pricePerHour, string calldata cid, address tokenAddr, uint256 nConnectors) external onlyProvider {
        require(isAcceptedPayment[tokenAddr],"this token is not allowed");
        uint256 amountToTransfer = _pricePerHour.mul(24).mul(7).mul(nConnectors);
        IERC20(tokenAddr).transferFrom(msg.sender, address(this),amountToTransfer);
        stakes[tokenAddr][msg.sender] += amountToTransfer;

        ChargingPointIDs.increment();
        uint256 currChargingPointCount = ChargingPointIDs.current();
        for(uint256 i=0; i<nConnectors ; i++){
            _addStation(_pricePerHour, cid, currChargingPointCount);
        }
        emit ChargingPointAdded(stationIDs.current(), cid, _pricePerHour, amountToTransfer);
    }
    /**
    ** @dev 
    ** @note  
        pricePerHour : price x hour of current station
        location : must be passed in coordinates or other relevant way
        tokenAddr : token which is used to perform the transaction , must be an approved token
    **/
    function _addStation(uint256 _pricePerHour, string calldata location, uint256 chargingPointId) internal  {
        stationIDs.increment();
        Station memory newStation = Station(_pricePerHour, location, msg.sender, [
            bytes3(0),bytes3(0),bytes3(0),bytes3(0),bytes3(0),bytes3(0),bytes3(0),bytes3(0)
        ],true);
        station_time_lower_bound[stationIDs.current()] = contract_time_lower_bound;
        stationsMap[stationIDs.current()] = newStation;
        StationCounterInChargingPoint[chargingPointId]++;
        ChargingPointToStation[chargingPointId][StationCounterInChargingPoint[chargingPointId]] = stationIDs.current();
        emit StationAdded(chargingPointId, StationCounterInChargingPoint[chargingPointId], stationIDs.current(), location, _pricePerHour);
    }
    /**
    ** @dev 
    ** @note  
        index : index of the station ( starts from 1
        day : index of day starting from today. if today is 15 and we want for 16 we must write 1, 0 is not allowed
        time : pass in bytes 24 slots ( hrs )
                i.e: 0010 0001 0000 0000 => we book for hours 3 and 8
                parse into hex : 0x2100 => this is the input
        tokenAddr : token which is used to perform the transaction , must be an approved token

    **/
    function bookStation(uint256 chargingPointId, uint256 connectorIndex, uint256 day, bytes3 time, address tokenAddr) external  onlyUser{

        bookingIDs.increment();
        uint256 index = ChargingPointToStation[chargingPointId][connectorIndex];
        require (index <= stationIDs.current() && index > 0,"index for booking not allowed");
        require (time != bytes3(0) , "new schedule cannot be empty");
        Station memory selectedStation = stationsMap[index];
        require(selectedStation.isActive,"Current Station is not active");

        //perform payment
        uint256 amountRequired = selectedStation.pricePerHour;
        require(isAcceptedPayment[tokenAddr],"this token is not accepted");
        IERC20(tokenAddr).transferFrom(msg.sender, address(this) , amountRequired);

        uint256 startPointer = day;
        uint256 diff = block.timestamp - station_time_lower_bound[index];
        if( diff > TIMESTAMP_PER_DAY){
            uint256 quotient = (diff).div(TIMESTAMP_PER_DAY);
            uint256 n = quotient;
            if(quotient>=7){
                n = 7;
                station_time_lower_bound[index]+=(TIMESTAMP_PER_DAY*(quotient.div(7)));
            }
            for ( uint8 i = 1 ; i <= n ; i++){
                startPointer+=1;
                selectedStation.availability[i] = bytes3(0);
            }
        }
        startPointer = startPointer % 7;
        bytes3 checkOverlap = time & selectedStation.availability[startPointer];
        require(checkOverlap == bytes3(0) , "new schedule overlaps");
        selectedStation.availability[startPointer] = time | selectedStation.availability[startPointer];
        stationsMap[index] = selectedStation;

        emit BookingSubmited(chargingPointId,connectorIndex,amountRequired, startPointer, time);
    }

    function desactivateConnector(uint256 chargingPointIndex, uint256 connectorIndex) external onlyProvider {
        require(stationsMap[ChargingPointToStation[chargingPointIndex][connectorIndex]].owner == msg.sender , "Caller is not the owner of the station");
        stationsMap[ChargingPointToStation[chargingPointIndex][connectorIndex]].isActive = false;
        
        emit ConnectorDesactivated(chargingPointIndex, connectorIndex);
    }
    function addAcceptedPayment(address tokenAddr) external onlyOwner {
        isAcceptedPayment[tokenAddr]= true;
    }
    //readers
    function getStation(uint256 index) external view returns(Station memory station){
        return (stationsMap[index]);
    }

    function getConnector(uint256 chargingPointID , uint256 connectorID) external view returns (Station memory station){
        return (stationsMap[ChargingPointToStation[chargingPointID][connectorID]]);
    }

    /** 
    **  @dev dummy call for usage in the testing
    **/
    function getBlockTimestamp() external view returns(uint256) {
        return(block.timestamp);
    }
}