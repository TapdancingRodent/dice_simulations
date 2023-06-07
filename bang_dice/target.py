from dataclasses import dataclass, fields
import math
import numpy as np

STARTING_DICE = 5
NUM_ROLLS = 3


@dataclass
class Roll:
    gattling: int
    dynamite: int
    other: int

    @classmethod
    def supported_faces(cls):
        return cls.__dataclass_fields__.keys()

    @property
    def total_rolled(self):
        return self.gattling + self.dynamite + self.other


@dataclass
class Outcome:
    probability: float
    roll: Roll

    def __init__(self, roll: Roll):
        self.roll = roll
        self.probability = math.prod(
            [
                math.pow(1 / 6, self.roll.gattling),
                math.pow(1 / 6, self.roll.dynamite),
                math.pow(4 / 6, self.roll.other),
            ]
        )

    @property
    def total_rolled(self):
        return self.roll.total_rolled


def generate_dice_outcomes(num_to_roll: int):
    outcomes = []
    for gattling_count in range(0, num_to_roll + 1):
        for dynamite_count in range(0, num_to_roll + 1 - gattling_count):
            other_count = num_to_roll - gattling_count - dynamite_count
            roll = Roll(gattling=gattling_count, dynamite=dynamite_count, other=other_count)
            outcomes.append(Outcome(roll))

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
        