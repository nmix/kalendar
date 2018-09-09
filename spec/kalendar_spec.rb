require 'kalendar'

RSpec.describe Kalendar do

  # Creates Date instance
  # @return [Date]
  def d(s)
    Date.strptime(s, "%d.%m.%Y")
  end

  # Creates array of Date instances
  # @return [Array] array of dates
  def dd(s)
    s.split(' ').map{ |day| d(day) }
  end

  # base_date 03.09.2018 (mn)
  let(:kalendar) { Kalendar.new(d('03.09.2018')) }

  let(:days) do
    {
      2018 => '01.01-05.01, 23.02',
      2019 => '01.01-02.01, 8.3',
    }
  end

  let(:days_array) { dd(
    '01.01.2018 02.01.2018 03.01.2018 04.01.2018 05.01.2018 23.02.2018 '\
    '01.01.2019 02.01.2019 08.03.2019'
  ) }

  before(:each) do
    Kalendar.reset!
  end

  describe '#next_work_day' do
    it { expect(kalendar.next_work_day).to eq(d('04.09.2018')) }
    
    it 'applies weekend' do
      kalendar = Kalendar.new(d('01.09.2018')) # sat
      expect(kalendar.next_work_day).to eq(d('03.09.2018'))
    end

    it 'applies fixed holidays' do
      kalendar = Kalendar.new(d('01.09.2018')) # sat
      Kalendar.set_holidays(2018 => '03.09') # mon
      expect(kalendar.next_work_day).to eq(d('04.09.2018'))
    end

    it 'applies fixed work days' do
      kalendar = Kalendar.new(d('01.09.2018')) # sat
      Kalendar.set_work_days(2018 => '02.09') # sun
      expect(kalendar.next_work_day).to eq(d('02.09.2018'))
    end
  end

  describe '#end_of_term' do
    context 'with calendar days' do
      # eot is alias of end_of_term
      it { expect(kalendar.eot(1, :calendar_days)).to eq(d('04.09.2018')) }

      it { expect(kalendar.eot(10, :calendar_days)).to eq(d('13.9.2018')) }

      it 'does not use specified holidays' do
        Kalendar.set_holidays(2018 => '03.09-05.09')
        expect(kalendar.eot(3, :calendar_days)).to eq(d('06.09.2018'))
      end
    end

    context 'with working days' do
      it { expect(kalendar.eot(1, :work_days)).to eq(d('04.09.2018')) }

      it { expect(kalendar.eot(4, :work_days)).to eq(d('07.09.2018')) }

      it 'applies weekends' do
        expect(kalendar.eot(5, :work_days)).to eq(d('10.09.2018'))
      end

      it 'applies fixed work days' do
        Kalendar.set_work_days(2018 => '08.09')
        expect(kalendar.eot(5, :work_days)).to eq(d('08.09.2018'))
      end

      it 'applies fixed holidays' do
        Kalendar.set_holidays(2018 => '10.09')
        expect(kalendar.eot(5, :work_days)).to eq(d('11.09.2018'))
      end

      it 'applies start holiday' do
        kalendar = Kalendar.new(d('01.09.2018')) # sat
        expect(kalendar.eot(1, :work_days)).to eq(d('03.09.2018'))
      end
    end

    context 'with weeks' do
      it { expect(kalendar.eot(1, :weeks)).to eq(d('10.09.2018')) }

      it { expect(kalendar.eot(3, :weeks)).to eq(d('24.09.2018')) }
    end

    context 'with months' do
      it { expect(kalendar.eot(1, :months)).to eq(d('03.10.2018')) }

      it { expect(kalendar.eot(2, :months)).to eq(d('03.11.2018')) }

      it 'applies last days of last month' do
        kalendar = Kalendar.new(d('31.08.2018')) # sat
        expect(kalendar.eot(1, :months)).to eq(d('30.09.2018'))
        expect(kalendar.eot(2, :months)).to eq(d('31.10.2018'))
      end
    end

    context 'with quarters' do
      it { expect(kalendar.eot(1, :quarters)).to eq(d('03.12.2018')) }

      it { expect(kalendar.eot(2, :quarters)).to eq(d('03.03.2019')) }
    end

    context 'with years' do
      it { expect(kalendar.eot(1, :years)).to eq(d('03.09.2019')) }

      it { expect(kalendar.eot(3, :years)).to eq(d('03.09.2021')) }
    end
  end

  describe '.set_work_days' do
    it 'saves hash to store' do
      Kalendar.set_work_days(days)
      expect(Kalendar.store[:work_days]).to eq(days)
    end

    it 'raise error if dates cross' do
      Kalendar.store = {holidays: days}
      expect{ Kalendar.set_work_days(days) }.to raise_error(ArgumentError)
    end
  end

  describe '.work_days' do
    it 'restore hash from store' do
      Kalendar.store = {work_days: days}
      expect(Kalendar.work_days).to eq(days_array)
    end
  end

  describe '.set_holidays' do
    it 'saves hash to store' do
      Kalendar.set_holidays(days)
      expect(Kalendar.store[:holidays]).to eq(days)
    end

    it 'raise error if dates cross' do
      Kalendar.store = {work_days: days}
      expect{ Kalendar.set_holidays(days) }.to raise_error(ArgumentError)
    end
  end

  describe '.holidays' do
    it 'restore hash from store' do
      Kalendar.store = {holidays: days}
      expect(Kalendar.holidays).to eq(days_array)
    end
  end

  describe '.holiday?' do
    # 03.09.2018 - mon
    it { expect(Kalendar.holiday?(d('03.09.2018'))).to be(false) }

    # 02.09.2018 - sun
    it { expect(Kalendar.holiday?(d('02.09.2018'))).to be(true) }

    it 'applies fixed holiday' do
      # 04.09.2018 - tue
      Kalendar.set_holidays(2018 => '04.09')
      expect(Kalendar.holiday?(d('04.09.2018'))).to be(true)
    end

    it 'applies fixes work days' do
      # 01.09.2018 - sat
      Kalendar.set_work_days(2018 => '01.09')
      expect(Kalendar.holiday?(d('01.09.2018'))).to be(false)
    end
  end

  describe '.parse_days' do
    it { expect(Kalendar.parse_days({})).to eq([]) }

    it { expect{ Kalendar.parse_days(2018 => '123') }.to raise_error(ArgumentError) }

    it { expect(Kalendar.parse_days(2018 => '10.01')).to eq(dd('10.01.2018')) }

    it 'parse multiple dates' do
      expect(
        Kalendar.parse_days(2018 => '01.01, 23.02, 8.3')
      ).to eq(dd('01.01.2018 23.02.2018 08.03.2018'))
    end

    it 'parse multiple dates with intervals' do
      expect(
        Kalendar.parse_days(2018 => '01.01-03.01, 05.01')
      ).to eq(dd('01.01.2018 02.01.2018 03.01.2018 05.01.2018'))
    end
  end

  describe '.init_storage' do
    it { expect(Kalendar.init_storage(OpenStruct.new)).to be(true) }
  end
end
