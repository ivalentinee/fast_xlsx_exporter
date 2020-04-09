# Fast XLSX Exporter
[![Build Status](https://travis-ci.org/ivalentinee/fast_xlsx_exporter.svg?branch=master)](https://travis-ci.org/ivalentinee/fast_xlsx_exporter)
[![Coverage Status](https://coveralls.io/repos/github/ivalentinee/fast_xlsx_exporter/badge.svg?branch=master)](https://coveralls.io/github/ivalentinee/fast_xlsx_exporter?branch=master)
[![Hex pm](https://img.shields.io/hexpm/v/fast_xlsx_exporter.svg?style=flat)](https://hex.pm/packages/fast_xlsx_exporter)

## Installation

Add `fast_xlsx_exporter` to your mix.ex deps:

```elixir
def deps do
  [
    {:fast_xlsx_exporter, "~> 0.1.2"}
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
FastXlsxExporter.finalize(context)
```

See? Really simple thing, nothing special.

If you're looking for something that really supports xlsx, go with [elixlsx](https://github.com/xou/elixlsx).
