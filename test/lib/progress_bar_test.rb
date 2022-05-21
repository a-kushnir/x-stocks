# frozen_string_literal: true

require 'test_helper'
require 'progress_bar'

class ProgressBarTest < ActiveSupport::TestCase
  test 'iterates array' do
    lines = []
    progress_bar = ProgressBar.new
    progress_bar.loop(%w[A B C]) do |node|
      lines << [node.progress.min.round, node.object]
    end
    assert_equal([[0, 'A'], [33, 'B'], [67, 'C']], lines)
  end

  test 'iterates steps' do
    lines = []
    progress_bar = ProgressBar.new
    progress_bar.steps do |steps|
      steps.step(weight: 2) { |node| lines << [node.progress.min.round, 'M'] }
      steps.step(weight: 1) { |node| lines << [node.progress.min.round, 'S'] }
      steps.step(weight: 4) { |node| lines << [node.progress.min.round, 'L'] }
    end

    assert_equal([[0, 'M'], [29, 'S'], [43, 'L']], lines)
  end

  test 'iterates array with sub-steps' do
    items = []
    progress_bar = ProgressBar.new
    progress_bar.loop(%w[A B C]) do |node|
      node.steps do |steps|
        steps.step(weight: 2) { |subnode| items << [subnode.progress.min.round, "M#{node.object}"] }
        steps.step(weight: 1) { |subnode| items << [subnode.progress.min.round, "S#{node.object}"] }
        steps.step(weight: 4) { |subnode| items << [subnode.progress.min.round, "L#{node.object}"] }
      end
    end
    assert_equal([[0, 'MA'], [10, 'SA'], [14, 'LA'], [33, 'MB'], [43, 'SB'], [48, 'LB'], [67, 'MC'], [76, 'SC'], [81, 'LC']], items)
  end

  test 'iterates steps with sub-arrays' do
    items = []
    progress_bar = ProgressBar.new

    progress_bar.steps do |steps|
      steps.step(weight: 2) { |node| node.loop(%w[A B C]) { |subnode| items << [subnode.progress.min.round, "M#{subnode.object}"] } }
      steps.step(weight: 1) { |node| node.loop(%w[A B C]) { |subnode| items << [subnode.progress.min.round, "S#{subnode.object}"] } }
      steps.step(weight: 4) { |node| node.loop(%w[A B C]) { |subnode| items << [subnode.progress.min.round, "L#{subnode.object}"] } }
    end
    assert_equal([[0, 'MA'], [10, 'MB'], [19, 'MC'], [29, 'SA'], [33, 'SB'], [38, 'SC'], [43, 'LA'], [62, 'LB'], [81, 'LC']], items)
  end
end
