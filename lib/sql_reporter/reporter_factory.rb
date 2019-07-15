module SqlReporter
  class ReporterFactory
    attr_reader :parser_hsh

    def initialize
      @parser_hsh = SqlReporter::Parser.parse
    end

    def log_reporter
      SqlReporter::LogReporter.new(parser_hsh)
    end
  end
end