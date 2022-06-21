# frozen_string_literal: true

user = XStocks::AR::User.new(email: 'xstocks@example.com', password: 'xStocks!')
XStocks::User.new.save(user)
