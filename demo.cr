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

# Example 2: "我的 书" (My Book) -> "tôi" + "đích" (original LTP meaning usually generic) + "sách"
# Expect: "tôi của sách" -> "sách của tôi" (if we had pronoun rules, but here testing the 'de' rule)
# Actually, Chinese is Pronoun + de + Noun.
tokens2 = [
  Token.new("我", "r", "tôi"),
  Token.new("的", "u", "đích"),
  Token.new("书", "n", "sách"),
]
# Wait, my Swap rule was Adj+Noun.
# Pronoun+de+Noun is Noun+de+Pronoun in VN?
# "My book" -> "Sách của tôi".
# So: "r" + "u" + "n" -> "n" + "u" + "r"?
# My sample rule only swaps Adj+Noun. And updates 'de'.
# Let's add a rule for the demo script quickly if we want to show it working, or just rely on what we have.
# The sample rule updates 'de' to 'của'.
# It doesn't swap 'r' and 'n'.
# Let's just run it and see the update match works.

puts "\nOriginal 2:"
puts tokens2.map { |t| "#{t.word}(#{t.pos}):#{t.meaning}" }.join(" ")
result2 = engine.translate(tokens2)
puts "\nTranslated 2:"
puts result2.map { |t| "#{t.word}(#{t.pos}):#{t.meaning}" }.join(" ")
