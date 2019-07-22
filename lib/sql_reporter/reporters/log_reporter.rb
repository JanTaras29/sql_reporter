#frozen_string_literal: true

require 'tty-table'

module SqlReporter
	module Reporters
		class LogReporter < Reporter
			EXTENSION = '.log'
			HEADERS = ['Query', 'Count difference', 'Duration difference [ms]']

			attr_reader :lines

			protected

			def generate_summary(totals)
				table = TTY::Table.new(HEADERS, lines).render(
					:ascii,
					column_widths: [120, 40, 40],
					multiline: true,
					resize: true,
				)
				io.write(table)
				io.write(totals.summary)
				@lines = []
			end

			def generate_query_line(diff)
				lines << [diff.query_name, "#{diff.master.count} -> #{diff.feature.count}", "#{diff.master.duration_formatted} -> #{diff.feature.duration_formatted}"]
			end

			def before_generate_report
				@lines = []
			end

			def after_generate_report
				io.close
			end

			def before_increases
				print_header('Count Increases')
			end

			def before_decreases
				print_header('Count Decreases')
			end

			def before_gone
				print_header('Gone')
			end

			def before_spawned
				print_header('Spawned')
			end

			def before_summary
				io.write("################## SUMMARY #####################\n")
			end
			
			private

			def print_header(header_name)
				io.write("SQL #{header_name} between #{fname0} -> #{fname1}\n")
				io.write("##########################################################\n")
			end
		end
	end
end