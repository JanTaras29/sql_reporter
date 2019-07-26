# frozen_string_literal: true

module SqlReporter
  class Total
    attr_accessor :query_diff, :duration_diff

    def initialize(query = 0 , duration = 0)
      @query_diff = query
      @duration_diff = duration
    end

    def +(total)
      self.class.new(query_diff + total.query_diff, duration_diff + total.duration_diff)
    end

    def query_gain
      query_diff > 0 ? query_diff : 0
    end

    def query_drop
      query_diff > 0 ? 0 : -query_diff
    end

    def summary
      queries_msg + duration_msg + "\n"
    end

    private

    def queries_msg
      "\nQueries count change: #{query_diff}\n" 
    end

    def duration_msg
      "\nDuration #{duration_diff > 0 ? 'gain' : 'decrease' }[ms]: #{duration_diff.abs.round(2)}\n"
    end
  end
end