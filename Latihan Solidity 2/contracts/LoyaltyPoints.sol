// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

interface ILoyalty {
    function addPoints(address customer, uint points) external;
    function redeemPoints(address customer, uint points) external;
    function getPoints(address customer) external view returns(string memory, uint);
}

contract LoyaltyPoints is ILoyalty {

    struct Customer {
        uint points;  
        string tier;  
    }

    function calculateTier(uint points) public pure returns (string memory) {
        if(points <= 99) {
            return "Bronze";
        } else if (points >= 100 && points < 500) {
            return "Silver";
        } else {
            return "Gold";
        }
    }

    mapping(address => Customer) public customers;

    function addPoints( address customer, uint points) external override {
        customers[customer].points += points;
        customers[customer].tier = calculateTier(customers[customer].points);
    }

    function redeemPoints(address customer, uint points) public override {
        require(customers[customer].points >= points, "NOT ENOUGH POINTS");

        customers[customer].points -= points;
        customers[customer].tier = calculateTier(customers[customer].points);
    }

    function getPoints(address customer) public view override returns(string memory, uint) {
        require(customers[customer].points >= 0, "POINTS NOT FOUND");

        Customer memory customerData = customers[customer];
        return (customerData.tier, customerData.points);
    }
}