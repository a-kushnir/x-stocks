<a href="http://x-stocks.herokuapp.com/">
    <img src="https://raw.githubusercontent.com/a-kushnir/x-stocks/main/public/img/favicons/favicon.svg" alt="xStocks logo" title="xStpcks" align="right" height="60" />
</a>

# xStocks

[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-blue)](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-blue)
[![Bootstrap](https://img.shields.io/github/package-json/dependency-version/a-kushnir/x-stocks/bootstrap)](https://img.shields.io/github/package-json/dependency-version/a-kushnir/x-stocks/bootstrap)
[![jQuery](https://img.shields.io/github/package-json/dependency-version/a-kushnir/x-stocks/jquery)](https://img.shields.io/github/package-json/dependency-version/a-kushnir/x-stocks/jquery)
[![Scrutinizer Code Quality](https://img.shields.io/scrutinizer/quality/g/a-kushnir/x-stocks/main)](https://img.shields.io/scrutinizer/quality/g/a-kushnir/x-stocks/main)
[![License](https://img.shields.io/github/license/a-kushnir/x-stocks)](https://img.shields.io/github/license/a-kushnir/x-stocks)

[xStocks](http://x-stocks.herokuapp.com/) is a Stock Data Aggregator website

# Table of contents

- [Screenshots](#screenshots)
    - [Home Page](#home-page)
    - [Stock Page](#stock-page)
    - [My Positions](#my-positions)
    - [My Dividends](#my-dividends)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)
- [Links](#links)

# Screenshots

[(Back to top)](#table-of-contents)

xStock is a website that allows to gather and analyze stock information from multiple sources and apply the data for your own portfolio.

## Home Page
News, vital market information with links to Sceeners and other important pages.

![home-page](https://user-images.githubusercontent.com/1454297/92982276-a58df780-f45a-11ea-897a-34c22b7cb71f.png)

## Stock Page
All gathered information about a single stock.

![stock-information](https://user-images.githubusercontent.com/1454297/92982322-e6860c00-f45a-11ea-9d20-d855d9140279.png)

## My Positions
All gathered information about user portfolio. Information can be presented in Table or Chart mode or exported to Excel format.

![positions-table](https://user-images.githubusercontent.com/1454297/92982317-dff79480-f45a-11ea-83a3-55d0abec70e3.png)
![positions-charts](https://user-images.githubusercontent.com/1454297/92982319-e259ee80-f45a-11ea-9744-69176ec46e09.png)

## My Dividends
All gathered information about user dividends. Information can be presented in Table or Chart mode or exported to Excel format.

![divident-table](https://user-images.githubusercontent.com/1454297/92982334-f30a6480-f45a-11ea-9ce7-9855bd6fd86a.png)
![divident-charts](https://user-images.githubusercontent.com/1454297/92982335-f4d42800-f45a-11ea-86ca-3b1a607eefe9.png)

# Requirements

[(Back to top)](#table-of-contents)

* Linux or macOS or Windows
* PostgreSQL, [download](https://www.postgresql.org/download/)
* Ruby 2.6 or later, [download](https://www.ruby-lang.org/en/downloads/)
* Yarn 1.22 or later, [download](https://classic.yarnpkg.com/en/docs/install/)
* Node 12 or later, [download](https://nodejs.org/en/download/)
* Git

# Installation

[(Back to top)](#table-of-contents)

Install PostgreSQL and create _x_stocks_ user and _x_stocks_development_ database or update _config\database.yml_ file to match existing configuration.

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

# Run mirgations
$ rails db:migrate

# Run the app
$ rails s
```

# License

[(Back to top)](#table-of-contents)

xStocks is under the MIT license. See the [LICENSE](https://github.com/a-kushnir/x-stocks/blob/main/LICENSE) for more information.

# Links

[(Back to top)](#table-of-contents)

* [Live version on Heroku](http://x-stocks.herokuapp.com/)
* [Source code](https://github.com/a-kushnir/x-stocks)
