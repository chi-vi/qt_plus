require "yaml"
require "./rule"

module CvTranslator
  class ConfigLoader
    def self.load_rules(file_path : String) : Array(Rule)
      content = File.read(file_path)
      # We assume the YAML is a list of rules
      Array(Rule).from_yaml(content)
    end
  end
end
