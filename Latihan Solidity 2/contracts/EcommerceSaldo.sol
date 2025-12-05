// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract EcommerceSaldo {
    uint public nextProductId;
    uint public nextUserId;

    struct Product {
        uint id;
        string name;
        uint price;
        address owner;
        bool isSold;
    }

    struct User {
        uint id;
        string name;
        uint balance;
        bool isRegistered;
    }

    Product[] public productList;

    mapping(address => User) public users;

    function register(string memory _name) public {
        require(users[msg.sender].isRegistered == false, "USER SUDAH TERDAFTAR");

        users[msg.sender] = User(nextUserId, _name, 0, true);

        nextUserId++;
    }

    function topUp(uint amount) public {
        require(amount > 0, "JUMLAH TIDAK BOLEH KURANG DARI 1");
        require(users[msg.sender].isRegistered == true, "USER BELUM TERDAFTAR");

        users[msg.sender].balance += amount;
    }

    function addProduct(string memory _name, uint _price) public {
        require(users[msg.sender].isRegistered == true, "USER BELUM TERDAFTAR");
        require(_price > 0, "HARGA TIDAK VALID");

        Product memory newProduct = Product(nextProductId, _name, _price, msg.sender, false);

        productList.push(newProduct);

        nextProductId++;
    }

    function buyProduct(uint id) public {
        require(id < productList.length, "PRODUK TIDAK DITEMUKAN");
        require(users[msg.sender].isRegistered, "USER BELUM TERDAFTAR");
        require(msg.sender != productList[id].owner, "TIDAK BISA MEMBELI PRODUK SENDIRI");
        require(users[msg.sender].balance >= productList[id].price, "SALDO ANDA KURANG");
        require(productList[id].isSold == false, "PRODUK SUDAH TERJUAL");

        address ownerProduct = productList[id].owner;

        users[msg.sender].balance -= productList[id].price;
        users[ownerProduct].balance += productList[id].price;   

        productList[id].isSold = true; 
    }

    function getProduct(uint _id) public view returns(Product memory) {
        require(_id < productList.length, "PRODUK TIDAK DITEMUKAN");

        return productList[_id];
    }

    function getMyBalance() public view returns(uint _balance) {
        return users[msg.sender].balance;
    }

    function withdraw() public {
        users[msg.sender].balance = 0;
    }
} 

