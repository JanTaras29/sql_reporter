# frozen_string_literal: true

module SqlReporter
  class Total
    attr_accessor :query_diff, :duration_diff
    def initialize
      @query_diff = 0
      @duration_diff = 0
    end

    def initialize(query, duration)
      @query_diff = query
      @duration_diff = duration
    end

    def queries_msg
      "\nQueries #{query_diff > 0 ? 'spawned' : 'killed' }: #{query_diff.abs}\n" 
    end

    def duration_msg
      "\nDuration #{duration_diff > 0 ? 'gain' : 'decrease' }[ms]: #{duration_diff.abs.round(2)}\n"
    end

    def summary
       queries_msg + duration_msg + "\n"
    end

    def +(total)
      self.class.new(query_diff + total.query_diff, duration_diff + total.duration_diff)
    end
  end
end