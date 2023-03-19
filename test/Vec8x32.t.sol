// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vec8x32.sol";

contract Vec8x32Test is Test {
    function test_embed() public {
        Vec8x32 v1 = embed8x32(0, 0xab);
        assertEq(
            Vec8x32.unwrap(v1),
            hex"ab00000000000000000000000000000000000000000000000000000000000000"
        );

        Vec8x32 v2 = embed8x32(31, 0xcd);
        assertEq(
            Vec8x32.unwrap(v2),
            hex"00000000000000000000000000000000000000000000000000000000000000cd"
        );

        Vec8x32 v3 = embed8x32(32, 0xde);
        assertEq(
            Vec8x32.unwrap(v3),
            hex"de00000000000000000000000000000000000000000000000000000000000000"
        );

        Vec8x32 v4 = embed8x32(33, 0x11);
        assertEq(
            Vec8x32.unwrap(v4),
            hex"0011000000000000000000000000000000000000000000000000000000000000"
        );
    }

    function test_embed_pluck(uint8 x, uint256 i) public {
        assertEq(embed8x32(i, x).pluck(i), x);
    }

    function test_embed_put(uint8 x, uint256 i) public {
        assertTrue(embed8x32(i, x) == V0x32.put(i, x));
    }

    function test_put_pluck(uint8 x, uint256 i) public {
        assertEq(V0x32.put(i, x).pluck(i), x);
    }

    // any(v, x) is true if v[i] = x and v[j] = 0 for all j != i
    function test_any_1(uint8 x, uint256 i) public {
        x = uint8(bound(x, 1, 255));
        Vec8x32 v = embed8x32(i, x);
        assertTrue(v.any(x));
    }

    // any(v, x) is true if v[i] = x, v[j] = y, and v[k] = 0 for all other k
    function test_any_2(uint8 x, uint8 y, uint256 i, uint256 j) public {
        x = uint8(bound(x, 1, 255));
        i = bound(i, 0, 31);
        j = bound(j, 0, 31);
        vm.assume(i != j);
        Vec8x32 v = embed8x32(i, x) | embed8x32(j, y);
        assertTrue(v.any(x));
    }

    // any(v, x) is false if v[i] = y != x, v[j] = z != x, and v[k] = 0 for all other k
    function test_any_3(uint8 x, uint8 y, uint8 z, uint256 i, uint256 j) public {
        x = uint8(bound(x, 1, 255));
        vm.assume(y != x && z != x);
        i = bound(i, 0, 30);
        j = bound(j, i + 1, 31);
        Vec8x32 v = embed8x32(i, y) | embed8x32(j, z);
        assertFalse(v.any(x));
    }

    function test_all_0() public {
        Vec8x32 z = Vec8x32.wrap(0);
        assertTrue(z.all(0x00));

        Vec8x32 f = Vec8x32.wrap(bytes32(type(uint256).max));
        assertTrue(f.all(0xff));
    }

    function test_all_1(uint8 x) public {
        Vec8x32 v = broadcast8x32(x);
        assertTrue(v.all(x));
    }

    function test_all_2(uint8 x, uint8 y, uint256 i) public {
        vm.assume(x != y);
        Vec8x32 v = broadcast8x32(x).put(i, y);
        assertFalse(v.all(x));
    }

    function test_fill_0() public {
        Vec8x32 v1 = fill8x32(5, 0x01);
        assertEq(
            Vec8x32.unwrap(v1),
            hex"0101010101000000000000000000000000000000000000000000000000000000"
        );
    }

    function test_add_0(uint8 x, uint8 y, uint256 i) public {
        Vec8x32 xs = embed8x32(i, x);
        Vec8x32 ys = embed8x32(i, y);

        Vec8x32 zs = xs + ys;

        uint8 z = zs.pluck(i);

        unchecked {
            assertEq(z, x + y);
        }
    }

    function test_add_1(uint8[2] calldata x, uint8[2] calldata y, uint256[2] memory i) public {
        i[0] = bound(i[0], 0, 30);
        i[1] = bound(i[1], i[0] + 1, 31);

        Vec8x32 xs = embed8x32(i[0], x[0]) | embed8x32(i[1], x[1]);
        Vec8x32 ys = embed8x32(i[0], y[0]) | embed8x32(i[1], y[1]);

        Vec8x32 zs = xs + ys;

        uint8 z0 = zs.pluck(i[0]);
        uint8 z1 = zs.pluck(i[1]);

        unchecked {
            assertEq(z0, x[0] + y[0]);
            assertEq(z1, x[1] + y[1]);
        }
    }

    function test_add_2(uint8 x, uint8 y) public {
        Vec8x32 xs = broadcast8x32(x);
        Vec8x32 ys = broadcast8x32(y);

        Vec8x32 zs = xs + ys;

        unchecked {
            assertTrue(zs.all(x + y));
        }
    }

    function test_add_3(Vec8x32 xs, Vec8x32 ys, uint8 i) public {
        Vec8x32 zs = xs + ys;
        unchecked {
            assertEq(zs.pluck(i), xs.pluck(i) + ys.pluck(i));
        }
    }

    function test_sub_0(uint8 x, uint8 y, uint256 i) public {
        Vec8x32 xs = embed8x32(i, x);
        Vec8x32 ys = embed8x32(i, y);

        Vec8x32 zs = xs - ys;

        uint8 z = zs.pluck(i);

        unchecked {
            assertEq(z, x - y);
        }
    }

    function test_sub_1(uint8[2] calldata x, uint8[2] calldata y, uint256[2] memory i) public {
        i[0] = bound(i[0], 0, 30);
        i[1] = bound(i[1], i[0] + 1, 31);

        Vec8x32 xs = embed8x32(i[0], x[0]) | embed8x32(i[1], x[1]);
        Vec8x32 ys = embed8x32(i[0], y[0]) | embed8x32(i[1], y[1]);

        Vec8x32 zs = xs - ys;

        uint8 z0 = zs.pluck(i[0]);
        uint8 z1 = zs.pluck(i[1]);

        unchecked {
            assertEq(z0, x[0] - y[0]);
            assertEq(z1, x[1] - y[1]);
        }
    }

    function test_sub_2(uint8 x, uint8 y) public {
        Vec8x32 xs = broadcast8x32(x);
        Vec8x32 ys = broadcast8x32(y);

        Vec8x32 zs = xs - ys;

        unchecked {
            assertTrue(zs.all(x - y));
        }
    }
}
