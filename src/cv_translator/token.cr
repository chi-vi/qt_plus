require "yaml"

module CvTranslator
  class Token
    include YAML::Serializable

    property word : String
    property pos : String
    property meaning : String

    def initialize(@word : String, @pos : String, @meaning : String)
    end
  end
end
