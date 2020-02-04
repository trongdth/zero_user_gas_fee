pragma solidity ^0.5;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Provable is ERC20 {

    mapping(address => mapping(bytes32 => bool)) played;
    mapping(address => uint) nonce;

    // First 4 bytes of keccak-256 hash of "approve"
    bytes4 methodWord = 0x095ea7b3;

    function getNonce() public view returns (uint) {
        return nonce[msg.sender];
    }

    function provable_approve(
        bytes32 hash,
        bytes32 r,
        bytes32 s,
        uint8 v,
        address to,
        uint value
    ) public
    {
        address signer = getSigner(
            hash,
            r,
            s,
            v,
            to,
            value
        );
        require(signer != address(0));

        // Execute the original approve function
        _approve(signer, to, value);
        emit Approval(signer, to, value);

        // Nonce increment + reply attack protection
        nonce[signer] += 1;
        played[signer][getProof(signer, to, value)] = true;
    }

    function checkProvableApprove(
        bytes32 hash,
        bytes32 r,
        bytes32 s,
        uint8 v,
        address to,
        uint value
    ) public view returns (bool)
    {
        address signer = getSigner(
            hash,
            r,
            s,
            v,
            to,
            value
        );

        return signer != address(0);
    }

    function getSigner(
        bytes32 hash,
        bytes32 r,
        bytes32 s,
        uint8 v,
        address to,
        uint value
    ) private view returns (address)
    {
        require(to != address(0));

        address signer = ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),
            v,
            r,
            s
        );

        bytes32 proof = getProof(signer, to, value);

        if (proof != hash) {return address(0);}
        if (played[signer][proof] == true) {return address(0);}

        return signer;
    }

    function getProof(address signer, address to, uint value) private view returns(bytes32) {
        uint nextNonce = nonce[signer] + 1;
        bytes32 proof = keccak256(
            abi.encodePacked(
                methodWord,
                to,
                value,
                address(this),
                nextNonce
            )
        );

        return proof;
    }
}
