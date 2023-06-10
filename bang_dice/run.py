import argparse
import logging

from target import Roll, determine_end_result

STARTING_DICE = 5
NUM_ROLLS = 3


def main():
    policy = "Shoot for as many gattling as possible"

    parser = argparse.ArgumentParser(prog='BangDice', description='Estimate probability in the bang dice game')
    parser.add_argument('-g', '--initial-gattling', default=0, dest="gattling", help="Number of gattling in the initial roll state", type=int)
    parser.add_argument('-d', '--initial-dynamite', default=0, dest="dynamite", help="Number of dynamite in the initial roll state", type=int)
    parser.add_argument('-o', '--initial-other', default=5, dest="other", help="Number of other faces in the initial roll state", type=int)
    parser.add_argument('-r', '--rolls', default=3, help="Total rolls available", type=int)
    parser.add_argument('-v', '--verbose', action='store_true')
    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    # Pretend I have an extra roll because I'm lazy
    initial_roll = Roll(gattling=args.gattling, dynamite=args.dynamite, other=args.other)
    result = determine_end_result(initial_roll, args.rolls, policy)
    print(result.pretty_outcome())


if __name__ == "__main__":
    main()
