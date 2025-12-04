// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniMarketplace {

    address public admin;
    uint public nextId;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "KAMU BUKAN ADMIN");
        _;
    }

    event ProductAdded(uint id, string name, uint price);
    event ProductDeleted(uint id);
    event ProductPurchased(uint id, address buyer);

    struct Product {
        uint id;
        string name;
        uint price;
        address owner;
        bool isSold;
    }

    // Array untuk return daftar produk
    Product[] public productList;

    // Mapping untuk akses cepat berdasarkan ID
    mapping(uint => Product) public products;

    // ADMIN TAMBAH PRODUK
    function addProduct(string memory _name, uint _price) public onlyAdmin {
        require(_price > 0, "HARGA TIDAK VALID");

        Product memory newProd = Product({
            id: nextId,
            name: _name,
            price: _price,
            owner: admin,
            isSold: false
        });

        products[nextId] = newProd;
        productList.push(newProd);

        emit ProductAdded(nextId, _name, _price);

        nextId++;
    }

    // USER BELI PRODUK
    function buyProduct(uint _id) external payable {
        Product storage prod = products[_id];

        require(_id < nextId, "PRODUK TIDAK ADA");
        require(prod.isSold == false, "PRODUK SUDAH TERJUAL");
        require(msg.sender != prod.owner, "TIDAK BISA BELI PRODUK SENDIRI");
        require(msg.value == prod.price, "HARGA HARUS PAS");

        // Transfer dana ke owner lama
        payable(prod.owner).transfer(msg.value);

        // Update produk di mapping
        prod.owner = msg.sender;
        prod.isSold = true;

        // Update juga versi array-nya
        productList[_id].owner = msg.sender;
        productList[_id].isSold = true;

        emit ProductPurchased(_id, msg.sender);
    }

    // GET SEMUA PRODUK
    function getProducts() public view returns(Product[] memory) {
        return productList;
    }

    // ADMIN HAPUS PRODUK
    function deleteProduct(uint _id) public onlyAdmin {
        require(_id < nextId, "PRODUK TIDAK ADA");
        require(products[_id].isSold == false, "TIDAK BISA HAPUS PRODUK YG SUDAH TERJUAL");

        delete products[_id];
        delete productList[_id];

        emit ProductDeleted(_id);
    }
}
