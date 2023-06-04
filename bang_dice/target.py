from collections import namedtuple
import math
import numpy as np

STARTING_DICE = 5
NUM_ROLLS = 3
FACE_PROBABILITIES = [1/6, 1/6, 4/6]


Outcome = namedtuple("Outome", "faces probability")


def generate_dice_outcomes(num_to_roll: int):
    outcomes = []
    for a in range(0, num_to_roll + 1):
        for b in range(0, num_to_roll + 1 - a):
            outcome = [a, b, num_to_roll - a - b]
            proba = math.prod(
                [
                    math.pow(FACE_PROBABILITIES[idx], face_count)
                    for idx, face_count in enumerate(outcome)
                ]
            )
            outcomes.append(Outcome(outcome, proba))

    return outcomes


def determine_end_result(roll_state, remaining_rolls, policy) -> np.array:
    return roll_state  # For now, simply roll nothing


if __name__ == "__main__":
    proba_table = np.zeros((len(FACE_PROBABILITIES),))
    policy = "Shoot for as many gattling as possible"
    initial_roll_outcomes = generate_dice_outcomes(5)
    for outcome, proba in initial_roll_outcomes:
        proba_table += proba * determine_end_result(outcome, NUM_ROLLS-1, policy)
    print(proba_table)
        