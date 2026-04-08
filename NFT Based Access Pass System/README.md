# NFT-Based Access Pass System

Sistem akses berbasis NFT ERC-721 yang memungkinkan admin membuat kartu akses dengan masa berlaku, opsi soulbound, pencabutan (revoke), dan kontrol akses bertingkat melalui kontrak gate.

## Fitur Utama

* ERC-721 access pass dengan metadata token
* Expiry per token (`tokenId -> expiry timestamp`)
* Soulbound opsional per token
* Mint oleh admin/owner
* Revoke/burn oleh admin/owner
* Perpanjangan expiry
* Gate untuk validasi akses berdasarkan kepemilikan, validitas token, dan tier resource
* Factory untuk membuat koleksi pass baru
* Unit test lengkap untuk mint, expiry, revoke, transfer, gate, dan tier logic

## Struktur Kontrak

### `contracts/AccessPassERC721.sol`

Kontrak NFT utama.

Tanggung jawab:

* mint token pass
* simpan expiry token
* blok transfer untuk token soulbound
* revoke/burn token
* set dan extend expiry
* tokenURI support
* emit event perubahan status penting

### `contracts/IAccessPass.sol`

Interface minimal untuk dibaca oleh `AccessGate`.

Tanggung jawab:

* expose fungsi `ownerOf`
* expose fungsi `isValid`
* expose fungsi lain yang dibutuhkan gate

### `contracts/AccessGate.sol`

Kontrak pengecek akses.

Tanggung jawab:

* cek apakah user adalah pemilik token
* cek token masih valid
* simpan mapping tier resource
* simpan tier token
* cek akses berdasarkan resource

### `contracts/PassFactory.sol`

Kontrak factory untuk membuat koleksi `AccessPassERC721` baru.

Tanggung jawab:

* deploy pass baru
* transfer ownership pass ke pembuat
* simpan daftar pass yang dibuat
* simpan daftar pass per creator

## Alur Sistem

1. Admin deploy `PassFactory`.
2. Creator memanggil `createPass()` untuk membuat koleksi pass baru.
3. Creator atau admin mint token pass melalui `AccessPassERC721`.
4. `AccessGate` membaca ownership dan validitas token.
5. Jika resource memakai tier, `AccessGate` membandingkan tier token dengan tier resource.

## API Singkat

### `AccessPassERC721`

* `mint(address to, uint64 expiry, bool soulbound, string uri) external onlyOwner returns (uint256)`
* `isValid(uint256 tokenId) public view returns (bool)`
* `revoke(uint256 tokenId) external onlyOwner onlyExisting(tokenId) nonReentrant`
* `setExpiry(uint256 tokenId, uint64 newExpiry) external onlyOwner onlyExisting(tokenId)`
* `extendExpiry(uint256 tokenId, uint64 extraSeconds) external onlyOwner onlyExisting(tokenId)`
* `tokenURI(uint256 tokenId) public view override returns (string memory)`

### `AccessGate`

* `setResourceTier(string resource, uint8 tier) external onlyOwner`
* `setTokenTier(uint256 tokenId, uint8 tier) external onlyOwner`
* `hasAccess(address user, uint256 tokenId) public view returns (bool)`
* `hasAccessForResource(address user, uint256 tokenId, string resource) public view returns (bool)`
* `getPass(address)` / `pass` getter via public state variable

### `PassFactory`

* `createPass(string name, string symbol, string baseURI) external returns (address)`
* `getPassesByCreator(address creator) external view returns (address[] memory)`
* `totalPasses() external view returns (uint256)`

## Catatan Keamanan dan Desain

* Gunakan `onlyOwner` untuk fungsi admin.
* `isValid()` harus mengembalikan boolean dan tidak boleh revert untuk token tidak ada.
* Soulbound hanya memblokir transfer normal, bukan mint atau burn.
* `revoke()` harus menghapus state token sebelum burn.
* Hindari loop besar di on-chain.
* Gunakan `.call` untuk transfer ETH bila ada fungsi withdraw.
* Untuk resource tier, string key valid tetapi mahal dan sensitif terhadap typo. Untuk produksi yang lebih rapih, `bytes32` lebih disarankan.
* `AccessGate` memakai `try/catch` agar token yang tidak ada atau sudah burn tidak membuat fungsi akses revert.

## Instalasi

```bash
npm install
```

Jika memakai OpenZeppelin dan Hardhat, pastikan dependensi berikut tersedia:

```bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @openzeppelin/contracts
```

## Menjalankan Test

```bash
npx hardhat test
```

Untuk melihat gas report:

```bash
REPORT_GAS=true npx hardhat test
```

## Deploy Lokal

1. Jalankan node lokal:

```bash
npx hardhat node
```

2. Deploy kontrak:

```bash
npx hardhat run scripts/deploy-local.js --network localhost
```

## Deploy Testnet

Pastikan konfigurasi network dan variabel environment sudah diisi.

```bash
npx hardhat run scripts/deploy-testnet.js --network <network-name>
```

## Contoh Alur Demo

1. Deploy `PassFactory`.
2. Buat koleksi baru dengan `createPass()`.
3. Mint pass untuk user.
4. Deploy `AccessGate` dengan address pass.
5. Set tier resource dan tier token.
6. Panggil `hasAccess()` dan `hasAccessForResource()` untuk memeriksa akses.

## Rencana Pengembangan Lanjutan

* Marketplace adapter untuk pembelian access pass
* Factory clone-based untuk menekan gas deploy
* Event indexing yang lebih kaya
* Frontend demo React + ethers.js
* Role-based access control menggunakan `AccessControl`

## Copyright

© 2026 Aldino Khalifah.