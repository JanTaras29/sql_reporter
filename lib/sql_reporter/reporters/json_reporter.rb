module SqlReporter
  module Reporters
    class JsonReporter < Reporter
      LOG_NAME = 'comparison.json'

      attr_reader :lines, :title, :body

      protected

      def generate_summary(totals)
        hsh = { count_increase: totals.query_diff , duration_increase: totals.duration_diff.round(2) }
        hsh[:queries] = lines unless lines.empty?
        body[title] = hsh
        @lines = []
      end

      def generate_query_line(diff)
        hsh = {
          name: diff.query_name,
          count: {before: diff.master.count, after: diff.feature.count},
          duration: {before: diff.master.duration_formatted, after: diff.feature.duration_formatted}
        }
        lines << hsh
      end

      def before_generate_report
        @lines = []
        @body = {}
      end

      def after_generate_report
        io.write(body.to_json)
        io.close
      end

      def before_increases
        @title = 'increases'
      end

      def before_decreases
        @title = 'decreases'
      end

      def before_gone
        @title = 'gone'
      end

      def before_spawned
        @title = 'spawned'
      end

      def before_summary
        @title = 'total'
      end
    end
  end
end