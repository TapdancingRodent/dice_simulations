# Bang Dice
Simulations of the bang dice game aimed at assessing the likelihood (and therefore value) of rolling for gattling guns.

## Usage
At present, running `run.py` as a script will run a basic simulation attempting to get to 3 gattling guns and ignoring all other results (bar dynamite, obviously). Specific simulations can be triggered by modifying the arguments given to `run.py` e.g. outcomes expected when getting 2 gattlings and no dynamite in the first roll:

```
$ python run.py -g 2 -o 3 -r 2
Expected outcome: {'gattling': 2.7314814814814814, 'dynamite': 0.7314814814814813, 'other': 1.5370370370370368}
P(achieving 3 gattling): 0.6232853223593963
P(exploding to 3 dynamite): 0.02143347050754458
```

## Development
This tool was developed under a pseudo-BDD process (tests can be run with `pytest`) and the contents of `test_target.py` contains good examples of how the components in `target.py` are designed to be used.

The OOP implementation was chosen to provide room for extension later since aggregating results back to the initial caller is non-trivial and a question like "how many arrows do I expect to roll when shooting for 3 gattling guns" may require metadata to bubble up or down the probability tree.
