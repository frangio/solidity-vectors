// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

type Vec8x32 is bytes32;

using {add as +, sub as -, neg as -, or as |, and as &, xor as ^, not as ~, eq as ==} for Vec8x32 global;
using Vec8x32Methods for Vec8x32 global;

bytes32 constant B1x32 = hex"0101010101010101010101010101010101010101010101010101010101010101";

Vec8x32 constant V0x32 = Vec8x32.wrap(0);
Vec8x32 constant V1x32 = Vec8x32.wrap(B1x32);

library Vec8x32Methods {
    function any(Vec8x32 xs, uint8 y) internal pure returns (bool) {
        unchecked {
            bytes32 ys = bytes32(y * uint256(B1x32));
            bytes32 t = Vec8x32.unwrap(xs);
            t ^= ~ys;
            t &= t >> 4;  // 01234567 & 45670123 = ____abcd
            t &= t >> 2;  // ____abcd & ______ab = ______ef
            t &= t >> 1;  // ______ef & _______e = _______z, z = &(0,1,2,3,4,5,6,7)
            t &= B1x32;  // _______z & 00000001 = 0000000z
            return t != 0;
        }
    }

    function all(Vec8x32 xs, uint8 y) internal pure returns (bool) {
        unchecked {
            bytes32 ys = bytes32(y * uint256(B1x32));
            bytes32 t = Vec8x32.unwrap(xs);
            t ^= ys;
            t |= t >> 128;
            t |= t >> 64;
            t |= t >> 32;
            t |= t >> 16;
            t |= t >> 8;
            t |= t >> 4;
            t |= t >> 2;
            t |= t >> 1;
            return t == 0;
        }
    }

    function put(Vec8x32 xs, uint256 i, uint8 y) internal pure returns (Vec8x32) {
        unchecked {
            uint256 s = (31 - (i % 32)) << 3;
            bytes32 t = Vec8x32.unwrap(xs);
            t &= ~(bytes32(uint256(0xff)) << s);
            t |= bytes32(uint256(y) * (1 << s));
            return Vec8x32.wrap(t);
        }
    }

    function pluck(Vec8x32 xs, uint256 i) internal pure returns (uint8 x) {
        unchecked {
            bytes32 t = Vec8x32.unwrap(xs);
            t >>= (31 - (i % 32)) << 3;
            t &= bytes32(uint256(0xff));
            // avoid solidity cleanup
            assembly { x := t }
        }
    }
}

function broadcast8x32(uint8 x) pure returns (Vec8x32) {
    unchecked {
        return Vec8x32.wrap(bytes32(x * uint256(B1x32)));
    }
}

function embed8x32(uint256 i, uint8 x) pure returns (Vec8x32) {
    unchecked {
        uint256 b = 1 << ((31 - (i % 32)) << 3);
        uint256 t = uint256(x) * b;
        return Vec8x32.wrap(bytes32(t));
    }
}

function fill8x32(uint256 n, uint8 x) pure returns (Vec8x32) {
    unchecked {
        bytes32 b = B1x32 << ((32 - (n % 32)) << 3);
        uint256 t = x * uint256(b);
        return Vec8x32.wrap(bytes32(t));
    }
}

function add(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    unchecked {
        uint256 x = uint256(Vec8x32.unwrap(xs));
        uint256 y = uint256(Vec8x32.unwrap(ys));
        uint256 b7 = uint256(B1x32 << 7);
        uint256 x7 = x & b7;
        uint256 y7 = y & b7;

        x ^= x7;
        y ^= y7;

        uint256 r = x + y;
        uint256 r7 = x7 ^ y7;

        r ^= r7;

        return Vec8x32.wrap(bytes32(r));
    }
}

function add1(Vec8x32 xs) pure returns (Vec8x32) {
    unchecked {
        uint256 x = uint256(Vec8x32.unwrap(xs));
        uint256 b7 = uint256(B1x32 << 7);
        uint256 x7 = x & b7;

        x ^= x7;

        uint256 r = x + uint256(B1x32);

        r ^= x7;

        return Vec8x32.wrap(bytes32(r));
    }
}

function sub(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    return add1(xs + ~ys);
}

function neg(Vec8x32 xs) pure returns (Vec8x32) {
    return add1(~xs);
}

function or(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    return Vec8x32.wrap(Vec8x32.unwrap(xs) | Vec8x32.unwrap(ys));
}

function and(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    return Vec8x32.wrap(Vec8x32.unwrap(xs) & Vec8x32.unwrap(ys));
}

function xor(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    return Vec8x32.wrap(Vec8x32.unwrap(xs) ^ Vec8x32.unwrap(ys));
}

function not(Vec8x32 xs) pure returns (Vec8x32) {
    return Vec8x32.wrap(~Vec8x32.unwrap(xs));
}

function eq(Vec8x32 xs, Vec8x32 ys) pure returns (bool) {
    return Vec8x32.unwrap(xs) ==  Vec8x32.unwrap(ys);
}

function neq(Vec8x32 xs, Vec8x32 ys) pure returns (bool) {
    return Vec8x32.unwrap(xs) !=  Vec8x32.unwrap(ys);
}
