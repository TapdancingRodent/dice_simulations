from collections import namedtuple
from dataclasses import dataclass
import logging
import math
import numbers
import numpy as np


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
    gattling_exp: float
    dynamite_exp: float

    def __init__(self, expectation=None, gattling_exp=0.0, dynamite_exp=0.0):
        if expectation is None:
            self.expectation = np.zeros((len(Roll.supported_faces()),))
        else:
            self.expectation = expectation

        self.gattling_exp = gattling_exp
        self.dynamite_exp = dynamite_exp

    def __iadd__(self, other_oa):
        self.expectation += other_oa.expectation
        self.gattling_exp += other_oa.gattling_exp
        self.dynamite_exp += other_oa.dynamite_exp
        return self

    def __mul__(self, other):
        if not isinstance(other, numbers.Number):
            raise NotImplementedError(f"Outcome aggregators can only be multiplied by a numeric scalar value not {other} of type {type(other)}")

        self.expectation = self.expectation * other
        self.gattling_exp *= other
        self.dynamite_exp *= other
        return self

    def pretty_outcome(self):
        return (
            f"Expected outcome: {dict(zip(Roll.supported_faces(), self.expectation))}\n"
            f"P(achieving 3 gattling): {self.gattling_exp}\n"
            f"P(exploding to 3 dynamite): {self.dynamite_exp}"
        )


def determine_end_result(roll_state: Roll, remaining_rolls: int, policy=None) -> OutcomeAggregation:
    if roll_state.gattling >= 3:
        logging.debug("Reached terminating state: 3 gattlings")
        return OutcomeAggregation(expectation=roll_state.as_np_array(), gattling_exp=1.0)

    elif roll_state.dynamite >= 3:
        logging.debug("Reached terminating state: 3 dynamite")
        return OutcomeAggregation(expectation=roll_state.as_np_array(), dynamite_exp=1.0)

    elif remaining_rolls == 0:
        logging.debug("Reached terminating state: Exhausted re-rolls")
        return OutcomeAggregation(expectation=roll_state.as_np_array())

    elif roll_state.other == 0:
        logging.debug("Reached terminating state: No dice to re-roll")
        # Default case to avoid wasted recursion in some edge cases
        return OutcomeAggregation(expectation=roll_state.as_np_array())

    logging.debug("Roll state not terminal, recursing into next re-roll")
    logging.debug(f"Current dice faces: {roll_state}")
    roll_outcomes = generate_dice_outcomes(roll_state.other)
    logging.debug(f"Additional dice outcomes to be evaluated: {roll_outcomes}")
    outcome_agg = OutcomeAggregation()

    for outcome in roll_outcomes:
        outcome.roll.gattling += roll_state.gattling
        outcome.roll.dynamite += roll_state.dynamite
        outcome_agg += (
            determine_end_result(outcome.roll, remaining_rolls - 1, policy) * outcome.probability
        )

    logging.debug(f"Intermediate outcome at reroll height {remaining_rolls}: {outcome_agg}")

    return outcome_agg
