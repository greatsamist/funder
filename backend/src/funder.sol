// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;



/*
  * @title Funder logic for raising funds .
  * @notice  web3 version of crowdFundMe.
  */

contract Funder {

  
     /*******************sTATE VARIABLES************************/
     address govToken;
     address govVoting;
     


  /*******************STRUCT************************/
    struct FundProps{
        string Purpose;
        uint256 amount;
        uint256 amountGenerared;
        bool status;
    }

  /*******************MAPPING************************/

    mapping (address => FundProps) public fundsprosps;
    mapping (address => uint) public investors;
    

    mapping (address => uint) RequestStatus;


  /*******************EVENTS************************/
    event Request(address owner, string purpose, uint amount);
    event donate(address owner, address beneficiary, uint amount);
    event withdraw(address owner, uint amount, bool status);



     /*******************CONSTRUCTOR************************/  
     constructor(address _token, address _govVoting){
        govToken = _token;
        govVoting = _govVoting;
        
     }
     
   



     

     /*******************FUNCTIONS************************/  
     /**
     * @notice Construct the FundsProperty for a benficiary
     * @param _purpose The Purpose of the fund requested for
     * @param _amount The amount needed to fulfill the purpose
     */

   function requestFund(string memory _purpose, uint _amount) external {
        FundProps storage FP =  fundsprosps[msg.sender];
        FP.amount = _amount;
        FP.Purpose = _purpose;
        emit Request(msg.sender, _purpose, _amount);
    }

    function setStatus(address beneficiary) external returns(bool) {
      require(msg.sender == govVoting);
        FundProps storage FP = fundsprosps[beneficiary];
        FP.status = true;
        return FP.status;
    }

    

     /**
     * @notice Donate Funds for a beneficiary
     * @param beneficiary The spender of the funds being donated
     */

    function donateFunds(address beneficiary) external payable{
        FundProps storage FP = fundsprosps[beneficiary];
        require(msg.value != 0, "you can't transfer 0 value");
        require(FP.status == true, "this donation is no longer available");
        require(FP.amountGenerared <= FP.amount, "target reachead for this fund");
        FP.amountGenerared += msg.value;
        investors[msg.sender]+= msg.value;
        emit donate(msg.sender, beneficiary, msg.value); 
    } 

     /**
     * @notice Withdraw all money contributed on behalf of the msg.sender;
     */

    function withdrawAll() external payable{
        FundProps storage FP = fundsprosps[msg.sender];
        require(FP.status == true, "No request for fund made");
        require(FP.amountGenerared != 0, "NO funds raised for you");
        uint value = FP.amountGenerared;
        FP.amountGenerared = 0;
        FP.status = false;
        payable(msg.sender).transfer(value);
        emit withdraw(msg.sender, value, FP.status);
    }

     /**
     * @notice Construct an interest rate model
     * @param amount The amount to withdraw from the total amount generated
     */
    function withdrawPart(uint amount) external payable {
        FundProps storage FP = fundsprosps[msg.sender];
        require(FP.status == true, "No request for fund made");
        require(FP.amountGenerared  >= amount, "insufficient funds");
        FP.amountGenerared -= amount;
        FP.amount -= amount;
        payable(msg.sender).transfer(amount);
        FP.amountGenerared == 0? FP.status = false: FP.status = true;
        emit withdraw(msg.sender, amount, FP.status);
    }



     /*******************VIEW FUNCTIONS************************/  



     function getBeneficiaryStatus(address beneficiary)  public view returns(bool status){
        FundProps storage FP = fundsprosps[beneficiary];
        status = FP.status;
      
  }
     /**
     * @notice check the amount generated by a beneficiary
     * @return return the amount generated
     **/
    function checkBalanceOf(address owner) external view returns (uint256){
        return fundsprosps[owner].amountGenerared;
    }

    function checkBalanceOfContract() external view returns(uint256){
        return address(this).balance;
    }

    function getBeneficiaryProps(address beneficiary) external view returns(FundProps memory props){
        props = fundsprosps[beneficiary];
        props.Purpose = fundsprosps[beneficiary].Purpose;
        props.amount = fundsprosps[beneficiary].amount;
        props.amountGenerared = fundsprosps[beneficiary].amountGenerared;
        props.status = fundsprosps[beneficiary].status;
    }
   

}
