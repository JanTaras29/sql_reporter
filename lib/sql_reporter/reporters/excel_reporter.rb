#frozen_string_literal: true
require 'spreadsheet'

module SqlReporter
	module Reporters
		class ExcelReporter < LogReporter
			EXTENSION = '.xls'
			HEADERS = ['Query', 'Count [master]', 'Count [feature]', 'Total time [master]', 'Total time [feature]']

			attr_reader :totals

			protected

			def generate_summary(totals, **kwargs)
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
				totals_row_no = lines.size + 1
				accumulated_row = totals_row_no + 2
				sheet[totals_row_no, 0] = 'Totals:'
				sheet[totals_row_no, 1] = lines.reduce(0) {|acc, l| acc + l.master.count }
				sheet[totals_row_no, 2] = lines.reduce(0) {|acc, l| acc + l.feature.count }
				sheet[totals_row_no, 3] = lines.reduce(0) {|acc, l| acc + l.master.duration_formatted }
				sheet[totals_row_no, 4] = lines.reduce(0) {|acc, l| acc + l.feature.duration_formatted }
				sheet[accumulated_row, 1] = 'Count Increase:'
				sheet[accumulated_row, 2] = sheet[totals_row_no, 2] - sheet[totals_row_no, 1]
				sheet[accumulated_row, 3] = 'Time Increase:'
				sheet[accumulated_row, 4] = sheet[totals_row_no, 4] - sheet[totals_row_no, 3]

				bold = Spreadsheet::Format.new(weight: :bold)
				[totals_row_no, accumulated_row].each do |row|
					5.times { |x| sheet.row(row).set_format(x, bold) }
				end
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