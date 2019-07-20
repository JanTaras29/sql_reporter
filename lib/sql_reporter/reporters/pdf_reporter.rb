require 'prawn'

module SqlReporter
  module Reporters
    class PdfReporter< Reporter
      LOG_NAME='comparison.pdf'

      attr_reader :plot_report, :log_report

      def initialize(parser_hsh)
        super(parser_hsh)
        @log_report = SqlReporter::Reporters::LogReporter.new(parser_hsh)
        @plot_report = SqlReporter::Reporters::PlotReporter.new(parser_hsh)
      end

      def after_generate_report
        log_report.generate_report
        plot_report.generate_report
        Prawn::Document.generate(output_file) do |pdf|
          pdf.text "Comparison report of #{@fname0} -> #{@fname1}"
          pdf.text 'Count changes:'
          pdf.image @plot_report.output_file
          pdf.text 'Timing changes:'
          pdf.image('time_' + @plot_report.output_file)
          pdf.text 'Summary'
          pdf.text File.read(@log_report.output_file)
         end
      end
    end
  end
end