require "yaml"

module CvTranslator
  class Token
    include YAML::Serializable

    property word : String
    property pos : String
    property meaning : String

    def initialize(@word : String, @pos : String, @meaning : String)
    end

    def clone
      Token.new(@word, @pos, @meaning)
    end
  end
end
