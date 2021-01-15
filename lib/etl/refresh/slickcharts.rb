# frozen_string_literal: true

module Etl
  module Refresh
    class Slickcharts < Base
      def all_stocks!(&block)
        Service.lock(:slickcharts, force: true) do |logger|
          data_loader = Etl::Extract::DataLoader.new(logger)

          block.call processing_message 0 if block_given?
          list = Etl::Extract::SlickCharts.new(data_loader).sp500
          Etl::Transform::Slickcharts.new.sp500(list)

          block.call processing_message 33 if block_given?
          list = Etl::Extract::SlickCharts.new(data_loader).nasdaq100
          Etl::Transform::Slickcharts.new.nasdaq100(list)

          block.call processing_message 67 if block_given?
          list = Etl::Extract::SlickCharts.new(data_loader).dowjones
          Etl::Transform::Slickcharts.new.dowjones(list)

          block.call completed_message if block_given?
        end
      end
    end
  end
end
