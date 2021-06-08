# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from www.slickcharts.com
    class SlickCharts < Base
      def all_stocks
        yield processing_message 0 if block_given?
        list = Etl::Extract::SlickCharts.new(loader).sp500
        Etl::Transform::SlickCharts.new.sp500(list)

        yield processing_message 33 if block_given?
        list = Etl::Extract::SlickCharts.new(loader).nasdaq100
        Etl::Transform::SlickCharts.new.nasdaq100(list)

        yield processing_message 67 if block_given?
        list = Etl::Extract::SlickCharts.new(loader).dow_jones
        Etl::Transform::SlickCharts.new.dow_jones(list)

        yield completed_message if block_given?
      end
    end
  end
end
