#frozen_string_literal: true

require 'tty-table'

module SqlReporter
	module Reporters
		class LogReporter < Reporter
			EXTENSION = '.log'
			HEADERS = ['Query', 'Count difference', 'Cached SQLs difference', 'Duration difference [ms]']

			attr_reader :lines

			protected

			def generate_summary(totals, **kwargs)
				table = TTY::Table.new(HEADERS, lines).render(
					:ascii,
					column_widths: [100, 40, 40, 40],
					multiline: true,
					resize: true,
				)
				io.write(table)
				io.write("Queries reduced: #{kwargs[:reduced]}\n") if kwargs.key? :reduced
				io.write("Queries spawned: #{kwargs[:spawned]}\n") if kwargs.key? :spawned
				io.write(totals.summary)
				@lines = []
			end

			def generate_query_line(diff)
				lines << [diff.query_name, "#{diff.master.count} -> #{diff.feature.count}", "#{diff.master.cached_count} -> #{diff.feature.cached_count}", "#{diff.master.duration_formatted} -> #{diff.feature.duration_formatted}"]
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
				io.write("################## SUMMARY #####################\n\n")
			end

			def setup_io
				@io = Class.new do
					attr_reader :file, :console_disabled

					def initialize(file, disable_console = false)
						@file = File.open(file, "w")
						@console_disabled = disable_console
					end

					def write(content)
						file.write(content)
						STDOUT.write(content) unless console_disabled
					end

					def close
						file.close
					end
				end.new(output_file, disable_console)
      end
			
			private

			def print_header(header_name)
				io.write("SQL #{header_name} between #{fname0} -> #{fname1}\n")
				io.write("##########################################################\n")
			end
		end
	end
end