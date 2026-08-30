---
title: TableTypeMaster
layout: project
dataKey: TableTypeMaster
---

| name | file_ext | mimetype | magic_number | list_tables | list_columns | list_column_types |
|---|---|---|---|---|---|---|
| csv | .csv | text/csv | na | na | yes | no |
| xlsx | .xlsx | application/vnd.openxmlformats-officedocument.spreadsheetml.sheet | 50 4B 03 04 | yes | yes | yes |
| sqlite | .sqlite | application/vnd.sqlite3 | 53 51 4C 69 74 65 20 66 6F 72 6D 61 74 20 33 00 | yes | yes | yes |
| html | .html | text/html | 3C 21 44 4F 43 54 59 50 45 | yes | yes | no |
| json | .json | application/json | na | na | yes | yes |
| postgres | na | na | na | yes | yes | yes |
| mongodb | na | na | na | yes | yes | yes |
| tsv | .tsv | text/tab-separated-values | na | na | yes | no |
| xml | .xml | application/xml | 3C 3F 78 6D 6C | yes | yes | no |
| parquet | .parquet | application/vnd.apache.parquet | 50 41 52 31 | na | yes | yes |
| avro | .avro | avro/binary | 4F 62 6A 01 | na | yes | yes |
| orc | .orc | application/orc | 4F 52 43 | na | yes | yes |
| ods | .ods | application/vnd.oasis.opendocument.spreadsheet | 50 4B 03 04 | yes | yes | yes |
| yaml | .yaml | application/yaml | na | na | yes | yes |
| toml | .toml | application/toml | na | yes | yes | yes |
| mysql | na | na | na | yes | yes | yes |
| mariadb | na | na | na | yes | yes | yes |
| sqlserver | na | na | na | yes | yes | yes |
| access | .accdb | application/x-msaccess | 00 01 00 00 | yes | yes | yes |
| hdf5 | .h5 | application/x-hdf | 89 48 44 46 0D 0A 1A 0A | yes | yes | yes |
| bigquery | na | na | na | yes | yes | yes |
