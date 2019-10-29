module SqlReporter
  module Reporters
    class Reporter
      EXTENSION=''

      def initialize(parser_hsh)
        @fname0, @master = parser_hsh.entries[0]
        @fname1, @feature = parser_hsh.entries[1]
        @master_max_count = @master.values.map(&:count).max
        @output = parser_hsh[:output] if parser_hsh.key?(:output)
        @disable_console = parser_hsh[:disable_console] if parser_hsh.key?(:disable_console)
      end
    
      attr_accessor :master, :feature, :fname0, :fname1, :output, :io
      attr_reader :master_max_count, :disable_console

      def generate_report
        setup_io
        before_generate_report
        totals = []
        
        before_decreases
        totals << summary_for_selected_differences(master.keys | feature.keys) do |key| 
          master[key] && feature[key] && (
            master[key].count > feature[key].count || (master[key].count == feature[key].count &&  master[key].cached_count > feature[key].cached_count)
          )
        end

        before_increases
        totals << summary_for_selected_differences(master.keys | feature.keys) do |key|
          master[key] && feature[key] && (
            master[key].count < feature[key].count || (master[key].count == feature[key].count && master[key].cached_count < feature[key].cached_count)
          )
        end

        before_spawned
        totals << summary_for_selected_differences(feature.keys - master.keys) { |key| feature[key] }

        before_gone
        totals << summary_for_selected_differences(master.keys - feature.keys) { |key| master[key] }

        before_summary
        totals_sum = totals.reduce(SqlReporter::Total.new(0,0,0)) {|acc, t| acc + t}
        additional_data = {}
        additional_data[:reduced] = totals.reduce(0) {|acc, t| acc + t.query_drop}
        additional_data[:spawned] = totals.reduce(0) {|acc, t| acc + t.query_gain}
        generate_summary(totals_sum, **additional_data)
        after_generate_report
        print_success_message
      end

      def output_file
        (output || 'comparison') + self.class::EXTENSION
      end

      protected

      def generate_summary(totals, **kwargs)
      end
    
      def generate_query_line(diff)
      end

      def summary_for_selected_differences(collection, &block)
        duration_diff = 0
        cached_count_diff = 0
        count_diff = 0
        process_differences(collection, &block).each do |diff|
          generate_query_line(diff)
          count_diff += diff.delta_count
          cached_count_diff += diff.delta_cached_count
          duration_diff += diff.delta_time
        end
        totals = SqlReporter::Total.new(count_diff, duration_diff, cached_count_diff)
        generate_summary(totals)
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
      end

      def after_generate_report
      end

      def before_increases
      end

      def before_decreases
      end

      def before_gone
      end

      def before_spawned
      end

      def before_summary
      end

      def setup_io
        @io = File.open(output_file, "w")
      end

      private

      def print_success_message
        puts "[Comparison Successful] Comparison report written to: #{`pwd`.strip + '/' + output_file}"
      end
    end
  end
end