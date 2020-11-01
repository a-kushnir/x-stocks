module Etl
  module Refresh
    class Slickcharts < Base

      def all_stocks!(&block)
        logger = nil

        block.call processing_message 0
        list = Etl::Extract::Slickcharts.new(logger: logger).sp500
        Etl::Transform::Slickcharts.new(logger).sp500(list)

        block.call processing_message 33
        list = Etl::Extract::Slickcharts.new(logger: logger).nasdaq100
        Etl::Transform::Slickcharts.new(logger).nasdaq100(list)

        block.call processing_message 67
        list = Etl::Extract::Slickcharts.new(logger: logger).dowjones
        Etl::Transform::Slickcharts.new(logger).dowjones(list)

        block.call completed_message
      end

    end
  end
end
