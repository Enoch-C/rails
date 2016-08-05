module Spree
  module Core
    Spree::Core::NumberGenerator.class_eval do
      private

      def generate_permalink(host)
        length = @length

        loop do
          candidate = new_candidate(length)
          return candidate unless host.exists?(number: candidate)

          # If over half of all possible options are taken add another digit.
          length += 1 if host.count > Rational(BASE**length, 2)
        end
      end

      def new_candidate(length)
        @prefix + "#{(Time.now.to_f * 10000).to_i}"[1..13] + 1.times.map { @candidates.sample(random: @random) }.join
      end
    end
  end
end
