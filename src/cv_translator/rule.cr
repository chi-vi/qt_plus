require "yaml"
require "./token"

module CvTranslator
  # A Condition checks if a token matches certain criteria.
  # Currently supports matching by POS tag.
  class Condition
    include YAML::Serializable

    property pos : String?
    property word : String?

    def initialize(@pos : String? = nil, @word : String? = nil)
    end

    def match?(token : Token) : Bool
      if p = @pos
        return false unless token.pos == p
      end
      if w = @word
        return false unless token.word == w
      end
      true
    end
  end

  # An Action defines what to do when a rule matches.
  # We use a discriminator or just loose parsing to handle different action types.
  # For simplicity in this iteration, let's use a structured approach that can be mapped from YAML.
  class Action
    include YAML::Serializable

    # Action types: "swap", "update_meaning", "noop"
    property type : String

    # Arguments for the action
    # For swap: [index1, index2] (relative to the match match start)
    # For update_meaning: [index, new_meaning]
    property args : Array(String | Int32)

    def initialize(@type : String, @args : Array(String | Int32))
    end
  end

  class Rule
    include YAML::Serializable

    property name : String
    property pattern : Array(Condition)
    property actions : Array(Action)

    def initialize(@name : String, @pattern : Array(Condition), @actions : Array(Action))
    end
  end
end
