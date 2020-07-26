class DividendsController < ApplicationController
  helper :stocks

  def index
    @positions = Position
      .where(user: current_user)
      .where.not(shares: nil)
      .all

    @page_title = 'My Dividends'
    @page_menu_item = :dividends

    respond_to do |format|
      format.html { }
      format.xlsx { generate_xlsx }
    end
  end

  private

  def generate_xlsx
    send_tmp_file('Dividends.xlsx') do |file_name|
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
          sheet.add_row ["Simple Pie Chart"]
          %w(first second third).each { |label| sheet.add_row [label, rand(24)+1] }
          sheet.add_chart(Axlsx::Pie3DChart, :start_at => [0,5], :end_at => [10, 20], :title => "example 3: Pie Chart") do |chart|
            chart.add_series :data => sheet["B2:B4"], :labels => sheet["A2:A4"],  :colors => ['FF0000', '00FF00', '0000FF']
          end
        end
        p.serialize(file_name)
      end
    end
  end

end
