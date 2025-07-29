// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0;

interface IERC20 {
    function transfer(address recipient, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract LatihanInterface {
    function sendToken(address tokenAddress, address recipient, uint amount) public {
        IERC20 token = IERC20(tokenAddress);

        require(token.balanceOf(msg.sender) >= amount, "Not enough token balance");

        bool success = token.transfer(recipient, amount);
        require(success, "Token Transfer Failed");
    }
}