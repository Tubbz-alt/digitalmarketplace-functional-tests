require 'uri'
require 'securerandom'

Given /^I am on the homepage$/ do
  page.visit("#{dm_frontend_domain}")
  page.should have_content("Digital Marketplace")
end

Given /^I am on the (.* )?(\/.*) page$/ do |app, url|
  # If the app is set, then send the request using rest-client instead of capybara
  # and store the result in @response. Otherwise, poltergeist/phantomjs try to wrap
  # the response JSON in HTML.
  if app
    domain = domain_for_app(app.strip)
    @response = call_api(:get, url, domain: domain)
  else
    page.visit("#{dm_frontend_domain}#{url}")
    page.should have_content("Digital Marketplace")
  end
end

Given /^I have a random g-cloud service from the API$/ do
  frameworks = call_api(:get, "/frameworks")
  live_g_cloud_slugs = JSON.parse(frameworks.body)["frameworks"].select {|framework|
    framework["framework"] == "g-cloud" && framework["status"] == "live"
  }.map {|framework| framework["slug"]}
  # reverse sort by whatever is after the final "-" in the framework slug
  latest_g_cloud_slug = live_g_cloud_slugs.sort_by {|slug| slug.split('-')[-1] }.reverse[0]
  puts "Latest live g-cloud framework slug: #{latest_g_cloud_slug}"

  params = {status: "published", framework: latest_g_cloud_slug}
  page_one = call_api(:get, "/services", params: params)
  page_one.code.should == 200
  last_page_url = JSON.parse(page_one.body)['links']['last']
  params[:page] = if last_page_url then
                    1 + rand(CGI.parse(URI.parse(last_page_url).query)['page'][0].to_i)
                  else
                    1
                  end
  random_page = call_api(:get, "/services", params: params)
  random_page.code.should == 200
  services = JSON.parse(random_page.body)['services']
  @service = services[rand(services.length)]
  puts "Service ID: #{@service['id']}"
  puts "Service name: #{ERB::Util.h @service['serviceName']}"
end

Given /^I have a random g-cloud lot from the API$/ do
  frameworks = call_api(:get, "/frameworks")
  live_g_cloud_frameworks = JSON.parse(frameworks.body)["frameworks"].select {|framework|
    framework["framework"] == "g-cloud" && framework["status"] == "live"
  }
  # reverse sort by whatever is after the final "-" in the framework slug
  g_cloud_lot = live_g_cloud_frameworks.sort_by {|framework| framework["slug"].split('-')[-1] }.reverse[0]["lots"].sample
  puts "G-Cloud lot: #{g_cloud_lot['name']}"
  @lot = g_cloud_lot
end

# TODO merge with above step
Given /^I have a random (?:([a-z-]+) )?supplier from the API$/ do |metaframework_slug|
  params = {}
  if metaframework_slug
    params['framework'] = metaframework_slug
  end
  page_one = call_api(:get, "/suppliers", params: params)
  last_page_url = JSON.parse(page_one.body)['links']['last']
  params[:page] = if last_page_url then
                    1 + rand(CGI.parse(URI.parse(last_page_url).query)['page'][0].to_i)
                  else
                    1
                  end
  random_page = call_api(:get, "/suppliers", params: params)
  # Remove suppliers without a DUNS number - these are old imported accounts
  # and it's easier to skip them than to handle the empty DUNS search case
  suppliers = JSON.parse(random_page.body)['suppliers'].select { |supplier|
    supplier['dunsNumber']
  }
  @supplier = suppliers[rand(suppliers.length)]
  puts "Supplier ID: #{@supplier['id']}"
  puts "Supplier name: #{ERB::Util.h @supplier['name']}"
end

# TODO merge with above step
Given /^I have a random dos brief from the API$/ do
  params = {status: "live,closed", framework: "digital-outcomes-and-specialists"}
  page_one = call_api(:get, "/briefs", params: params)
  last_page_url = JSON.parse(page_one.body)['links']['last']
  params[:page] = if last_page_url then
                    1 + rand(CGI.parse(URI.parse(last_page_url).query)['page'][0].to_i)
                  else
                    1
                  end
  random_page = call_api(:get, "/briefs?with_users=true", params: params)
  briefs = JSON.parse(random_page.body)['briefs']
  @brief = briefs[rand(briefs.length)]

  # furnish the brief with the cosmetic status label used by the frontend
  @brief['statusLabel'] = {
    "live" => "Open",
    "closed" => "Closed",
  }[@brief['status']]

  puts "Brief ID: #{@brief['id']}"
  puts "Brief name: #{ERB::Util.h @brief['title']}"
end

When /I click #{MAYBE_VAR} ?(button|link)?$/ do |button_link_name, elem_type|
  if elem_type == 'button'
    page.click_button(button_link_name)
  elsif elem_type == 'link'
    page.click_link(button_link_name)
  else
    page.click_link_or_button(button_link_name)
  end
end

When /I check #{MAYBE_VAR} checkbox$/ do |checkbox_label|
  check_checkbox(checkbox_label)
end

When /I choose #{MAYBE_VAR} radio button(?: for the '(.*)' question)?$/ do |radio_label, question|
  if question
    within(:xpath, "//span[normalize-space(text())='#{question}']/../..") do
      choose_radio(radio_label)
    end
  else
    choose_radio(radio_label)
  end
end

When /I check a random '(.*)' checkbox$/ do |checkbox_name|
  checkbox = all_fields(checkbox_name, {type: 'checkbox'}).sample
  check_checkbox(checkbox)
end

When /I choose a random '(.*)' radio button$/ do |name|

  radio = all_fields(name, {type: 'radio'}).sample
  choose_radio(radio)
end

When /I check all '(.*)' checkboxes$/ do |checkbox_name|
  all_fields(checkbox_name, {type: 'checkbox'}).each do |checkbox|
    check_checkbox(checkbox)
  end
end

When /^I enter a random value in the '(.*)' field( and click its associated '(.*)' button)?$/ do |field_name, maybe_click_statement, click_button_name|
  @fields||= {}
  @fields[field_name] = SecureRandom.hex
  puts "#{field_name}: #{@fields[field_name]}"
  step "I enter '#{@fields[field_name]}' in the '#{field_name}' field#{maybe_click_statement}"
end

When /^I enter #{MAYBE_VAR} in the '(.*)' field( and click its associated '(.*)' button)?$/ do |value, field_name, maybe_click_statement, click_button_name|
  field_element = page.find_field field_name
  field_element.set value
  if maybe_click_statement
    form_element = field_element.find(:xpath, "ancestor::form")
    form_element.click_button(click_button_name)
  end
end

When(/^I choose a random uppercase letter$/) do
  @letter = ('A'..'Z').to_a.sample
  puts "letter: #{@letter}"
end

Then /^I see a (success|warning|destructive) banner message containing '(.*)'$/ do |status, message|
  page.find(:css, ".banner-#{status}-without-action").should have_content(message)
end

Then /^I see #{MAYBE_VAR} breadcrumb$/ do |breadcrumb_text|
  breadcrumb = page.all(:xpath, "//div[@id='global-breadcrumb']/nav//li").last
  breadcrumb.text().should == breadcrumb_text
end

Then /^I (don't |)see the '(.*)' link$/ do |negative, link_text|
  page.should have_link(link_text) if negative.empty?

  page.should_not have_link(link_text) unless negative.empty?
end

Then /^I am on #{MAYBE_VAR} page$/ do |page_name|
  page.should have_selector('h1', text: normalize_whitespace(page_name))
end

Then /^I see #{MAYBE_VAR} in the page's h1$/ do |page_name_fragment|
  find('h1').text.should include(normalize_whitespace(page_name_fragment))
end

Then(/^I see the page's h1 ends in #{MAYBE_VAR}$/) do |term|
  find('h1').text.should end_with term
end

Then /I see #{MAYBE_VAR} as the value of the '(.*)' field$/ do |value, field|
  if page.has_field?(field, {type: 'radio', visible: :all}) or page.has_field?(field, {type: 'checkbox', visible: :all})
    first_field(field, {checked: true}).value.should == value
  else
    first_field(field).value.should == value
  end
end

Then /^I do not see the '(.*)' field$/ do |field_name|
  page.should_not have_field(field_name)
end

Then /I see #{MAYBE_VAR} as the value of the '(.*)' JSON field$/ do |value, field|
  json = JSON.parse(@response)
  json.should include(field)
  json[field].should eq(value)
end

Then /Display the value of the '(.*)' JSON field as '(.*)'$/ do |field, name|
  json = JSON.parse(@response)
  json.should include(field)
  puts "#{name}: #{json[field]}"
end

Then(/^I see #{MAYBE_VAR} as the page header context$/) do |value|
  first(:xpath, "//header//*[@class='context']").text.should  == normalize_whitespace(value)
end

Then /^I see the '(.*)' summary table filled with:$/ do |table_heading, table|
  result_table_location = "//*[@class='summary-item-heading'][normalize-space(text())='#{table_heading}']/following-sibling::table[1]"
  result_table_rows_location = result_table_location + "/tbody/tr[@class='summary-item-row']"

  result_table_rows = all(:xpath, result_table_rows_location)

  table.rows.each_with_index do |row, index|
    result_items = result_table_rows[index].all('td')
    result_items[0].text.should == row[0]
    result_items[1].text.should == row[1]
  end
end

Then /^I see the '(.*)' radio button is checked(?: for the '(.*)' question)?$/ do |radio_button_name, question|
  if question
    within(:xpath, "//span[normalize-space(text())='#{question}']/../..") do
      first_field(radio_button_name, {type: 'radio'}).should be_checked
    end
  else
    first_field(radio_button_name, {type: 'radio'}).should be_checked
  end
end

Then /^I see '(.*)' text on the page/ do |expected_text|
  all(:xpath, "//*[normalize-space() = '#{expected_text}']").length.should >= 1
end

Then /^I see a '(.*)' attribute with the value '(.*)'/ do |attribute_name, attribute_value|
  place = "//*[@#{attribute_name} = '#{attribute_value}']"
  all(:xpath, place).length.should == 1
end

Then /^I take a screenshot/ do
  page.save_screenshot('screenshot.png')
end