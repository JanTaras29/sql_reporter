#frozen_string_literal: true

require 'json'

class Reporter
	LOG_NAME = "comparison.log"

	def initialize(parser_hsh)
		@fname0, @master = parser_hsh.entries[0]
		@fname1, @feature = parser_hsh.entries[1]
		@master_max_count = @master.values.map(&:count).max
	end

	attr_accessor :master, :feature, :fname0, :fname1, :io
	attr_reader :master_max_count

	def generate_report
		@io = File.open(LOG_NAME, "w")
		totals = []
		
		io.write("SQL Query Count Decreases between #{fname0} -> #{fname1}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key].count > feature[key].count }

		io.write("SQL Query Count Increases between #{fname0} -> #{fname1}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(master.keys | feature.keys) { |key| master[key] && feature[key] && master[key].count < feature[key].count }

		io.write("SQL New Queries between #{fname0} -> #{fname1}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(feature.keys - master.keys) { |key| feature[key] }

		io.write("SQL Gone Queries between #{fname0} -> #{fname1}\n")
		io.write("##########################################################\n")
		totals << summary_for_selected_triplets(master.keys - feature.keys) { |key| master[key] }

		io.write("################## SUMMARY #####################\n")
		summary = totals.reduce(SqlReporter::Total.new(0,0)) {|acc, t| acc + t}.summary
		io.write(summary)
		io.close
	end

	private

	def summary_for_selected_triplets(collection, &block)
		duration_diff = 0
		count_diff = 0
		process_triplets(collection, &block).each do |key, queries|
			io.write("Difference for #{key}:\n")
			io.write("Count difference: #{queries['master'].count} -> #{queries['feature'].count}\n")
			io.write("Duration difference [ms]: #{queries['master'].duration_formatted} -> #{queries['feature'].duration_formatted}\n")
			diff = queries['feature'] - queries['master']
			count_diff += diff.count
			duration_diff += diff.duration_formatted
		end
		totals  = SqlReporter::Total.new(count_diff, duration_diff)
		io.write(totals.summary)
		totals
	end

	def process_triplets(collection)
		prefiltered_collection = collection.select { |key| yield(key) }
		triplets = prefiltered_collection.map do |key| 
			[key, construct_query_comparison_hash(key)]
		end
		triplets.sort_by {|t| (t[1]['master'] - t[1]['feature']).count.abs + t[1]['master'].post_decimal_score(master_max_count) }.reverse.to_h
	end

	def construct_query_comparison_hash(key)
		{
			'master' => master[key] || SqlReporter::Query.null(key),
			'feature' => feature[key] || SqlReporter::Query.null(key)
		}
	end
end