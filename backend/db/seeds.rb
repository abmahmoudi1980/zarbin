# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be used by the app. You can also use a more sophisticated approach,
# such as using a seeding library or even writing raw SQL, depending on your needs.
#
# Examples:
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie_id: movies.first.id)

# Seed predefined transaction categories
# These are the 7 base categories for all transactions

categories_data = [
  { persian_name: 'خوراک', icon_code: 'grocery', display_order: 1 },
  { persian_name: 'حمل‌ونقل', icon_code: 'transport', display_order: 2 },
  { persian_name: 'قبوض', icon_code: 'bills', display_order: 3 },
  { persian_name: 'خرید', icon_code: 'shopping', display_order: 4 },
  { persian_name: 'سلامت', icon_code: 'health', display_order: 5 },
  { persian_name: 'تفریح', icon_code: 'entertainment', display_order: 6 },
  { persian_name: 'سایر', icon_code: 'other', display_order: 7 }
]

categories_data.each do |category_data|
  Category.find_or_create_by(icon_code: category_data[:icon_code]) do |category|
    category.persian_name = category_data[:persian_name]
    category.display_order = category_data[:display_order]
  end
end

puts "✅ Seeded #{categories_data.length} transaction categories"

# Seed initial market rates
# These will be updated automatically by FetchMarketRatesJob (runs every 5 minutes during market hours)

recent_rate = MarketRate.recent.first

if recent_rate.nil?
  timestamp = Time.current
  
  initial_rates = [
    { rate_type: 'usd', value_in_toman: 42_000 },
    { rate_type: 'gold_gram', value_in_toman: 2_500_000 },
    { rate_type: 'bahar_coin', value_in_toman: 45_000_000 }
  ]

  initial_rates.each do |rate_data|
    MarketRate.create!(
      rate_type: rate_data[:rate_type],
      value_in_toman: rate_data[:value_in_toman],
      timestamp: timestamp
    )
  end

  puts "✅ Seeded #{initial_rates.length} initial market rates"
else
  puts "ℹ️  Market rates already seeded, skipping"
end
