local settings = {
  flib_dictionary_levels_per_batch = {
    name = "flib-dictionary-levels-per-batch",
    default_value = 15,
    minimum_value = 1,
    maximum_value = 15,
  },
  flib_translations_per_tick = {
    name = "flib-translations-per-tick",
    default_value = 50,
    minimum_value = 1,
  },
}

return settings