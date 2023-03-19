// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vec8x32.sol";

contract Vec8x32Test is Test {
    // any(v, x) is true if v[i] = x and v[j] = 0 for all j != i
    function test_any_1(uint8 x, uint256 i) public {
        x = uint8(bound(x, 1, 255));
        i = bound(i, 0, 31);
        Vec8x32 v = Vec8x32.wrap(bytes32(uint256(x)) << (i * 8));
        assertTrue(any(v, x));
    }

    // any(v, x) is true if v[i] = x, v[j] = y, and v[k] = 0 for all other k
    function test_any_2(uint8 x, uint8 y, uint256 i, uint256 j) public {
        x = uint8(bound(x, 1, 255));
        i = bound(i, 0, 31);
        j = bound(j, 0, 31);
        vm.assume(i != j);
        Vec8x32 v = Vec8x32.wrap(
            (bytes32(uint256(x)) << (i * 8)) |
            (bytes32(uint256(y)) << (j * 8))
        );
        assertTrue(any(v, x));
    }

    // any(v, x) is false if v[i] = y != x, v[j] = z != x, and v[k] = 0 for all other k
    function test_any_3(uint8 x, uint8 y, uint8 z, uint256 i, uint256 j) public {
        x = uint8(bound(x, 1, 255));
        vm.assume(y != x && z != x);
        i = bound(i, 0, 30);
        j = bound(j, i + 1, 31);
        Vec8x32 v = Vec8x32.wrap(
            (bytes32(uint256(y)) << (i * 8)) |
            (bytes32(uint256(z)) << (j * 8))
        );
        assertFalse(any(v, x));
    }

    function test_put_0() public {
        Vec8x32 v1 = embed(0, 0xab);
        assertEq(
            Vec8x32.unwrap(v1),
            hex"00000000000000000000000000000000000000000000000000000000000000ab"
        );

        Vec8x32 v2 = embed(31, 0xcd);
        assertEq(
            Vec8x32.unwrap(v2),
            hex"cd00000000000000000000000000000000000000000000000000000000000000"
        );

        Vec8x32 v3 = embed(32, 0xde);
        assertEq(
            Vec8x32.unwrap(v3),
            hex"00000000000000000000000000000000000000000000000000000000000000de"
        );

        Vec8x32 v4 = embed(0, 0x00);
        assertEq(
            Vec8x32.unwrap(v4),
            hex"0000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    function test_put_pluck(uint8 x, uint256 i) public {
        assertEq(pluck(embed(i, x), i), x);
    }

    function test_add_0(uint8 x, uint8 y, uint256 i) public {
        Vec8x32 xs = embed(i, x);
        Vec8x32 ys = embed(i, y);

        Vec8x32 zs = xs + ys;

        uint8 z = pluck(zs, i);

        unchecked {
            assertEq(z, x + y);
        }
    }

    function test_add_1(uint8[2] calldata x, uint8[2] calldata y, uint256[2] memory i) public {
        i[0] = bound(i[0], 0, 30);
        i[1] = bound(i[1], i[0] + 1, 31);

        Vec8x32 xs = embed(i[0], x[0]) | embed(i[1], x[1]);
        Vec8x32 ys = embed(i[0], y[0]) | embed(i[1], y[1]);

        Vec8x32 zs = xs + ys;

        uint8 z0 = pluck(zs, i[0]);
        uint8 z1 = pluck(zs, i[1]);

        unchecked {
            assertEq(z0, x[0] + y[0]);
            assertEq(z1, x[1] + y[1]);
        }
    }

    function test_sub_0(uint8 x, uint8 y, uint256 i) public {
        Vec8x32 xs = embed(i, x);
        Vec8x32 ys = embed(i, y);

        Vec8x32 zs = xs - ys;

        uint8 z = pluck(zs, i);

        unchecked {
            assertEq(z, x - y);
        }
    }

    function test_sub_1(uint8[2] calldata x, uint8[2] calldata y, uint256[2] memory i) public {
        i[0] = bound(i[0], 0, 30);
        i[1] = bound(i[1], i[0] + 1, 31);

        Vec8x32 xs = embed(i[0], x[0]) | embed(i[1], x[1]);
        Vec8x32 ys = embed(i[0], y[0]) | embed(i[1], y[1]);

        Vec8x32 zs = xs - ys;

        uint8 z0 = pluck(zs, i[0]);
        uint8 z1 = pluck(zs, i[1]);

        unchecked {
            assertEq(z0, x[0] - y[0]);
            assertEq(z1, x[1] - y[1]);
        }
    }

}