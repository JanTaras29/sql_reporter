# frozen_string_literal: true

require 'spec_helper'

describe SqlReporter::Total do
  let(:total) { described_class.new(4, 9.82) }
  let(:other) { described_class.new(-5, -23.4) }
  subject { total }
  
  describe 'default constructor' do
    subject { described_class.new }
    it 'initalizes totals object with zeroed query and duration diff' do
      expect(subject.query_diff).to be_zero
      expect(subject.duration_diff).to be_zero
    end
  end

  describe 'arithmetics' do
    context 'sum' do
      subject { total + other }
      it 'has the summed count and duration_diff' do
        expect(subject.query_diff).to eql total.query_diff + other.query_diff
        expect(subject.duration_diff).to eql total.duration_diff + other.duration_diff
      end
    end
  end

  describe '#query_drop' do
    context 'for positive count diff' do
      it 'defaults to zero' do
        expect(subject.query_drop).to be_zero
      end
    end

    context 'for negative count diff' do
      subject { other }
      it 'is the negative of count_diff' do
        expect(subject.query_drop).to eql -subject.query_diff
      end
    end
  end

  describe '#query_gain' do
    context 'for positive count diff' do
      it 'is the count_diff' do
        expect(subject.query_gain).to eql subject.query_diff
      end
    end

    context 'for negative count diff' do
      subject { other }
      it 'defaults to zero' do
        expect(subject.query_gain).to be_zero
      end
    end
  end

  describe '#summary' do
    let(:expectation) do
      "\nQueries count change: #{subject.query_diff}\n\nDuration #{subject.duration_diff > 0 ? 'gain' : 'decrease' }[ms]: #{subject.duration_diff.abs.round(2)}\n\n"
    end
    it 'prints the summary of the total' do
      expect(subject.summary).to eql expectation
    end
  end
end