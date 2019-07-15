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
      else
        log_reporter
      end
    end

    def log_reporter
      SqlReporter::LogReporter.new(parser_hsh)
    end

    def json_reporter
      SqlReporter::JsonReporter.new(parser_hsh)
    end
  end
end