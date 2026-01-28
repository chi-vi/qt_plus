require "./spec_helper"
require "../src/cv_translator/engine"
require "../src/cv_translator/rule"
require "../src/cv_translator/token"

include CvTranslator

describe Engine do
  it "calculates rule weight correctly" do
    # Rank 2, Len 2, Spec 0 -> 200 + 20 + 0 = 220
    rule = Rule.new("Test", 2, ["a", "n"])
    rule.weight.should eq(220)

    # Rank 1, Len 1, Spec 1 -> 100 + 10 + 1 = 111
    rule2 = Rule.new("Test2", 1, ["u"], ["x"])
    rule2.weight.should eq(111)
  end

  it "swaps adj and noun using reordering" do
    t1 = Token.new("A", "a", "A_mean")
    t2 = Token.new("N", "n", "N_mean")
    sentence = [t1, t2]

    # Rule: Swap 0 and 1
    # Note: reordering: [1, 0] means new index 0 takes from old index 1, etc.
    rule = Rule.new("swap_an", 2, ["a", "n"], nil, [1, 0])

    engine = Engine.new([rule])
    result = engine.translate(sentence)

    result[0].word.should eq("N")
    result[1].word.should eq("A")
  end

  it "chooses higher rank rule" do
    t1 = Token.new("A", "a", "A_val")

    # Rule 1: Rank 1 matches "a"
    rule1 = Rule.new("r1", 1, ["a"])
    # Rule 2: Rank 2 matches "a", overrides meaning
    rule2 = Rule.new("r2", 2, ["a"], nil, nil, {0 => "Overridden"})

    # Both match, but Rule 2 has higher weight
    engine = Engine.new([rule1, rule2])
    result = engine.translate([t1])

    result[0].meaning.should eq("Overridden")
  end
end
