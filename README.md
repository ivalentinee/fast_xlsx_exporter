# Fast XLSX Exporter
[![Build Status](https://travis-ci.org/ivalentinee/fast_xlsx_exporter.svg?branch=master)](https://travis-ci.org/ivalentinee/fast_xlsx_exporter)
[![Coverage Status](https://coveralls.io/repos/github/ivalentinee/fast_xlsx_exporter/badge.svg?branch=master)](https://coveralls.io/github/ivalentinee/fast_xlsx_exporter?branch=master)
[![Hex pm](https://img.shields.io/hexpm/v/fast_xlsx_exporter.svg)](https://hex.pm/packages/fast_xlsx_exporter)

## Installation

Add `fast_xlsx_exporter` to your mix.ex deps:

```elixir
def deps do
  [
    {:fast_xlsx_exporter, "~> 0.1.3"}
  ]
end
```

## Explanation
[Elixlsx](https://github.com/xou/elixlsx) was fine, until really huge exports appeared. Then it took more and more time to generate xlsx reports. And RAM.

So, being really primitive (8 hour at night from scratch knowing nothing about xlsx) this library does not store document in memory. It writes straight to file system.

Some example:
```elixir
head = ["column1", "column2", "column3"]
rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
count = Enum.count(rows)

context = FastXlsxExporter.initialize(count, head)
context = Enum.reduce(rows, context, &FastXlsxExporter.put_row/2)
{:ok, {_filename, document}} = FastXlsxExporter.finalize(context)
File.write("/home/george/failures.xlsx", document)
```

See? Really simple thing, nothing special.

If you're looking for something that really supports xlsx, go with [elixlsx](https://github.com/xou/elixlsx).

## Supported cell values

### Numbers
Both `float` and `integer` values are supported and special form of `{<float>, :percents}` to write number as xlsx percent.

Example row:
```elixir
[1, 12.5, {0.59, :percents}]
```

### Strings
Strings could be written in two ways.

First one is straight (no special form). In this case strings are written sequentially to **shared strings**, which is RAM-friendly but bloats resulting xlsx file.

Second one requires special form of `{<string>, :dictionary}`. In this case strings are put into dictionary and are written into **shared strings** only once, but are stored in memory, which is good for limited set of values but can cause `OOMKilled` if strings are *random*.

Example rows:
```elixir
# first row
["Vladimir Putin", "Donald Trump", "Literally Hitler"]
# second row
[{"some_string", :dictionary}, {"some_other_string", :dictionary}, {"some_string", :dictionary}]
# third row
["wow!", {"some_other_string", :dictionary}, "yay!"]
```

### Date and time
Both `%Date{}` and `%NaiveDateTime{}` are rendered as dates (not strings).

Example row:
```elixir
[~D[1905-12-11], ~D[2020-04-09], ~N[2020-04-09 12:00:00]]
```
