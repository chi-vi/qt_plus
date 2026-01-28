require "./src/cv_translator/token"
require "./src/cv_translator/rule"
require "./src/cv_translator/engine"
require "./src/cv_translator/config_loader"

include CvTranslator

# 1. Load Rules
puts "Loading rules..."
rules = ConfigLoader.load_rules("grammar.yaml")
puts "Loaded #{rules.size} rules."

# 2. Prepare Sample Input
# Example: "美丽的 花" (Beautiful Flower) -> "đẹp" + "hoa"
# Expect: "hoa đẹp" (Noun + Adj)
tokens = [
  Token.new("美丽", "a", "đẹp"),
  Token.new("花", "n", "hoa"),
]

puts "\nOriginal:"
puts tokens.map { |t| "#{t.word}(#{t.pos}):#{t.meaning}" }.join(" ")

# 3. Translate
engine = Engine.new(rules)
result = engine.translate(tokens)

puts "\nTranslated:"
puts result.map { |t| "#{t.word}(#{t.pos}):#{t.meaning}" }.join(" ")

# Example 2: "我 的 书" (My Book) -> "tôi" + "đích" + "sách"
# Expect: "sách của tôi" (reorder 2, 1, 0 and update 1='của')
tokens2 = [
  Token.new("我", "r", "tôi"),
  Token.new("的", "u", "đích"),
  Token.new("书", "n", "sách"),
]

puts "\nOriginal 2:"
puts tokens2.map { |t| "#{t.word}(#{t.pos}):#{t.meaning}" }.join(" ")
result2 = engine.translate(tokens2)
puts "\nTranslated 2:"
puts result2.map { |t| "#{t.word}(#{t.pos}):#{t.meaning}" }.join(" ")
