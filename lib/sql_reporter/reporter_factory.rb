module SqlReporter
  class ReporterFactory
    attr_reader :parser_hsh

    def initialize
      @parser_hsh = SqlReporter::Parser.parse
    end

    def for_format
      case parser_hsh[:format]
      when 'log'
        log_reporter
      when 'json'
        json_reporter
      when 'png'
        plot_reporter
      when 'pdf'
        pdf_reporter
      when 'xls'
        excel_reporter
      else
        pdf_reporter
      end
    end

    private

    def log_reporter
      SqlReporter::Reporters::LogReporter.new(parser_hsh)
    end

    def json_reporter
      SqlReporter::Reporters::JsonReporter.new(parser_hsh)
    end

    def plot_reporter
      SqlReporter::Reporters::PlotReporter.new(parser_hsh)
    end

    def pdf_reporter
      SqlReporter::Reporters::PdfReporter.new(parser_hsh)
    end

    def excel_reporter
      SqlReporter::Reporters::ExcelReporter.new(parser_hsh)
    end
  end
end