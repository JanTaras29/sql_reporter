#frozen_string_literal: true
require 'spreadsheet'

module SqlReporter
	module Reporters
		class ExcelReporter < LogReporter
			EXTENSION = '.xls'
			HEADERS = ['Query', 'Count [master]', 'Count [feature]', 'Total time [master]', 'Total time [feature]']

			attr_reader :totals

			protected

			def generate_summary(totals)
				@totals = totals
			end

			def generate_query_line(diff)
				lines << diff
			end

			def before_generate_report
				@lines = []
			end

			def after_generate_report
				@totals = totals
				@lines = lines.sort_by {|d| d.sort_score(master_max_count) }.reverse
				book = Spreadsheet::Workbook.new
				sheet = book.create_worksheet(name: "Comparison Report #{fname0} -> #{fname1}") 
				sheet.row(0).concat HEADERS
				lines.each_with_index do |l, i|
					sheet.row(i + 1).concat [l.query_name, l.master.count, l.feature.count, l.master.duration_formatted, l.feature.duration_formatted]
				end
				sheet[lines.size + 1, 0] = 'Totals:'
				sheet[lines.size + 1, 1] = lines.reduce(0) {|acc, l| acc + l.master.count }
				sheet[lines.size + 1, 2] = lines.reduce(0) {|acc, l| acc + l.feature.count }
				sheet[lines.size + 1, 3] = lines.reduce(0) {|acc, l| acc + l.master.duration_formatted }
				sheet[lines.size + 1, 4] = lines.reduce(0) {|acc, l| acc + l.feature.duration_formatted }
				sheet[lines.size + 3, 1] = 'Count Increase:'
				sheet[lines.size + 3, 2] = sheet[lines.size + 1, 2] - sheet[lines.size + 1, 1]
				sheet[lines.size + 3, 3] = 'Time Increase:'
				sheet[lines.size + 3, 4] = sheet[lines.size + 1, 4] - sheet[lines.size + 1, 3]
				book.write "./#{output_file}"
			end

			def before_increases
			end

			def before_decreases
			end

			def before_gone
			end

			def before_spawned
			end

			def before_summary
			end
			
		end
	end
end