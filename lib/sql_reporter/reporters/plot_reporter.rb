require 'gruff'

module SqlReporter
  module Reporters
    class PlotReporter < Reporter
      LOG_NAME = 'comparison.png'

      attr_reader :count_plot, :time_plot,  :diffs

      protected

      def before_generate_report
        @count_plot = Gruff::Bar.new(400)
        @time_plot = Gruff::Bar.new(400)
        @diffs = []
        count_plot.title = "Count #{fname0} > #{fname1}"
        count_plot.marker_count = 0
        count_plot.show_labels_for_bar_values = true
        time_plot.title = "Timing #{fname0} > #{fname1}"
        time_plot.marker_count = 0
        time_plot.show_labels_for_bar_values = true
      end
      
      def generate_query_line(diff)
        diffs << diff
      end

      def after_generate_report
        instert_plot_data(count_plot, :count)
        instert_plot_data(time_plot, :duration_formatted)
        count_plot.write(output_file)
        time_plot.write('time_' + output_file)
      end

      private

      def instert_plot_data(plot, method)
        diffs.each do |diff|
          plot.data(diff.query_name[0..20] + ' BEFORE', diff.master.public_send(method), '#990000')
          plot.data(diff.query_name[0..20] + ' AFTER', diff.feature.public_send(method), '#000099')
        end
      end
    end
  end
end