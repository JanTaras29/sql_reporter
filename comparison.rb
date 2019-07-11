#! usr/env/ruby

require 'json'
# Data struct for keeping the query data
Query = Struct.new(:sql, :count, :duration) do
	def duration_formatted
		duration&.round(2)
	end
end

Totals = Struct.new(:query_diff, :duration_diff) do
	def queries_msg
		"#{query_diff > 0 ? 'Queries spawned' : 'Queries killed' }: #{query_diff.abs}\n" 
	end

	def duration_msg
		"#{duration_diff > 0 ? 'Duration gain' : 'Duration decrease' }[ms]: #{duration_diff.abs.round(2)}\n"
	end

	def summary
		"##############\n" + queries_msg + duration_msg + "##############\n"
	end

	def +(total)
		self.class.new(query_diff + total.query_diff, duration_diff + total.duration_diff)
	end
end

class Comparator
	LOG_NAME = "comparison.log"

	attr_accessor :master, :feature, :f0, :f1, :io

	def initialize
		load_files
	end

	def generate_report
		@io = File.open(LOG_NAME, "w")
		totals = []

		io.write("SQL Query Count Decreases between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key].count > feature[key].count }

		io.write("SQL Query Count Increases between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key].count < feature[key].count }

		io.write("SQL New Queries between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(feature.keys - master.keys) { |key| feature[key] }

		io.write("SQL Gone Queries between #{ARGV[0]} -> #{ARGV[1]}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(master.keys - feature.keys) { |key| master[key] }

		io.write("################## SUMMARY #####################\n")
		summary = totals.reduce(Totals.new(0,0)) {|acc, t| acc + t}.summary
		io.write(summary)
		io.close
	end

	private

	def summary_for_selected_triplets(collection, &block)
		duration_diff = 0
		query_diff = 0
		process_triplets(collection, &block).each do |key, queries|
			io.write("Difference for #{key}:\n")
			io.write("Count difference: #{queries['master'].count} -> #{queries['feature'].count}\n")
			io.write("Duration difference [ms]: #{queries['master'].duration_formatted} -> #{queries['feature'].duration_formatted}\n")
			query_diff += queries['feature'].count - queries['master'].count
			duration_diff += queries['feature'].duration_formatted - queries['master'].duration_formatted
		end
		totals  = Totals.new(query_diff, duration_diff)
		io.write(totals.summary)
		totals
	end

	def process_triplets(collection)
		prefiltered_collection = collection.select { |key| yield(key) }
		triplets = prefiltered_collection.map do |key| 
			[key, construct_query_comparison_hash(master[key], feature[key], key)]
		end
		triplets.sort_by {|t| (t[1]['master'].count - t[1]['feature'].count).abs + t[1]['master'].count* 0.000001 }.reverse.to_h
	end

	def construct_query_comparison_hash(master, feature, key)
		hsh = {}
		hsh['master'] = master || null_query(key)
		hsh['feature'] = feature || null_query(key)
		hsh
	end

	def duration_summary(diff)
		"#{diff > 0 ? 'Duration gain' : 'Duration decrease' }[ms]: #{diff.abs}\n"
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
			@master = JSON.load(f0)['data'].values.map { |v| [v['sql'], Query.new(v['sql'], v['count'], v['duration'])] }.to_h
			@feature = JSON.load(f1)['data'].values.map { |v| [v['sql'], Query.new(v['sql'], v['count'], v['duration'])] }.to_h
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

	def null_query(query_name)
		Query.new(query_name, 0, 0)
	end
end


Comparator.new.generate_report

