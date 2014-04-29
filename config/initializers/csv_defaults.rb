require 'csv'
CSV_DEFAULTS = CSV::DEFAULT_OPTIONS.dup

CSV_DEFAULTS[:force_quotes] = true
CSV_DEFAULTS[:col_sep] = ';'
