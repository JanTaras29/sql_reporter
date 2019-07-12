# frozen_string_literal: true

module SqlReporter
  class Parser
    def self.parse
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

      { ARGV[0] => master, ARGV[1] => feature }
    end
  end
end