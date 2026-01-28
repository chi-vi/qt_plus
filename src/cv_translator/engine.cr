require "./rule"
require "./token"

module CvTranslator
  class Engine
    property rules : Array(Rule)

    def initialize(@rules : Array(Rule))
    end

    # Represents a decision at a specific index
    struct Step
      property rule : Rule?
      property previous_index : Int32

      def initialize(@previous_index : Int32, @rule : Rule? = nil)
      end
    end

    def translate(sentence : Array(Token)) : Array(Token)
      n = sentence.size
      return sentence if n == 0

      # dp[i] = max score for the first i tokens (index 0 to i-1)
      dp = Array(Int32).new(n + 1, -1)
      backptr = Array(Step?).new(n + 1, nil)

      dp[0] = 0

      (1..n).each do |i|
        # Option 1: Skip current token (treat as Identity transformation)
        # Score = previous score + small base score (e.g. 1) to prefer covering tokens vs nothing?
        # Actually, if we skip, we just keep the token as is.
        # Making the base score 0 might prefer finding rules.
        # Let's say keeping a token gives 1 point (length 1 * 10?).
        # No, let's keep it simple: Base score 1.
        score_skip = dp[i - 1] + 1
        if score_skip > dp[i]
          dp[i] = score_skip
          backptr[i] = Step.new(i - 1, nil)
        end

        # Option 2: Apply a rule ending at i (covering range start...i)
        @rules.each do |rule|
          len = rule.length
          start = i - len

          if start >= 0
            # Check if rule matches tokens[start...i]
            if rule.match?(sentence, start)
              current_score = dp[start] + rule.weight
              if current_score > dp[i]
                dp[i] = current_score
                backptr[i] = Step.new(start, rule)
              end
            end
          end
        end
      end

      # Reconstruct steps
      steps = [] of Step
      curr = n
      while curr > 0
        step = backptr[curr]
        if step
          steps << step
          curr = step.previous_index
        else
          # Should not happen if dp logic is correct
          break
        end
      end
      steps.reverse!

      # Build result
      result = [] of Token

      steps.each do |step|
        start_idx = step.previous_index
        rule = step.rule

        if rule
          # Apply rule
          chunk_len = rule.length
          original_chunk = sentence[start_idx, chunk_len]

          # 1. Apply Reordering
          reordered_chunk = original_chunk.dup
          if ordering = rule.reordering
            new_chunk = [] of Token
            ordering.each do |relative_idx|
              if relative_idx < original_chunk.size
                new_chunk << original_chunk[relative_idx]
              end
            end
            reordered_chunk = new_chunk
          end

          # 2. Apply Overriding (Meaning Update)
          # Note: Overrding map applies to INDICES relative to the ORIGINAL match usually?
          # Or relative to the NEW order?
          # "Overriding" in config example was "1: của".
          # If we reordered [0, 2, 1], index 1 is now at the end.
          # Usually logic is: "Update meaning of token at original index X".
          # However, since we return a new list of tokens, we should probably modify the instances in the new list?
          # Let's assume overriding applies to the token object itself. Since we dup, we can modify it.
          # But wait, if we reorder, which token is which?
          # Let's clone tokens so we don't mutate original sentence for safety.

          final_chunk = reordered_chunk.map { |t| t.clone } # Need clone method

          # If Overriding is map<Int, String> where Int is relative index in match
          if overrides = rule.overriding
            overrides.each do |idx, new_meaning|
              # Find where the token at original index `idx` ended up?
              # Or does validation imply we update meaning BEFORE reorder?
              # Usually easier to update meaning on the original tokens (clones) then reorder.

              # Let's do: Clone -> Update Meaning (using original indices) -> Reorder
            end
          end

          # RE-DO implementation for correctness:
          # 1. Get original chunk
          # 2. Clone tokens
          # 3. Apply meanings to clones (by original index)
          # 4. Reorder clones

          # But wait, the Token class needs a #clone method
          working_chunk = original_chunk.map { |t|
            # Manual clone since it's a simple class
            Token.new(t.word, t.pos, t.meaning)
          }

          if overrides = rule.overriding
            overrides.each do |idx, new_meaning|
              if idx < working_chunk.size
                working_chunk[idx].meaning = new_meaning
              end
            end
          end

          final_chunk = [] of Token
          if ordering = rule.reordering
            ordering.each do |relative_idx|
              if relative_idx < working_chunk.size
                final_chunk << working_chunk[relative_idx]
              end
            end
          else
            final_chunk = working_chunk
          end

          result.concat(final_chunk)
        else
          # Identity (Skip)
          # Just append the single token at range start_idx...start_idx+1
          # Clone it too
          t = sentence[start_idx]
          result << Token.new(t.word, t.pos, t.meaning)
        end
      end

      result
    end
  end
end
