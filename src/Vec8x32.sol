// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

type Vec8x32 is bytes32;

using {add as +, or as |, and as &} for Vec8x32 global;

bytes32 constant V01x32 = hex"0101010101010101010101010101010101010101010101010101010101010101";

function broadcast(uint8 x) pure returns (Vec8x32) {
    return Vec8x32.wrap(bytes32(x * uint256(V01x32)));
}

function any(Vec8x32 xs, uint8 y) pure returns (bool) {
    bytes32 ys = bytes32(y * uint256(V01x32));
    bytes32 t = Vec8x32.unwrap(xs);
    t ^= ~ys;
    t &= t >> 4;  // 01234567 & 45670123 = ____abcd
    t &= t >> 2;  // ____abcd & ______ab = ______ef
    t &= t >> 1;  // ______ef & _______e = _______z, z = &(0,1,2,3,4,5,6,7)
    t &= V01x32;  // _______z & 00000001 = 0000000z
    return t != 0;
}

function embed(uint256 i, uint8 x) pure returns (Vec8x32) {
    unchecked {
        uint256 b = 1 << ((i % 32) << 3);
        uint256 t = uint256(x) * b;
        return Vec8x32.wrap(bytes32(t));
    }
}

function put(Vec8x32 xs, uint8 x, uint256 i) pure returns (Vec8x32) {
    unchecked {
        uint256 s = (i % 32) << 3;
        uint256 b = 1 << s;
        bytes32 t = Vec8x32.unwrap(xs);
        t &= ~(bytes32(uint256(0xff)) << s);
        t |= bytes32(uint256(x) * b);
        return Vec8x32.wrap(t);
    }
}

function pluck(Vec8x32 xs, uint256 i) pure returns (uint8 x) {
    unchecked {
        uint256 s = (i % 32) << 3;
        bytes32 t = Vec8x32.unwrap(xs);
        t >>= s;
        t &= bytes32(uint256(0xff));
        // avoid solidity cleanup
        assembly { x := t }
    }
}

function fill(uint256 n, uint8 x) pure returns (Vec8x32) {
    unchecked {
        bytes32 b = V01x32 >> (256 - ((n % 32) << 3));
        uint256 t = x * uint256(b);
        return Vec8x32.wrap(bytes32(t));
    }
}

function add(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    unchecked {
        uint256 x = uint256(Vec8x32.unwrap(xs));
        uint256 y = uint256(Vec8x32.unwrap(ys));
        uint256 b7 = uint256(V01x32 << 7);
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

function or(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    return Vec8x32.wrap(Vec8x32.unwrap(xs) | Vec8x32.unwrap(ys));
}

function and(Vec8x32 xs, Vec8x32 ys) pure returns (Vec8x32) {
    return Vec8x32.wrap(Vec8x32.unwrap(xs) & Vec8x32.unwrap(ys));
}
