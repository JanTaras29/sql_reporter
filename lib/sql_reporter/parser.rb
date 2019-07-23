# frozen_string_literal: true

require 'json'
require 'optparse'

module SqlReporter
  class Parser
    def self.parse
      options = {}
      OptionParser.new do |opts|
        opts.banner = 'Usage: sql_reporter [options] file.json file2.json'

        opts.on('-f', '--format FORMAT', String, 'Format of the output file (defaults to pdf, avaliable formats: log , json, png, pdf, xls )') do |f|
          options[:format] = f
        end

        opts.on('-o', '--output FILE', String, 'File to write the report to - without extension') do |o|
          options[:output] = o
        end

        opts.on_tail('--version', 'Show version') do
          puts SqlReporter::VERSION
          exit
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end.parse!

      unless ARGV.size == 2
        STDERR.puts "[ERROR] Incorrect number of parameters passed (2 files required)"
        exit(1)
      end

      begin
        f0 = File.read(ARGV[0])
        f1 = File.read(ARGV[1])
      rescue StandardError => e
        puts e.message
        exit(1)
      end
  
      begin
        master = JSON.load(f0)['data'].values.map { |v| [v['sql'], SqlReporter::Query.new(v['sql'], v['count'], v['duration'])] }.to_h
        feature = JSON.load(f1)['data'].values.map { |v| [v['sql'], SqlReporter::Query.new(v['sql'], v['count'], v['duration'])] }.to_h
      rescue JSON::ParserError
        STDERR.puts 'One of the files provided is not a correctly formatted JSON file'
        exit(1)
      end

      master_key = ARGV[0]
      feature_key = ARGV[0] == ARGV[1] ? ARGV[0] + '_copy' : ARGV[1]

      { master_key => master, feature_key => feature, format: options[:format] }.merge(options)
    end
  end
end