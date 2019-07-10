#! usr/env/ruby

require 'json'

class Comparator
	LOG_NAME = "comparison.log"

	attr_accessor :master, :feature, :f0, :f1, :io

	def initialize
		load_files
	end

	def generate_report
		@io = File.open(LOG_NAME, "w")

		io.write("SQL Query Count Decreases between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		summary_for_selected_triplets(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key] > feature[key] }

		io.write("SQL Query Count Increases between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		summary_for_selected_triplets(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key] < feature[key] }

		io.write("SQL New Queries between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		summary_for_selected_triplets(feature.keys - master.keys) { |key| feature[key] }

		io.write("SQL Gone Queries between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		summary_for_selected_triplets(master.keys - feature.keys) { |key| master[key] }

		io.close()
	end

	private

	
	def summary_for_selected_triplets(collection, &block)
		process_triplets(collection, &block).each do |key, counts|
			io.write("Difference for #{key}:\n")
			io.write("Count difference: #{counts[0]} -> #{counts[1]}\n")
		end
	end

	def process_triplets(collection)
		triplets = collection.select { |key| yield(key) }.map { |key| [key, [master[key] || 0, feature[key] || 0]] }
		triplets.sort_by {|t| (t[1][0] - t[1][1]).abs + t[1][0]* 0.000001 }.reverse.to_h
	end
	
	def print_usage
		puts "Usage: ruby comparison.rb first_file.json second_file.json"
	end

	def load_files
		begin
			@f0 = File.read(ARGV[0])
			@f1 = File.read(ARGV[1])
		rescue StandardError => e
			puts e.message
			exit(1)
		end

		begin
			@master = JSON.load(f0)['data'].values.map { |v| [v['sql'], v['count']] }.to_h
			@feature = JSON.load(f1)['data'].values.map { |v| [v['sql'], v['count']] }.to_h
		rescue JSON::ParserError
			error 'One of the files provided is not a correctly formatted JSON file'
		end
	end

	def ensure_params_passed
		if ARGV.size != 2
			print_usage
			raise StandardError, 'You need to provide 2 files in order to compare them' 
		end
	end
end


Comparator.new.generate_report

