require "./src/cv_translator/token"
require "./src/cv_translator/rule"
require "./src/cv_translator/engine"
require "./src/cv_translator/config_loader"

include CvTranslator

# 1. Load Rules
puts "Loading rules..."
rules = ConfigLoader.load_rules("grammar.yaml")
puts "Loaded #{rules.size} rules."
engine = Engine.new(rules)

def test(name : String, tokens : Array(Token), engine : Engine)
  puts "\n--- Test: #{name} ---"
  puts "Original: " + tokens.map { |t| "#{t.meaning}" }.join(" ")

  result = engine.translate(tokens)

  puts "Translated: " + result.map { |t| "#{t.meaning}" }.join(" ")
  puts "Result Tokens: " + result.map { |t| "#{t.word}(#{t.pos})" }.join(" ")
end

# 1. NP: Beautiful Flower
t1 = [Token.new("美丽", "a", "đẹp"), Token.new("花", "n", "hoa")]
test("Adj + Noun", t1, engine)

# 2. Possessive: My Book
t2 = [Token.new("我", "r", "tôi"), Token.new("的", "u", "đích"), Token.new("书", "n", "sách")]
test("Possessive", t2, engine)

# 3. Passive: I bei Him Beat (I was beaten by him)
t3 = [Token.new("我", "r", "tôi"), Token.new("被", "p", "bị"), Token.new("他", "r", "anh_ta"), Token.new("打", "v", "đánh")]
test("Passive (Bei)", t3, engine)

# 4. Location: Zai Home Eat
t4 = [Token.new("在", "p", "tại"), Token.new("家", "n", "nhà"), Token.new("吃", "v", "ăn")]
test("Location (Zai)", t4, engine)

# 5. Negation: Bu Good
t5 = [Token.new("不", "d", "bất"), Token.new("好", "a", "tốt")]
test("Negation (Bu)", t5, engine)

# 6. Direction: Wang South Walk
t6 = [Token.new("往", "p", "vãng"), Token.new("南", "n", "nam"), Token.new("走", "v", "đi")]
test("Direction (Wang)", t6, engine)

# 7. Suffix: Student Men (Plural)
t7 = [Token.new("同学", "n", "bạn_học"), Token.new("们", "k", "môn")]
test("Suffix (Men)", t7, engine)
