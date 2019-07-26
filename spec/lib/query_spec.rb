# frozen_string_literal: true

require 'spec_helper'

describe SqlReporter::Query do
  let(:sample_query) { 'SELECT foo FROM bar WHERE bar.id = xxx' }

  describe '#self.null' do
    subject { described_class.null(sample_query) }
    it 'creates a record with zeroed count and duration' do
      expect(subject.sql).to eql sample_query
      expect(subject.count).to be_zero
      expect(subject.duration).to be_zero
    end
  end

  describe 'instance methods' do
    let(:query) { SqlReporter::Query.new(sample_query, 8, 7.6433 ) }
    let(:other) { SqlReporter::Query.new(sample_query, 6 , 5.1443 ) }
    subject { query }

    describe 'arithmethics' do
      context 'additon' do
        subject { query + other }
        it 'has the same name as first parent and the count and time are sum of both parents values' do
          expect(subject.sql). to eql query.sql
          expect(subject.count). to eql query.count + other.count
          expect(subject.duration). to eql query.duration + other.duration
        end
      end

      context 'subtraction' do
        subject { query - other }
        it 'has the same name as first parent and the count and time are difference of both parents values' do
          expect(subject.sql). to eql query.sql
          expect(subject.count). to eql query.count - other.count
          expect(subject.duration). to eql query.duration - other.duration
        end
      end
    end

    describe '#duration_formatted' do
      it 'returns duration rounded to 2 decimal points' do
        expect(subject.duration_formatted).to eql subject.duration.round(2)
      end
    end

    describe '#post_decimal_score' do
      let(:max_score_seed) { rand subject.count..200 }
      it 'returns score based on count of queries and its relation to the biggest count' do
        expect(subject.post_decimal_score(max_score_seed)).to eql subject.count * (1 / (max_score_seed + 1))
      end
    end
  end
end