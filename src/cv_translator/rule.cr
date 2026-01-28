require "yaml"
require "./token"

module CvTranslator
  class Rule
    include YAML::Serializable

    property desc : String
    property rank : Int32
    # "match_pos" is required, defines the sequence of POS tags
    @[YAML::Field(key: "match_pos")]
    property match_pos : Array(String)

    # "match_tok" is optional. If present, it must match the word at that position.
    # Empty string "" means "match anything".
    @[YAML::Field(key: "match_tok")]
    property match_tok : Array(String)?

    # "reordering" is optional. Defines new order of indices.
    property reordering : Array(Int32)?

    # "overriding" is optional map of index -> new meaning
    property overriding : Hash(Int32, String)?

    def initialize(@desc : String, @rank : Int32, @match_pos : Array(String),
                   @match_tok : Array(String)? = nil, @reordering : Array(Int32)? = nil,
                   @overriding : Hash(Int32, String)? = nil)
    end

    def length : Int32
      match_pos.size
    end

    # Specificity = Number of non-empty tokens in match_tok
    def specificity : Int32
      return 0 unless tok = match_tok
      tok.count { |t| !t.empty? }
    end

    # Weight calculation for DP
    def weight : Int32
      (rank * 100) + (length * 10) + specificity
    end

    def match?(tokens : Array(Token), start_index : Int32) : Bool
      return false if start_index + length > tokens.size

      length.times do |i|
        token = tokens[start_index + i]

        # Check POS
        required_pos = match_pos[i]
        # Allow checking simplified POS prefix? e.g. "n" matches "nh", "ni"?
        # For now, strict match or maybe simple casing? Let's assume strict match as per user request example.
        return false unless token.pos == required_pos

        # Check Token if specified
        if toks = match_tok
          # Ensure checks bound
          if i < toks.size
            required_word = toks[i]
            unless required_word.empty?
              return false unless token.word == required_word
            end
          end
        end
      end
      true
    end
  end
end
