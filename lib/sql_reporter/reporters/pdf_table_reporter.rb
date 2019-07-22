#frozen_string_literal: true
require 'prawn/table'

module SqlReporter
	module Reporters
		class PdfTableReporter < LogReporter

			attr_reader :totals

			def produce_table(pdf_context)
				t = pdf_context.make_table([HEADERS, *lines])
				t.draw
				pdf_context.move_down(20)
				pdf_context.font_size(12) { pdf_context.text(totals.summary, styles: [:bold]) }
			end

			protected

			def generate_summary(totals)
				@totals = totals 
			end

			def generate_query_line(diff)
				lines << [diff.query_name, "#{diff.master.count} -> #{diff.feature.count}", "#{diff.master.duration_formatted} -> #{diff.feature.duration_formatted}"]
			end

			def before_generate_report
				@lines = []
			end

			def after_generate_report
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