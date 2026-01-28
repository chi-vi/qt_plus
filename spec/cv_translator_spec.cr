require "./spec_helper"
require "../src/cv_translator/engine"
require "../src/cv_translator/rule"
require "../src/cv_translator/token"

include CvTranslator

describe Engine do
  it "swaps adj and noun" do
    t1 = Token.new("A", "a", "A_mean")
    t2 = Token.new("N", "n", "N_mean")
    sentence = [t1, t2]

    pattern = [Condition.new(pos: "a"), Condition.new(pos: "n")]
    # Note: Crystal needs help inferring the Array(String | Int32) if we just pass [0, 1]
    args = [0, 1] of String | Int32
    action = Action.new("swap", args)

    rule = Rule.new("swap_an", pattern, [action])

    engine = Engine.new([rule])
    result = engine.translate(sentence)

    result[0].should eq(t2)
    result[1].should eq(t1)
  end

  it "updates meaning based on context" do
    t1 = Token.new("X", "x", "old")
    pattern = [Condition.new(word: "X")]

    args = [0, "new"] of String | Int32
    action = Action.new("update_meaning", args)

    rule = Rule.new("update_x", pattern, [action])

    engine = Engine.new([rule])
    result = engine.translate([t1])

    result[0].meaning.should eq("new")
  end
end
