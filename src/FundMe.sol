//get funds from user
// withdraw funds 
// set a minimum funding value in USD 


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter } from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    //type decleration
    using PriceConverter for uint256;  

    //State Variable
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    address[] public s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    //modifier
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed) {
       i_owner = msg.sender;
       s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didint send enough!");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
         //reset the funders number 
        for (uint256 i = 0; i < s_funders.length; i++) {
           address funder = s_funders[i];
           s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
          // Transfer the entire balance of the contract to the owner
        // payable(msg.sender).transfer(address(this).balance); this is a method using transfer to withdraw 
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

     function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory, sorry!
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    // receive() external payable {
    //     fund();
    // }
    // fallback() external payable {
    //     fund();
    //  }


     /**
    * view / pure function (Getters)
    */
   
       function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }


    function _onlyOwner() internal view {
        require(msg.sender == i_owner, "sender is not owner");
    }

    function getAddressToAmountFunded(
        address fundingAddress
        ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }   

    function getOwner() external view returns (address) {
        return i_owner;
    }
     function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

}



















// contract FundMe {
//      using PriceConverter for uint256;

//      error NotOwner();

//      uint256 public constant MINIMUM_USD = 50 * 1e18;

//      address[] public funders;
//      mapping(address => uint256) public addressToAmountFunded;

//      address public immutable i_owner;
//      constructor(){
//           i_owner = msg.sender;
//      }

//      function Fund() public payable{
//           //1e18 ... want to be able to send minimum fundz 
//           //require makes every function call base on its success 
//             require(msg.value.getConversionRate() >= MINIMUM_USD , "didnt send enough");
//             funders.push(msg.sender);
//             addressToAmountFunded[msg.sender] = msg.value;
//        }

//      function withdraw() public onlyOwner {
//           for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
//                address funder = funders[funderIndex];
//                addressToAmountFunded[funder] = 0;
//      }
//      funders = new address[] (0);
//      (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
//      require(callSuccess, "call failed");
//     }

//     modifier onlyOwner {
//           // require(msg.sender == i_owner, "sender is not owner!");
//           if (msg.sender != i_owner) {revert NotOwner();}
//           _;
//     }  

//     receive() external payable {
//      Fund();
//     }
//     fallback() external payable {
//      Fund();
//     }
//}