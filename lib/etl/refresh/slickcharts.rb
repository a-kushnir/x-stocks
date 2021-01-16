# frozen_string_literal: true

module Etl
  module Refresh
    class Slickcharts < Base
      def all_stocks!
        Service.lock(:slickcharts, force: true) do |logger|
          data_loader = Etl::Extract::DataLoader.new(logger)

          yield processing_message 0 if block_given?
          list = Etl::Extract::SlickCharts.new(data_loader).sp500
          Etl::Transform::Slickcharts.new.sp500(list)

          yield processing_message 33 if block_given?
          list = Etl::Extract::SlickCharts.new(data_loader).nasdaq100
          Etl::Transform::Slickcharts.new.nasdaq100(list)

          yield processing_message 67 if block_given?
          list = Etl::Extract::SlickCharts.new(data_loader).dow_jones
          Etl::Transform::Slickcharts.new.dowjones(list)

          yield completed_message if block_given?
        end
      end
    end
  end
end
