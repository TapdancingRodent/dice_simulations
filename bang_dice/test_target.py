import math
import numpy as np

from target import Roll, determine_end_result, generate_dice_outcomes


def test_no_rolls_has_simple_outcome():
    """
    WHEN rolling no dice
    THEN the outcome will be none of all faces with unity probability
    """
    outcomes = generate_dice_outcomes(0)
    assert len(outcomes) == 1
    assert outcomes[0].roll.total_rolled == 0
    assert outcomes[0].probability == 1


def test_single_roll_has_all_outcomes():
    """
    WHEN rolling a single die
    THEN there will be an outcome for each face value
    """
    outcomes = generate_dice_outcomes(1)
    assert len(outcomes) == len(Roll.supported_faces())


def test_single_roll_probability_sum_is_one():
    """
    WHEN rolling a single die
    THEN the sum of outcomes adds up to one
    """
    outcomes = generate_dice_outcomes(1)
    proba_sum = sum([outcome.probability for outcome in outcomes])
    assert math.isclose(proba_sum, 1, rel_tol=1e-9, abs_tol=0.0)


def test_policy_sticks_on_gattlings():
    """
    WHEN a trio of gattlings have been rolled
    THEN no further rolls will be made
    """
    termination_roll = Roll(gattling=3, dynamite=1, other=1)
    result = determine_end_result(termination_roll, 2)
    assert np.allclose(result.expectation, termination_roll.as_np_array())
    # TODO: mock generate_dice_outcomes and check it wasn't called
