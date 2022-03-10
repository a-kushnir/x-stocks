# frozen_string_literal: true

# Controller to provide access to background services
class ServicesController < ApplicationController
  layout 'application_old'

  include ActionController::Live

  def index
    @tag = params[:tag]
    @jobs = @tag.present? ? XStocks::Job.find_by_tag(@tag) : XStocks::Job.all

    if @tag.present? && @jobs.blank?
      @tag = nil
      @jobs = XStocks::Job.all
    end

    @stocks = XStocks::AR::Stock.all

    @columns = columns

    @page_title = 'Services'
    @page_menu_item = :services
  end

  def run_one
    find_job do |job|
      EventStream.run(response) do |stream|
        perform_job(job) { |status| stream.write(status) }
      end
    end
  end

  def submit_one
    find_job do |job|
      perform_job(job) { nil }

      flash[:notice] = 'Service run complete'
      redirect_to action: 'index'
    end
  end

  def log
    find_job do |job|
      service = job.service

      send_data(service&.log,
                filename: "#{params[:lookup_code]}-log.txt",
                type: 'text/plain')
    end
  end

  def error
    find_job do |job|
      service = job.service

      send_data(service&.error,
                filename: "#{params[:lookup_code]}-error.txt",
                type: 'text/plain')
    end
  end

  def file
    find_job do |job|
      service = job.service

      send_data(service&.file_content,
                filename: service&.file_name || "#{params[:lookup_code]}-file.txt",
                type: service&.file_type || 'text/plain')
    end
  end

  def run_all
    EventStream.run(response) do |stream|
      service = XStocks::Service.new
      break if service.locked?

      service.perform_update { |status| stream.write(status) }
    end
  end

  private

  def find_job
    job = XStocks::Job.find(params[:lookup_code])
    if job
      yield job
    else
      flash[:notice] = 'Invalid service'
      redirect_to action: 'index'
    end
  end

  def perform_job(job, &block)
    args = params.permit(job.arguments.keys).to_hash.symbolize_keys
    job.force_lock = true
    job.perform(**args, &block)
  end

  def columns
    columns = []

    columns << { label: 'Schedule', index: index = 1, default: true }
    columns << { label: 'Status', index: index += 1, default: true }
    columns << { label: 'Last Run', index: index += 1, default: true }
    columns << { label: 'Arguments', index: index += 1, default: true }
    columns << { label: 'Actions', index: index + 1, default: true }

    columns
  end
end
