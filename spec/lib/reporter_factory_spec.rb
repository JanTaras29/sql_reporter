# frozen_string_literal: true

require 'spec_helper'

describe SqlReporter::ReporterFactory do
  let(:parser_hash) { {file0: {}, file1: {}} }

  before do
    allow(SqlReporter::Parser).to receive(:parse).and_return(parser_hash)
  end

  describe '#for_format' do
    context 'unparametrised behaviour' do
      it 'returns pdf reporter' do
        expect(subject.for_format.is_a?(SqlReporter::Reporters::PdfReporter)).to be_truthy
      end
    end

    describe 'with format param' do
      let(:format) { nil }
      let(:parser_hash) do
        {file0: {}, file1: {}, format: format }
      end
      context 'for log format' do
        let(:format) { 'log' }
        subject { described_class.new }
        it 'returns log reporter' do
          expect(subject.for_format.is_a?(SqlReporter::Reporters::LogReporter)).to be_truthy
        end
      end
  
      context 'for json format' do
        let(:format) { 'json' }
        subject { described_class.new }
        it 'returns json reporter' do
          expect(subject.for_format.is_a?(SqlReporter::Reporters::JsonReporter)).to be_truthy
        end
      end
  
      context 'for xls format' do
        let(:format) { 'xls' }
        subject { described_class.new }
        it 'returns excel reporter' do
          expect(subject.for_format.is_a?(SqlReporter::Reporters::ExcelReporter)).to be_truthy
        end
      end
  
      context 'for png format' do
        let(:format) { 'png' }
        subject { described_class.new }
        it 'returns png reporter' do
          expect(subject.for_format.is_a?(SqlReporter::Reporters::PlotReporter)).to be_truthy
        end
      end

      context 'for pdf format' do
        let(:format) { 'pdf' }
        subject { described_class.new }
        it 'returns pdf reporter' do
          expect(subject.for_format.is_a?(SqlReporter::Reporters::PdfReporter)).to be_truthy
        end
      end
    end
  end
end