# frozen_string_literal: true

require 'json'
require 'optparse'

module SqlReporter
  class Parser
    def self.parse
      options = {format: 'log'}
      OptionParser.new do |opts|
        opts.banner = 'Usage: sql_reporter [options] file.json file2.json'

        opts.on('-f', '--format FORMAT', String, 'Format of the output file (defaults to log, avaliable formats: log , json )') do |f|
          options[:format] = f
        end

        opts.on('-o', '--output FILE', String, 'File to write the report to') do |o|
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
        STDERR.puts "[ERROR] Incorrect parameters passed"
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

      hsh = { ARGV[0] => master, ARGV[1] => feature, format: options[:format] }
      hsh.merge({output: options[:output]})
    end
  end
end