#! usr/env/ruby

require 'json'

if ARGV.size != 2
	print_usage
	raise StandardError, 'You need to provide 2 files in order to compare them' 
end

begin
	f0 = File.read(ARGV[0])
	f1 = File.read(ARGV[1])
rescue StandardError => e
	puts e.message
	exit(1)
end
LOG_NAME = "comparison.log"

begin
	master = JSON.load(f0)['data'].values.map { |v| [v['sql'], v['count']] }.to_h
	feature = JSON.load(f1)['data'].values.map { |v| [v['sql'], v['count']] }.to_h
rescue JSON::ParserError
	error 'One of the files provided is not a correctly formatted JSON file'
end

File.open(LOG_NAME, "w") do |io| 
	io.write("SQL Query Count Decreases between #{ARGV[0]} -> #{ARGV[1]}\n")
	io.write("##########################################################\n")
	(master.keys | feature.keys).each do |key|
		next unless master[key] && feature[key] && master[key] > feature[key]
		io.write("Difference for #{key}:\n")
		io.write("Count drop: #{master[key]} -> #{feature[key]}\n")
	end
	io.write("SQL Query Count Increases between #{ARGV[0]} -> #{ARGV[1]}\n")
	io.write("##########################################################\n")
	(master.keys | feature.keys).each do |key|
		next unless master[key] && feature[key] && master[key] < feature[key]
		io.write("Difference for #{key}:\n")
		io.write("Count difference: #{master[key]} -> #{feature[key]}\n")
	end

	io.write("SQL New Queries between #{ARGV[0]} -> #{ARGV[1]}\n")
	io.write("##########################################################\n")
	(feature.keys - master.keys).each do |key|
		next unless feature[key]
		io.write("Difference for #{key}:\n")
		io.write("Count difference: 0 -> #{feature[key]}\n")
	end

	io.write("SQL Gone Queries between #{ARGV[0]} -> #{ARGV[1]}\n")
	io.write("##########################################################\n")
	(master.keys - feature.keys).each do |key|
		next unless master[key]
		io.write("Difference for #{key}:\n")
		io.write("Count difference: #{master[key]} -> 0\n")
	end
end

def print_usage
	puts "Usage: ruby comparison.rb first_file.json second_file.json"
end

