module SqlReporter
  class Reporter
    def initialize(parser_hsh)
      @fname0, @master = parser_hsh.entries[0]
      @fname1, @feature = parser_hsh.entries[1]
      @master_max_count = @master.values.map(&:count).max
    end
  
    attr_accessor :master, :feature, :fname0, :fname1
    attr_reader :master_max_count

    def generate_report
			before_generate_report
			totals = []
			
			before_decreases
			totals << summary_for_selected_differences(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key].count > feature[key].count }

			before_increases
			totals << summary_for_selected_differences(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key].count < feature[key].count }

			before_spawned
			totals << summary_for_selected_differences(feature.keys - master.keys) { |key| feature[key] }

			before_gone
			totals << summary_for_selected_differences(master.keys - feature.keys) { |key| master[key] }

			before_summary
			summary = totals.reduce(SqlReporter::Total.new(0,0)) {|acc, t| acc + t}.summary
			generate_summary(summary)
			after_generate_report
		end

    protected

    def generate_summary(summary)
      raise NotImplementedError
    end
  
    def generate_query_line(diff)
      raise NotImplementedError
    end

    def summary_for_selected_differences(collection, &block)
      duration_diff = 0
      count_diff = 0
      process_differences(collection, &block).each do |diff|
        generate_query_line(diff)
        count_diff += diff.delta_count
        duration_diff += diff.delta_time
      end
      totals = SqlReporter::Total.new(count_diff, duration_diff)
      generate_summary(totals.summary)
      totals
    end
  
    def process_differences(collection)
      prefiltered_collection = collection.select { |key| yield(key) }
      differences = prefiltered_collection.map do |key| 
        construct_difference_object(key)
      end
      differences.sort_by {|d| d.sort_score(master_max_count) }.reverse
    end
  
    def construct_difference_object(key)
      m = master[key] || SqlReporter::Query.null(key)
      f = feature[key] || SqlReporter::Query.null(key)
      SqlReporter::Difference.new(key, m, f)
    end

    def before_generate_report
      raise NotImplementedError
    end

    def after_generate_report
      raise NotImplementedError
    end

    def before_increases
      raise NotImplementedError
    end

    def before_decreases
      raise NotImplementedError
    end

    def before_gone
      raise NotImplementedError
    end

    def before_spawned
      raise NotImplementedError
    end

    def before_summary
      raise NotImplementedError
    end
  end
end