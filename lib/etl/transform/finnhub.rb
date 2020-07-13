module Etl
  module Transform
    class Finnhub

      def company(stock, json)
        stock.ipo = json['ipo']
        stock.logo = json['logo']
        stock.save
      end

      def peers(stock, json)
        peers = (json || []).select { |p| p != stock.symbol }
        ::Tag.batch_update(stock, :stock_peer, peers)
      end

      def quote(stock, json)
        stock.current_price = json['c']
        stock.prev_close_price = json['pc']
        stock.open_price = json['o']
        stock.day_low_price = json['l']
        stock.day_high_price = json['h']
        stock.update_prices!
      end

      def recommendation(stock, json)
        json ||= []

        json.sort_by! { |row| Date.parse(row['period']) }
        json = json[-4..-1] if json.size > 4

        hash = {}
        json.each do |row|
          hash[Date.parse(row['period'])] = [
            row['strongBuy'],
            row['buy'],
            row['hold'],
            row['sell'],
            row['strongSell']
          ]
        end

        stock.finnhub_rec_details = hash
        stock.finnhub_rec = recommendation_mean(stock.finnhub_rec_details)
        stock.save
      end

      private

      def recommendation_mean(rec_details)
        return nil if rec_details.blank?

        value = total = 0
        rec_details.each do |_, data|
          value += 1 * data[0] + 2 * data[1] + 3 * data[2] + 4 * data[3] + 5 * data[4]
          total += data[0] + data[1] + data[2] + data[3] + data[4]
        end

        value.to_f / total
      end

    end
  end
end
