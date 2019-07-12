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

    def duration_formatted
      duration&.round(2)
    end
  end
end