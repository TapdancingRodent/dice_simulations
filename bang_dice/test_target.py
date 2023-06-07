import math

from target import Roll, generate_dice_outcomes


def test_no_rolls_has_simple_outcome():
    """
    WHEN rolling no dice
    THEN the outcome will be none of all faces with unity probability
    """
    outcomes = generate_dice_outcomes(0)
    assert len(outcomes) == 1
    assert outcomes[0].total_rolled == 0
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


# TODO: a class / NamedTuple for outcomes-probability pairs
