module Etl
  module Refresh
    class Slickcharts

      def all_stocks!
        logger = nil

        list = Etl::Extract::Slickcharts.new(logger: logger).sp500
        Etl::Transform::Slickcharts.new(logger).sp500(list)

        list = Etl::Extract::Slickcharts.new(logger: logger).nasdaq100
        Etl::Transform::Slickcharts.new(logger).nasdaq100(list)

        list = Etl::Extract::Slickcharts.new(logger: logger).dowjones
        Etl::Transform::Slickcharts.new(logger).dowjones(list)
      end

    end
  end
end
