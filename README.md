# $\vec{v}$.sol

**A vector data type with 32 8-bit components and basic vectorized operations.**

*May contain bugs. Use at your own risk.*

```solidity
import {Vec8x32} from 'solidity-vectors/Vec8x32.sol';
```

## Constants

### `V0x32`

A vector of zeros.

### `V1x32`

A vector of ones.

## Construction

### `broadcast8x32(x)`

Returns a vector $v$ such that $v_i = x$ for all $i$.

### `embed8x32(i, x)`

Returns a vector $v$ such that $v_i = x$ and $v_j = 0$ for $j \neq i$.

$i$ is used modulo 32.

### `fill8x32(n, x)`

Returns a vector $v$ such that $v_i = x$ for $i < n$ and $v_j = 0$ for $j >= n$.

$n$ is used modulo 32.

## Modification

### `v.put(i, x)`

Returns a new vector $v'$ such that $v'_i = x$ and $v'_j = v_j$ for $i \neq j$.

$i$ is used modulo 32.

## Predicates

### `v.any(x)`

Returns true if there is any $v_i = x$.

### `v.all(x)`

Returns true if $v_i = x$ for all $i$.

## Arithmetic

### `v + w`, `v - w`

Component-wise addition and subtraction of two vectors with wrap-around on overflow.

### `-v`

Component-wise negation with wrap-around on overflow.

## Bitwise

### `v & w`, `v | w`, `v ^ w`, `~v`

Component-wise bitwise operators. (Equivalent to operating on `bytes32` values.)

## Others

### `v.pluck(i)`

Returns $v_i$. $i$ is used modulo 32.
