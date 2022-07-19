<a href="http://x-stocks.herokuapp.com/">
    <img src="https://raw.githubusercontent.com/a-kushnir/x-stocks/main/app/assets/images/favicon/favicon.svg" alt="xStocks logo" title="xStocks" align="right" height="60" />
</a>

# xStocks

[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-blue)](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-blue)
[![Language](https://img.shields.io/badge/language-ruby-orange)](https://img.shields.io/badge/language-ruby-orange)
[![Rails](https://img.shields.io/gem/v/rails?label=rails)](https://img.shields.io/gem/v/rails?label=rails)
[![Tailwind](https://img.shields.io/github/package-json/dependency-version/a-kushnir/x-stocks/tailwindcss?label=tailwind)](https://img.shields.io/github/package-json/dependency-version/a-kushnir/x-stocks/tailwindcss?label=tailwind)
[![Scrutinizer Code Quality](https://img.shields.io/scrutinizer/quality/g/a-kushnir/x-stocks/main)](https://img.shields.io/scrutinizer/quality/g/a-kushnir/x-stocks/main)
[![Scrutinizer Code Coverage](https://img.shields.io/scrutinizer/coverage/g/a-kushnir/x-stocks/main)](https://img.shields.io/scrutinizer/coverage/g/a-kushnir/x-stocks/main)
[![License](https://img.shields.io/github/license/a-kushnir/x-stocks)](https://img.shields.io/github/license/a-kushnir/x-stocks)

[xStocks](http://x-stocks.herokuapp.com/) is a Stock Data Aggregator website

# Table of contents

- [Screenshots](#screenshots)
    - [Home](#home)
    - [Stock](#stock)
    - [Portfolio](#portfolio)
    - [Dividends](#dividends)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
    - [API Keys](#api-keys)
    - [Users](#users)
- [License](#license)
- [Links](#links)

# Screenshots

[(Back to top)](#table-of-contents)

xStock is a website that allows to gather and analyze stock information from multiple sources and apply the data for your own portfolio.

## Home
News, vital market information with links to Sceeners and other important pages.

![home-page](https://user-images.githubusercontent.com/1454297/179772085-f1a05356-bb7a-435d-afa4-c68b83e0317b.png)

## Stock
All gathered information about a single stock.

![stock-information](https://user-images.githubusercontent.com/1454297/179772438-093d7d4e-693a-4994-96b7-a0423df9b2af.png)

## Portfolio
All gathered information about user portfolio. Information can be presented in Table or Chart mode or exported to Excel format.

![positions-table](https://user-images.githubusercontent.com/1454297/179772654-02b43282-c4b0-4028-a0bb-fb51cfc5bcf1.png)
![positions-charts](https://user-images.githubusercontent.com/1454297/179774298-a2ddd4d4-0a5a-4805-96d8-daf1b9389aef.png)

## Dividends
All gathered information about user dividends. Information can be presented in Table or Chart mode or exported to Excel format.

![divident-table](https://user-images.githubusercontent.com/1454297/179773148-9be67d15-484b-4b19-8035-e8cc69b0a551.png)
![divident-charts](https://user-images.githubusercontent.com/1454297/179774247-30912439-e0bd-4829-bbc0-61496fce84f2.png)

## API Documentation
The project has API that allows retrieving information about stocks, exhanges, and user portfolio. API Key and the documentation are available at My Profile page.

![api-documentation](https://user-images.githubusercontent.com/1454297/109259195-f307e200-77b8-11eb-8a0f-7936b16daecb.png)

# Requirements

[(Back to top)](#table-of-contents)

* Linux or macOS or Windows
* PostgreSQL, [download](https://www.postgresql.org/download/)
* Ruby 2.7.5 or later, [download](https://www.ruby-lang.org/en/downloads/)
* Node 16 or later, [download](https://nodejs.org/en/download/)
* Yarn 1.22 or later, [download](https://classic.yarnpkg.com/en/docs/install/)
* Git

# Installation

[(Back to top)](#table-of-contents)

Install PostgreSQL and create _x_stocks_ user or update _config/database.yml_ file to match existing configuration.

To build and run this application locally, you'll need latest versions of Git, Ruby, Yarn and Node installed on your computer. From your command line:

```
# Clone this repository
$ git clone https://github.com/a-kushnir/x-stocks.git

# Go into the repository
$ cd x-stocks

# Install gems
$ bundle

# Install packages
$ yarn install

# Create the database, loads the schema, and initialize it with the seed data
$ rails db:setup

# Run the app
$ rails s
```

# Configuration

[(Back to top)](#table-of-contents)

## API Keys

### Finnhub Stock API
* Sign up on https://finnhub.io/
* Copy API Key (example: bueso4n48v6tiubaqv70)
* Add environment variable FINNHUB_KEY with the copied value
* You can use multiple keys to overcome free account limitations, use variables like FINNHUB_KEY_2, FINNHUB_KEY_3 and so on

### Polygon Stock API
* Sign up on https://polygon.io/
* Copy API Key (example: ABabcd4U2aBc1or234rYO_HELPMEhaha)
* Add environment variable POLYGON_KEY with the copied value
* You can use multiple keys to overcome free account limitations, use variables like POLYGON_KEY_2, POLYGON_KEY_3 and so on

### IEX Cloud API
* Sign up on https://iexcloud.io/
* Copy API Token (example: pk_e735a31e0a593e7db8c38c9ce04632e7)
* Add environment variable IEXAPIS_KEY with the copied value
* You can use multiple keys to overcome free account limitations, use variables like IEXAPIS_KEY_2, IEXAPIS_KEY_3 and so on

### Environment variables

Learn more about environment variables:
* [RubyMine](https://www.jetbrains.com/help/objc/add-environment-variables-and-program-arguments.html)
* [Heroku](https://devcenter.heroku.com/articles/config-vars)

## Users

See [db/seeds/users.rb](https://github.com/a-kushnir/x-stocks/blob/main/db/seeds/users.rb) for default credentials.

# License

[(Back to top)](#table-of-contents)

xStocks is under the MIT license. See the [LICENSE](https://github.com/a-kushnir/x-stocks/blob/main/LICENSE) for more information.

# Links

[(Back to top)](#table-of-contents)

* [Live version](http://x-stocks.herokuapp.com/) on Heroku
* [API Documentation](http://x-stocks.herokuapp.com/api_docs) on Heroku
* [Source code](https://github.com/a-kushnir/x-stocks)
