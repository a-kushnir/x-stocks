# frozen_string_literal: true

Dir['x_stocks/jobs/*.rb'].sort.each { |file| require file }

module XStocks
  # Lists available jobs
  class Job
    def self.all
      XStocks::Jobs
        .constants
        .map { |const| XStocks::Jobs.const_get(const) }
        .select { |klass| klass < XStocks::Jobs::Base }
        .map(&:new)
    end

    def self.find(lookup_code)
      all.detect { |job| job.lookup_code == lookup_code }
    end

    def self.find_by_tag(tag)
      all.select { |job| job.tags.include?(tag) }
    end
  end
end
