Percolation Kata
================

Given a material composition, write an algorithm to determine if the material is permeable.
Return true if water can pass through the material, otherwise false.

- Water will travel from top to bottom.
- Can pass only directly down (no diagonal transfer) to Open spaces.
- Water will fill open sibling cells on same level before attempting to move to next row.

Material Composition can be reflected as a multi-dimensional array.

```
[1] = Blocked
[0] = Open
[W] = Water
```

Permeable Composition Example:

```
State 0 - no water

[1][0][1][1][0] 
[1][0][0][1][1]
[1][1][0][1][1]
[1][0][0][1][1]
[1][0][1][1][1]

[1][W][1][1][W] State 1 - water passed to 1st row
[1][0][0][1][1]
[1][1][0][1][1]
[1][0][0][1][1]
[1][0][1][1][1]

[1][W][1][1][W] 
[1][W][W][1][1] State 2 - water passed to 2nd row
[1][1][0][1][1]
[1][0][0][1][1]
[1][0][1][1][1]

[1][W][1][0][1]
[1][W][W][1][1]
[1][1][W][1][1] State 3 - water passed to 3rd row
[1][0][0][1][1]
[1][0][1][1][1]

[1][W][1][0][1]
[1][W][W][1][1]
[1][1][W][1][1]
[1][W][W][1][1] State 4 - water passed to 4th row
[1][0][1][1][1]

[1][W][1][0][1]
[1][W][W][1][1]
[1][1][W][1][1]
[1][W][W][1][1]
[1][W][1][1][1] State 5 - water passed to 5th row, therefore composition demed permeable!
```

Non-Permeable Composition Example:

```
State 0 -  no water

[1][0][1][1][0] 
[1][1][0][1][1]
[1][1][0][1][1]
[1][0][0][1][1]
[1][0][1][1][1]

[1][W][1][1][W] State 1 -  water on 1st row
[1][1][0][1][1] 
[1][1][0][1][1]
[1][0][0][1][1]
[1][0][1][1][1]   

[1][W][1][1][W] State 2 -  water cannot make it to 2nd row...!
[1][1][0][1][1] 
[1][1][0][1][1]
[1][0][0][1][1]
[1][0][1][1][1]
```
