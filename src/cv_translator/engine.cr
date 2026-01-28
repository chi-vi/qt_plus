require "./rule"
require "./token"

module CvTranslator
  class Engine
    property rules : Array(Rule)

    def initialize(@rules : Array(Rule))
    end

    def translate(sentence : Array(Token)) : Array(Token)
      # We process until no more rules apply or we hit a safety limit
      # For now, let's do a single pass or a few passes.
      # Ideally, we restart the scan after a match to handle nested structures,
      # but we must avoid infinite loops.

      passes = 0
      max_passes = 100
      changed = true

      while changed && passes < max_passes
        changed = false
        passes += 1

        i = 0
        while i < sentence.size
          # Try to match rules at position i
          match_found = false

          @rules.each do |rule|
            match_len = rule.pattern.size
            next if i + match_len > sentence.size

            # Check if pattern matches
            matches = true
            match_len.times do |offset|
              unless rule.pattern[offset].match?(sentence[i + offset])
                matches = false
                break
              end
            end

            if matches
              # Apply actions
              apply_actions(rule, sentence, i)
              changed = true
              match_found = true

              # Optimization: After a match, we might want to skip ahead
              # or restart. For simplicity, we break to the outer changes loop
              # to re-evaluate from the start (safer for complex reordering).
              # But to just simple-swap and continue, we can skip `match_len`.
              # Let's restart scan to be safe for now, validation will tell.
              break
            end
          end

          if match_found
            break # Restart the while loop (passes)
          end

          i += 1
        end
      end

      sentence
    end

    private def apply_actions(rule : Rule, sentence : Array(Token), start_index : Int32)
      rule.actions.each do |action|
        case action.type
        when "swap"
          if action.args.size == 2
            idx1 = action.args[0].as(Int32)
            idx2 = action.args[1].as(Int32)
            # Swap relative to start_index
            real_idx1 = start_index + idx1
            real_idx2 = start_index + idx2

            # Simple swap
            sentence[real_idx1], sentence[real_idx2] = sentence[real_idx2], sentence[real_idx1]
          end
        when "update_meaning"
          if action.args.size == 2
            idx = action.args[0].as(Int32)
            new_meaning = action.args[1].as(String)
            sentence[start_index + idx].meaning = new_meaning
          end
        end
      end
    end
  end
end
