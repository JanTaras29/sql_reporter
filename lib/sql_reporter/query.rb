# frozen_string_literal: true

# Data struct for keeping the query data
module SqlReporter
  class Query
    attr_accessor :sql, :count, :duration

    def self.null(query_name)
      self.new(query_name, 0, 0)
    end

    def initialize(s,c,d)
      @sql = s
      @count = c
      @duration = d
    end

    def +(other)
      self.class.new(sql, count + other.count, duration + other.duration)
    end

    def -(other)
      self.class.new(sql, count - other.count, duration - other.duration)
    end

    def post_decimal_score(max_count)
      count * (1 / (master_max_count + 1))
    end

    def duration_formatted
      duration&.round(2)
    end
  end
end