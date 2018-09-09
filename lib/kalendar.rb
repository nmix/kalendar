require 'date'
require 'ostruct'

class Kalendar

  PERIODS = %w[
    calendar_days
    work_days
    weeks
    months
    quarters
    years
  ]

  @@store = OpenStruct.new

  attr_reader :base_date

  def initialize(base_date = Date.today)
    @base_date = base_date
  end

  # Next working day after current
  # @return [Date]
  def next_work_day
    target_day = @base_date + 1
    while Kalendar.holiday?(target_day)
      target_day += 1
    end
    target_day
  end

  # End date of term with specified period
  # @param num [Integer] period duration
  # @param type [Symbol/String] period type :work_days, :calendar_days,
  #   :weeks, :months, :quarters, :years
  # @return [Date]
  def end_of_term(num, type)
    raise ArgumentError, 'num cannot be negative or 0' if num <= 0
    unless PERIODS.include?(type.to_s)
      raise ArgumentError, "unknown period #{type}" 
    end
    send("after_#{type}", num)
  end

  alias eot end_of_term

  class << self

    # Specify fixed working days hash
    # @param days [Hash] year-days hash
    #   ex: {
    #     2018 => '01.01-10.01 23.02 8.3'
    #     2019 => '01.01-08.01 08.03 01.05-04.05'
    #   }
    # @return [Hash] year-days hash
    def set_work_days(days)
      work_days_array = parse_days(days)
      if (work_days_array & holidays).any?
        raise ArgumentError, 'Overlay of date (s) of working days and holidays'
      end
      Kalendar.store = store.merge(:work_days => days)
    end

    # @return [Array] array of Date
    def work_days
      parse_days(store.fetch(:work_days, []))
    end


    # Specify fixed holidays hash
    # @param days [Hash] year-days hash
    #   ex: {
    #     2018 => '01.01-10.01 23.02 8.3'
    #     2019 => '01.01-08.01 08.03 01.05-04.05'
    #   }
    # @return [Hash] year-days hash
    def set_holidays(days)
      holidays_array = parse_days(days)
      if (holidays_array & work_days).any?
        raise ArgumentError, 'Overlay of date (s) of working days and holidays'
      end
      Kalendar.store = store.merge(:holidays => days)
    end

    # @return [Array] array of Date
    def holidays
      parse_days(store.fetch(:holidays, []))
    end

    # Is holiday
    # @param day [Date] specific date
    # @return [bool]
    def holiday?(day) 
      case
      when holidays.include?(day) then true
      when day.wday % 6 != 0 then false
      when work_days.include?(day) then false
      else true
      end
    end

    # Parse year-days hash
    # @param [Hash] year-days has
    #   ex: {
    #     2018 => '01.01-10.01 23.02 8.3'
    #     2019 => '01.01-08.01 08.03 01.05-04.05'
    #   }
    # @return [Array] array of Date instances
    def parse_days(year_days_hash)
      year_days_hash.map do |year, days|
        days = days.delete(" \t\r\n")
        next if days.empty?
        days.split(',').map do |day|
          if day.include?('-')
            range_days = day.split('-')
            raise ArgumentError if range_days.count != 2
            date1 = parse_day(year, range_days[0])
            date2 = parse_day(year, range_days[1])
            (date1..date2).to_a
          else
            parse_day(year, day)
          end
        end
      end.flatten.sort
    end

    # Set fixed kalendar year-day hash to the store
    # @param [Hash] year-days hash
    def store=(year_days_hash)
      @@store.kalendar = year_days_hash
    end

    # Fetching fixed kalendar year-days hash from store
    # @return [Hash]
    def store
      @@store.kalendar || {}
    end

    # Reset fixed working days and holidays
    # @return [Hash] Empty hash
    def reset!
      Kalendar.store = {}
    end

    # Initialize hash-like store
    # @param [Object/Class] hash-like class or instance
    # @return [true/false]
    def init_storage(new_storage)
      # will raise exception if method doesnt exist
      # todo: fix
      new_storage.kalendar 
      @@store = new_storage
      true
    rescue StandardError => msg
      p msg
      false
    end

    private

    # Parse year value and string 'DD.MM' to Date
    # @param year [Integer]
    # @param day [String] day with format 'DD.MM'
    # @return [Date]
    def parse_day(year, day)
      Date.strptime("#{year}.#{day}", "%Y.%d.%m")
    end
  end

  private

  # End of term with calendar days
  # @param num [Integer] count of calendar days
  # @return [Date]
  def after_calendar_days(num)
    @base_date + num
  end

  alias after_calendar_day after_calendar_days

	# End of term with work days
  # @params num [Integer] count of work days
  # @return Date
  def after_work_days(num)
    # --- accumulate working days including weekends and holidays
    work_day_counter = 0
    target_date = @base_date + 1
    while work_day_counter < (num-1) do
      unless Kalendar.holiday?(target_date)
        work_day_counter += 1
      end
      target_date += 1
    end
    # --- if the resulting date was on a weekend, looking for the first
    #     working day after it
    while Kalendar.holiday?(target_date)
      target_date += 1
    end
    target_date
  end

  # End of term with weeks
  # @params num [Integer] count of weeks
  # @return Date
  def after_weeks(num)
    @base_date + num * 7
  end

  # End of term with months
  # @params num [Integer] count of months
  # @return Date
  def after_months(num)
    @base_date >> num
  end

  # End of term with quarters
  # @params num [Integer] count of quarters
  # @return Date
  def after_quarters(num)
    @base_date >> (num * 3)
  end

  # End of term with years
  # @params num [Integer] count of years
  # @return Date
  def after_years(num)
    @base_date.next_year(num)
  end
end
