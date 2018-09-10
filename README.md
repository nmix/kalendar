# Kalendar

Простая библиотека для подсчета рабочих дней в календаре

## Установка



```bash
gem install specific_install
gem specific_install -l nmix/kalendar
```

или Gemfile

```ruby
gem 'kalendar', :github => 'nmix/kalendar'
```

## Использование

```ruby
require 'kalendar'

# фиксируем праздничные дни
Kalendar.set_holidays(
  2018 => '01.01-08.01, 23.02, 08.03, 09.03, 30.04-02.05, 09.05, 11.06, 12.06, 15.06, 21.08, 30.08, 05.11, 06.11, 31.12',
  2019 => '01.01-08.01'
)

# фиксируем рабочие дни
Kalendar.set_work_days(
  2018 => '28.04, 09.06, 29.12'
)

# следующий рабочий день
Kalendar.new(Date.new(2018, 1, 1)).end_of_term(1, :work_days).to_s
=> "2018-01-09"

# псевдоним для команды выше
Kalendar.new(Date.new(2018, 9, 1))
=> "2018-09-04"

# следующий календарный день
Kalendar.new(Date.new(2018, 1, 1)).end_of_term(1, :calendar_days).to_s
=> "2018-01-02"

# через неделю
Kalendar.new(Date.new(2018, 1, 1)).end_of_term(1, :weeks).to_s
=> "2018-01-08"

# через месяц
Kalendar.new(Date.new(2018, 1, 1)).end_of_term(1, :months).to_s
=> "2018-02-01"

# через квартал
Kalendar.new(Date.new(2018, 1, 1)).end_of_term(1, :quarters).to_s
=> "2018-04-01"

# через год
Kalendar.new(Date.new(2018, 1, 1)).end_of_term(1, :years).to_s
=> "2019-01-01"
```

## Интеграция с классом Date

```ruby
require 'kalendar'

class Date
  # Определение крайнего срока при завершении заданного интервала
  # @param num [Integer] period duration
  # @param type [Symbol/String] period type :work_days, :calendar_days,
  #   :weeks, :months, :quarters, :years
  # @return [Date]
  def end_term(num, type)
    Kalendar.new(self).end_of_term(num, type)
  end
end

```

Использование

```ruby
# work days
Date.new(2018, 1, 1).end_term(1, :work_days).to_s
=> "2018-01-09"
# deprecated
Date.new(2018, 1, 1).after_working_days(1).to_s
=> "2018-01-09"
# calendar days
Date.new(2018, 1, 1).end_term(1, :calendar_days).to_s
=> "2018-01-02"
```

## Хранилище

По умолчанию для хранения данных используется класс [OpenStruct](http://ruby-doc.org/stdlib-2.5.1/libdoc/ostruct/rdoc/OpenStruct.html).

Для использования Kalendar с постоянным хранилищем данных, необходимо передать ему Hash-like класс или экземпляр класса с возможность произвольного доступа по полям, например для Rails можно использовать [Rails Settings Cached](https://github.com/huacnlee/rails-settings-cached)

```ruby
# /config/initializers/kalendar.rb
Kalendar.init_storage(Setting)
```

## Тестирование

```bash
rspec spec
```
