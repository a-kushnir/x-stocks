# frozen_string_literal: true

module XStocks
  class Stock
    # Stock Issue Type Business Model
    module IssueType
      ISSUE_TYPES = {
        'ad' => 'ADR (American Depositary Receipt)',
        're' => 'REIT (Real Estate Investment Trust)',
        'ce' => 'CEF (Closed-End Fund)',
        'si' => 'Secondary Issue',
        'lp' => 'Limited Partnerships',
        'cs' => 'Common Stock',
        'et' => 'ETF (Exchange Traded Fund)',
        'wt' => 'Warrant',
        'oef' => 'OEF (Open-End Fund)',
        'cef' => 'CEF (Closed-End Fund)',
        'ps' => 'Preferred Stock',
        'ut' => 'Unit',
        'temp' => 'Temporary'
      }.freeze

      def common_stock?
        %w[cs].include?(ar_stock.issue_type)
      end

      def adr?
        %w[ad].include?(ar_stock.issue_type)
      end

      def etf?
        %w[et].include?(ar_stock.issue_type)
      end

      def issue_type_name
        ISSUE_TYPES.fetch(ar_stock.issue_type, 'Unknown')
      end

      def logo_url
        return ar_stock.logo if ar_stock.logo.present?
        return '/img/adr-logo.png' if adr?
        return '/img/etf-logo.png' if etf?
        return '/img/cs-logo.png' if common_stock?

        nil
      end
    end
  end
end
