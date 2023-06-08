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
    def sum_dice_outcome_probas(num_dice):
        outcomes = generate_dice_outcomes(num_dice)
        return sum([outcome.probability for outcome in outcomes])

    proba_sums = np.array([sum_dice_outcome_probas(nd) for nd in range(6)])
    assert np.allclose(proba_sums, np.ones(proba_sums.shape))


def test_policy_stops_when_rolls_expended():
    """
    WHEN you have no more available rolls
    THEN no further rolls will be made and no other termination conditions are noted
    """
    termination_roll = Roll(gattling=2, dynamite=1, other=2)
    result = determine_end_result(termination_roll, 0)
    assert np.allclose(result.expectation, termination_roll.as_np_array())
    assert result.gattling_exp== 0
    assert result.dynamite_exp== 0


def test_policy_sticks_on_gattlings():
    """
    WHEN a trio of gattlings have been rolled
    THEN no further rolls will be made and a success will be registered
    """
    termination_roll = Roll(gattling=3, dynamite=0, other=2)
    result = determine_end_result(termination_roll, 2)
    assert np.allclose(result.expectation, termination_roll.as_np_array())
    assert result.gattling_exp== 1
    assert result.dynamite_exp== 0


def test_policy_explodes_on_dynamites():
    """
    WHEN a trio of dynamites have been rolled
    THEN no further rolls will be made and an explosion will be registered
    """
    termination_roll = Roll(gattling=1, dynamite=3, other=1)
    result = determine_end_result(termination_roll, 2)
    assert np.allclose(result.expectation, termination_roll.as_np_array())
    assert result.gattling_exp== 0
    assert result.dynamite_exp== 1


def test_policy_keeps_rolling_for_gattlings():
    """
    WHEN less than 3 gattlings have been rolled and more rolls are available
    THEN more rolls will happen, raising the expectation on gattlings
    """
    non_termination_roll = Roll(gattling=2, dynamite=1, other=2)
    result = determine_end_result(non_termination_roll, 1)
    assert result.expectation[0] > 2


def test_unreachable_trio_termination_outcomes():
    """
    WHEN you run the program with a fewer than three dice
    THEN three of a kind termination outcomes will have expectation zero
    """
    garbage_roll = determine_end_result(Roll(gattling=0, dynamite=0, other=2), 3)
    assert garbage_roll.gattling_exp == 0
    assert garbage_roll.dynamite_exp == 0
    assert np.all(garbage_roll.expectation > 0)

def test_trio_outcomes_are_aggregated():
    """
    WHEN you run the program with at least 3 dice
    THEN there will be a non-zero chance of a three of a kind termination
    """
    viable_roll = determine_end_result(Roll(gattling=0, dynamite=0, other=3), 3)
    assert viable_roll.gattling_exp > 0
    assert viable_roll.dynamite_exp > 0
    assert np.all(viable_roll.expectation > 0)
