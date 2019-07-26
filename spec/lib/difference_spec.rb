# frozen_string_literal: true

require 'spec_helper'

describe SqlReporter::Difference do
  let(:sample_query) { 'SELECT foo FROM bar WHERE bar.id = xxx' }
  let(:master) { SqlReporter::Query.new(sample_query, 8, 7.64 ) }
  let(:feature) { SqlReporter::Query.new(sample_query, 6 , 5.14 ) }
  subject { SqlReporter::Difference.new(sample_query, master, feature) }

  describe '#delta_count' do
    it 'is equal to the difference of query number between master and feature' do
      expect(subject.delta_count).to eql (feature - master).count
    end
  end

  describe '#delta_time' do
    it 'is equal to the difference of time consumed by the query type between master and feature rounder to 2' do
      expect(subject.delta_time).to eql (feature - master).duration.round(2)
    end
  end

  describe '#delta_timing' do
    it 'is equal to the absulute difference of query number plus the remainder from sort score of master' do
      expect(subject.sort_score(10)).to eql (feature - master).count.abs + master.post_decimal_score(10)
    end
  end
end