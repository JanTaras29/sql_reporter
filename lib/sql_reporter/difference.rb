module SqlReporter
  # Difference between 2 Query objects
  class Difference
    attr_reader :master, :feature, :query_name

    def initialize(name, master, feature)
      @query_name = name
      @master = master
      @feature = feature
    end

    def delta_count
      (feature - master).count
    end

    def delta_cached_count
      (feature - master).cached_count
    end

    def delta_time
      (feature - master).duration_formatted
    end

    def sort_score(max_count)
      (master - feature).count.abs + master.post_decimal_score(max_count)
    end
  end
end
