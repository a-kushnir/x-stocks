# frozen_string_literal: true

exchanges = [
  {
    name: 'Bats Global Markets',
    code: 'BATS',
    region: 'United States',
    iexapis_code: nil,
    webull_code: 'amex',
    finnhub_code: 'BATS EXCHANGE',
    tradingview_code: 'AMEX',
    dividend_code: 'NASDAQ'
  },
  {
    name: 'NYSE',
    code: 'MKT',
    region: 'United States',
    iexapis_code: 'NYSE MKT LLC',
    webull_code: 'AMEX',
    finnhub_code: 'NYSE MKT LLC',
    tradingview_code: 'AMEX',
    dividend_code: 'AMEX'
  },
  {
    name: 'NYSE Arca',
    code: 'AMEX',
    region: 'United States',
    iexapis_code: 'NYSE Arca',
    webull_code: 'nysearca',
    finnhub_code: nil,
    tradingview_code: 'AMEX',
    dividend_code: 'AMEX'
  },
  {
    name: 'Nasdaq',
    code: 'NASDAQ',
    region: 'United States',
    iexapis_code: 'NASDAQ',
    webull_code: 'nasdaq',
    finnhub_code: 'NASDAQ NMS - GLOBAL MARKET',
    tradingview_code: 'NASDAQ',
    dividend_code: 'NASDAQ'
  },
  {
    name: 'New York Stock Exchange',
    code: 'NYSE',
    region: 'United States',
    iexapis_code: 'New York Stock Exchange',
    webull_code: 'nyse',
    finnhub_code: 'NEW YORK STOCK EXCHANGE, INC.',
    tradingview_code: 'NYSE',
    dividend_code: 'NYSE'
  },
  {
    name: 'Toronto Stock Exchange',
    code: 'TSX',
    region: 'Canada',
    iexapis_code: 'US OTCv',
    webull_code: 'otcmkts',
    finnhub_code: 'OTC MARKETS',
    tradingview_code: 'OTC',
    dividend_code: 'OTC'
  }
]

XStocks::AR::Exchange.create!(exchanges)
