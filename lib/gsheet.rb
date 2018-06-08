require 'active_support/all'
require 'facets'
require 'google_drive'

class Gsheet
  include Enumerable

  attr_accessor :key
  attr_reader :spreadsheet_key
  attr_reader :worksheet_title
  attr_reader :drive_session

  def initialize(spreadsheet_key, key_column_name='Id', worksheet_title='Sheet1')
    @spreadsheet_key = spreadsheet_key
    @worksheet_title = worksheet_title
    @key = key_column_name.snakecase.to_sym

    @drive_session = GoogleDrive::Session.from_config('config.json')
    @ws = @drive_session.spreadsheet_by_key(@spreadsheet_key).worksheet_by_title(@worksheet_title)
    @header_height = 1

    @autosave_interval = 30.seconds
    @last_save = Time.now

    reload_instance!
  end

  def reload!
    @ws.reload
    @last_save = Time.now
    reload_instance!
  end

  def reload_instance!
    @columns = (@ws.rows.first || [])
        .map.with_index { |column_name, i| [column_name.snakecase.to_sym, i] }
        .reject { |a| a.first.blank? }
        .to_h
    @key_column_index = @columns[@key] || 0
    @row_keys = rows.transpose[@key_column_index] || []

    # Add key column if missing
    @ws[1, @key_column_index + 1] = @key.to_s.humanize if @ws.rows.blank?
  end

  def [](key)
    row_index = key.is_a?(Integer) ? key : @row_keys.index(key)
    row = rows[row_index]
    @columns.transform_values { |v| row[v] }
  end

  def []=(key, h)
    # Does row exist?
    row_index = if key.is_a? Integer
      key
    else
      add_row(key) unless @row_keys.include?(key)
      @row_keys.index key
    end

    h.each do |column_key, value|
      # Does column exist?
      add_column(column_key) unless @columns.key?(column_key)
      column_index = @columns[column_key]

      set_value(row_index, column_index, value)
    end
  end

  def each(&block)
    @row_keys.each do |row_key|
      block.call(row_key, self[row_key])
    end
  end

  def save
    @ws.save
    @last_save = Time.now
  end

  def add_row(key)
    set_value(rows.size, @key_column_index, key)
    reload_instance!
  end

  def add_column(key)
    set_value(0 - @header_height, @ws.rows.first.size, key.to_s.humanize)
    reload_instance!
  end

  def set_value(row, column, value)
    # Check if needs update (prevents 'NULL' cells)
    ws_row = row + @header_height
    outside_rows = (ws_row >= @ws.rows.size) || (column >= @ws.rows.first.size)
    return if !outside_rows && rows[row, column] == value

    @ws[ws_row + 1, column + 1] = value.presence || 'NULL'

    autosave
  end

  def worksheet
    @ws
  end

  def rows
    @ws.rows(@header_height)
  end

  private

  def autosave
    save if (@last_save + @autosave_interval).past?
  end

end
