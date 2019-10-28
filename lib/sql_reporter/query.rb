# frozen_string_literal: true

# Data struct for keeping the query data
module SqlReporter
  class Query
    attr_accessor :sql, :count, :duration, :cached_count

    def self.null(query_name)
      self.new(query_name, 0, 0, 0)
    end

    def initialize(s, c, d, cc)
      @sql = s
      @count = c
      @duration = d
      @cached_count = cc
    end

    def +(other)
      self.class.new(sql, count + other.count, duration + other.duration, cached_count + other.cached_count)
    end

    def -(other)
      self.class.new(sql, count - other.count, duration - other.duration, cached_count - other.cached_count)
    end

    def post_decimal_score(max_count)
      count * (1 / (max_count + 1))
    end

    def duration_formatted
      duration&.round(2)
    end
  end
end