pragma solidity ^0.8.7;

contract KYC {

    struct Customer {
        string userName;
        string data;
        address bank;
        bool kycStatus ;
        uint8 upVotes;
        uint8 downVotes;
    }

    struct Bank {
        string name;
        address bankAddress;
        string regNumber;
        uint256 kycCount;
        bool isAllowedToVote;
        uint8 complaintsReported;
    }

    struct KYCRequest {
        string userName;
        address bankAddress;
        string data;
    }

    mapping(string => Customer) customers;
    mapping(address => Bank) banks;
    mapping(string => KYCRequest) kycRequests;

    uint256 totalBanks;
    address admin;

    constructor(){
        admin = msg.sender;
    }


    modifier isAdmin {
        require(msg.sender == admin, "This action can only be performed by admin.");
        _;
    }


    function addKYCRequest(string memory _userName, string memory _data) public {
        require(kycRequests[_userName].bankAddress == address(0), "Users KYC request already exists.");

        kycRequests[_userName].userName = _userName;
        kycRequests[_userName].bankAddress = msg.sender;
        kycRequests[_userName].data = _data;
    }


    function removeKYCRequest(string memory _userName) public{
        require(kycRequests[_userName].bankAddress != address(0), "Request not found");

        delete kycRequests[_userName];
    }

    function addCustomer(string memory _userName, string memory _data) public {
        require(customers[_userName].bank == address(0), "Customer already exists");

        customers[_userName].userName = _userName;
        customers[_userName].data = _data;
        customers[_userName].bank = msg.sender;
        customers[_userName].upVotes = 0;
    }


    function modifyCustomer(string memory _userName, string memory _updatedData) public {
        require(customers[_userName].bank != address(0), "Customer not found");

        customers[_userName].data = _updatedData;
    }


    function viewCustomerData(string memory _userName) public view returns (string memory, string memory, address){
        require(customers[_userName].bank != address(0), "Customer not found");

        return (customers[_userName].userName, customers[_userName].data, customers[_userName].bank);
    }

    function upVoteCustomer(string memory _userName) public {
        require(customers[_userName].bank != address(0), "Customer not found");
        customers[_userName].upVotes += 1;


        if(totalBanks >=5){
            uint256 percentage = (customers[_userName].downVotes / totalBanks) * 100;
            customers[_userName].kycStatus = percentage >=33;
            
        }else{
            customers[_userName].kycStatus = customers[_userName].upVotes > customers[_userName].downVotes;
        }

    }
    
    function downVoteCustomer(string memory _userName) public {
        require(customers[_userName].bank != address(0), "Customer not found");
        customers[_userName].upVotes -= 1;

        if(totalBanks >=5){
            uint256 percentage = (customers[_userName].downVotes / totalBanks) * 100;
            customers[_userName].kycStatus = percentage >=33;
            
        }else{
            customers[_userName].kycStatus = customers[_userName].upVotes > customers[_userName].downVotes;
        }

    }

    function getBankComplaints(address _bankAddress ) public view returns(uint8){
        require(banks[_bankAddress].bankAddress != address(0), "Bank not found");

        return banks[_bankAddress].complaintsReported;
    }

    function viewBankDetails(address _bankAddress) public view returns (Bank memory){
        require(banks[_bankAddress].bankAddress != address(0), "Bank not found");
        return banks[_bankAddress];
    }

    function reportBank(address _bankAddress) public {
        require(banks[_bankAddress].bankAddress != address(0), "Bank not found");

        banks[_bankAddress].complaintsReported +=1;

        uint256 percentage = (banks[_bankAddress].complaintsReported / totalBanks) * 100;

        if(percentage >= 33){
                banks[_bankAddress].isAllowedToVote = false;
        }

    }


    // ADMIN FUNCTIONALITIES FROM HERE..............

    
    // Add bank to the network
    function addBank(string memory _name, address _bankAddress, string memory _registrationNumber) public isAdmin {
        banks[_bankAddress].name = _name;
        banks[_bankAddress].bankAddress = _bankAddress;
        banks[_bankAddress].regNumber = _registrationNumber;
        banks[_bankAddress].kycCount = 0;
        banks[_bankAddress].isAllowedToVote = true;
        banks[_bankAddress].complaintsReported = 0;

        totalBanks +=1;
    }


    // To change voting status of bank
    function changeBankVotingEligibility(address _bankAddress, bool _status) public isAdmin {
            require(banks[_bankAddress].bankAddress != address(0), "Bank not found");

            banks[_bankAddress].isAllowedToVote = _status;
    }

    // remove bank from the network
    function removeBank(address _bankAddress) public isAdmin {

        require(banks[_bankAddress].bankAddress != address(0), "Bank not found");

        delete banks[_bankAddress];
    }


}
