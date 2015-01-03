# Sample System
Sample System describes a train system that goes across America.

It's not very logical, but it serves the purpose of demonstrating a data
format.

## `stations`
The `stations` object contains a mapping of "station codes" (basically unique
IDs for every station) to station names.

## `connections`
The `connections` object contains one key-value pair for every station. The key
is the station ID. The value is a mapping of station IDs to costs. The costs
are used when calculating an optimal path.

For example, say we want to travel from California to Penslyllyafsdvvania. Here
is how we would navigate the datastructure and find the total cost.

1. Find the station IDs (1 and 4).
2. Simplify paths.
3. Find possible paths.
4. Find the optimal path. (1 -> 3 -> 4)
