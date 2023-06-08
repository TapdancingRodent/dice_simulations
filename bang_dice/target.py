from collections import namedtuple
from dataclasses import dataclass, fields
import math
import numpy as np

STARTING_DICE = 5
NUM_ROLLS = 3


RollProbability = namedtuple("RollProbability", "roll probability")


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
class OutcomeAggregation: pass


def calculate_probability(roll: Roll):
    return math.prod(
        [
            math.pow(1 / 6, roll.gattling),
            math.pow(1 / 6, roll.dynamite),
            math.pow(4 / 6, roll.other),
        ]
    )


def generate_dice_outcomes(num_to_roll: int):
    outcomes = []
    for gattling_count in range(0, num_to_roll + 1):
        for dynamite_count in range(0, num_to_roll + 1 - gattling_count):
            other_count = num_to_roll - gattling_count - dynamite_count
            roll = Roll(gattling=gattling_count, dynamite=dynamite_count, other=other_count)
            outcomes.append(RollProbability(roll, calculate_probability(roll)))

    return outcomes


def determine_end_result(roll_state: Roll, remaining_rolls: int, policy=None) -> OutcomeAggregation:
    # Apply the policy for what to keep, optionally keep rolling
    return roll_state  # For now, simply return what was rolled


if __name__ == "__main__":
    proba_table = np.zeros((len(Roll.supported_faces),))
    policy = "Shoot for as many gattling as possible"
    initial_roll_outcomes = generate_dice_outcomes(STARTING_DICE)
    for outcome in initial_roll_outcomes:
        proba_table += outcome.probability * determine_end_result(outcome, NUM_ROLLS-1, policy)
    print(proba_table)
        