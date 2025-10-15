// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ZKPMerkleNFT
 * @notice Mint NFTs only for verified users proving membership via a Merkle proof.
 * - No imports, no constructor.
 * - initialize(...) must be called once to set admin & merkle root.
 * - Leaves are keccak256(abi.encodePacked(address)).
 */
contract ZKPMerkleNFT {
    string public name = "ZKP Verified NFT";
    string public symbol = "ZKPV";

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;

    bytes32 public merkleRoot;
    address public admin;
    bool private initialized;
    mapping(address => bool) public hasMinted;
    uint256 private _nextTokenId = 1;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event MerkleRootUpdated(bytes32 oldRoot, bytes32 newRoot);
    event Initialized(address indexed admin, bytes32 merkleRoot);

    function initialize(bytes32 _merkleRoot) external {
        require(!initialized, "Already initialized");
        initialized = true;
        admin = msg.sender;
        merkleRoot = _merkleRoot;
        emit Initialized(admin, merkleRoot);
    }

    function updateMerkleRoot(bytes32 _newRoot) external {
        require(msg.sender == admin, "Only admin");
        bytes32 old = merkleRoot;
        merkleRoot = _newRoot;
        emit MerkleRootUpdated(old, _newRoot);
    }

    function mint(bytes32[] calldata proof, string calldata tokenUri) external returns (uint256) {
        require(initialized, "Not initialized");
        require(!hasMinted[msg.sender], "Already minted");
        require(merkleRoot != bytes32(0), "Merkle root not set");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(_verifyMerkleProof(leaf, proof, merkleRoot), "Invalid proof");

        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);
        _tokenURIs[tokenId] = tokenUri;
        hasMinted[msg.sender] = true;
        return tokenId;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(to != owner, "Approval to current owner");
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "Not authorized");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Transfer to zero");

        _tokenApprovals[tokenId] = address(0);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "Mint to zero");
        require(_owners[tokenId] == address(0), "Token already minted");
        _owners[tokenId] = to;
        _balances[to] += 1;
        emit Transfer(address(0), to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = _owners[tokenId];
        return (spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender]);
    }

    function _verifyMerkleProof(bytes32 leaf, bytes32[] calldata proof, bytes32 root) internal pure returns (bool) {
        bytes32 computed = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 sibling = proof[i];
            if (computed <= sibling) {
                computed = keccak256(abi.encodePacked(computed, sibling));
            } else {
                computed = keccak256(abi.encodePacked(sibling, computed));
            }
        }
        return computed == root;
    }

    function transferAdmin(address newAdmin) external {
        require(msg.sender == admin, "Only admin");
        require(newAdmin != address(0), "Zero address");
        admin = newAdmin;
    }

    function adminMint(address to, string calldata tokenUri) external returns (uint256) {
        require(msg.sender == admin, "Only admin");
        uint256 tokenId = _nextTokenId++;
        _mint(to, tokenId);
        _tokenURIs[tokenId] = tokenUri;
        return tokenId;
    }

    function isAddressVerified(address who, bytes32[] calldata proof) external view returns (bool) {
        if (!initialized || merkleRoot == bytes32(0)) return false;
        bytes32 leaf = keccak256(abi.encodePacked(who));
        return _verifyMerkleProof(leaf, proof, merkleRoot);
    }
}
