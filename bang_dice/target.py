from collections import namedtuple
from dataclasses import dataclass, fields
import math
import numbers
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

    def as_np_array(self):
        return np.array([self.gattling, self.dynamite, self.other])


def multinomial_coeff(lst):
    """Taken from https://stackoverflow.com/a/46378809"""
    res, i = 1, 1
    for a in lst:
        for j in range(1, a + 1):
            res *= i
            res //= j
            i += 1
    return res


def calculate_probability(roll: Roll):
    return math.prod(
        [
            math.pow(1 / 6, roll.gattling),
            math.pow(1 / 6, roll.dynamite),
            math.pow(4 / 6, roll.other),
        ]
    ) * multinomial_coeff(roll.as_np_array())


def generate_dice_outcomes(num_to_roll: int):
    outcomes = []
    for gattling_count in range(0, num_to_roll + 1):
        for dynamite_count in range(0, num_to_roll + 1 - gattling_count):
            other_count = num_to_roll - gattling_count - dynamite_count
            roll = Roll(gattling=gattling_count, dynamite=dynamite_count, other=other_count)
            outcomes.append(RollProbability(roll, calculate_probability(roll)))

    return outcomes


@dataclass
class OutcomeAggregation:
    expectation: np.array

    def __init__(self, expectation=None):
        if expectation is None:
            self.expectation = np.zeros((len(Roll.supported_faces()),))
        else:
            self.expectation = expectation

    def __iadd__(self, other_oa):
        self.expectation += other_oa.expectation
        return self

    def __mul__(self, other):
        if not isinstance(other, numbers.Number):
            raise NotImplementedError(f"Outcome aggregators can only be multiplied by a numeric scalar value not {other} of type {type(other)}")
        self.expectation = self.expectation * other
        return self


def determine_end_result(roll_state: Roll, remaining_rolls: int, policy=None) -> OutcomeAggregation:
    if roll_state.gattling >= 3 or roll_state.dynamite >= 3 or roll_state.other == 0 or remaining_rolls == 0:
        return OutcomeAggregation(expectation=roll_state.as_np_array())

    roll_outcomes = generate_dice_outcomes(roll_state.other)
    outcome_agg = OutcomeAggregation()

    for outcome in roll_outcomes:
        outcome.roll.gattling += roll_state.gattling
        outcome.roll.dynamite += roll_state.dynamite
        outcome_agg += (
            determine_end_result(outcome.roll, remaining_rolls - 1, policy) * outcome.probability
        )

    return outcome_agg


if __name__ == "__main__":
    policy = "Shoot for as many gattling as possible"
    # Pretend I have an extra roll because I'm lazy
    outcome_agg = determine_end_result(Roll(gattling=0, dynamite=0, other=5), 3, policy)
    print(outcome_agg)
