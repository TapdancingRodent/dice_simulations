# Bang Dice
Simulations of the bang dice game aimed at assessing the likelihood (and therefore value) of rolling for gattling guns.

## Usage
At present, running `target.py` as a script will run a basic simulation attempting to get to 3 gattling guns and ignoring all other results (bar dynamite, obviously).

## Development
This tool was developed under a pseudo-BDD process (tests can be run with `pytest`) and the contents of `test_target.py` contains good examples of how the components in `target.py` are designed to be used.

The OOP implementation was chosen to provide room for extension later since aggregating results back to the initial caller is non-trivial and a question like "how many arrows do I expect to roll when shooting for 3 gattling guns" may require metadata to bubble up or down the probability tree.
