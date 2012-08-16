# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  body = page.body
  puts body

end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  is_checked = uncheck.nil?
  ratings = rating_list.split(",")
  ratings.each do |r|
    if true & is_checked
      step %Q{I check "ratings_#{r}"}
    else
      step %Q{I uncheck "ratings_#{r}"}
    end
  end
end

When /^I press: (.*)$/ do |pressed_button|
  step %Q{I press "#{pressed_button}"}
end

Then /^I should see movies with ratings: (.*)$/ do |rating_list|
  ratings = page.all("table#movies tbody#movielist tr td[2]").map { |r| r.text }
  rating_list.split(",").each do |r|
    assert ratings.include?(r.strip)
  end
end

Then /^I should not see movies with rating: (.*)$/ do |rating_list|
  ratings = page.all("table#movies tbody#movielist tr td[2]").map { |r| r.text}
  rating_list.split(",").each do |r|
    assert !ratings.include?(r.strip)
  end
end

Given /^I selected no ratings$/ do
  all_ratings = Movie.find(:all, :select => 'distinct rating').map(&:rating)
  all_ratings.each do |r|
    step %Q{I uncheck "ratings_#{r}"}
  end
end

Then /^I should see none of the movies$/ do
  titles = page.all("table#movies tbody#movielist tr td[1]").map { |r| r.text }
  assert titles.size == 0
end

Given /^I selected all ratings$/ do
  all_ratings = Movie.find(:all, :select => 'distinct rating').map(&:rating)
  all_ratings.each do |r|
    step %Q{I check "ratings_#{r}"}
  end
end

Then /^I should see all of the movies$/ do
  titles = page.all("table#movies tbody#movielist tr td[1]").map { |r| r.text }
  assert titles.size == Movie.all.count
end

Then /^I should see movies sorted by title$/ do
  displayed_titles = page.all("table#movies tbody#movielist tr td[1]").map { |r| r.text }
  cnt = 0
  displayed_titles.each do |title|
    if title != displayed_titles.last
      assert title < displayed_titles[cnt+1]
      cnt += 1
    end
  end
end

Then /^I should see movies sorted by release date$/ do
  displayed_dates = page.all("table#movies tbody#movielist tr td[3]").map { |r| r.text }
  cnt = 0
  displayed_dates.each do |title|
    if title != displayed_dates.last
      assert title < displayed_dates[cnt+1]
      cnt += 1
    end
  end
end
