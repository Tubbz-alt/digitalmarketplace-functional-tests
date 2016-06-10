require 'uri'

Given /^I am on the homepage$/ do
  page.visit("#{dm_frontend_domain}")
  page.should have_content("Digital Marketplace")
end

Given /^I am on the (\/.*) page$/ do |url|
  page.visit("#{dm_frontend_domain}#{url}")
  page.should have_content("Digital Marketplace")
end

Given /^I have a random g-cloud service from the API$/ do
  params = {status: "published", framework: "g-cloud-6,g-cloud7"}
  page_one = call_api(:get, "/services", params: params)
  last_page_url = JSON.parse(page_one.body)['links']['last']
  params[:page] = 1 + rand(CGI.parse(URI.parse(last_page_url).query)['page'][0].to_i)
  random_page = call_api(:get, "/services", params: params)
  services = JSON.parse(random_page.body)['services']
  @service = services[rand(services.length)]
  puts "Service ID: #{@service['id']}"
  puts "Service name: #{@service['serviceName']}"
end

When /I click '(.*)'$/ do |button_link_name|
  page.click_link_or_button(button_link_name)
end

When /^I enter that service\.(.*) in the '(.*)' field$/ do |attr_name, field_name|
  step "I enter '\"#{@service.fetch(attr_name)}\"' in the '#{field_name}' field"
end

When /^I enter '(.*)' in the '(.*)' field$/ do |value,field_name|
  page.fill_in(field_name, with: value)
end

Then /^I see the '(.*)' breadcrumb$/ do |breadcrumb_text|
  breadcrumb = page.all(:xpath, "//div[@id='global-breadcrumb']/nav//li").last
  breadcrumb.text().should match(breadcrumb_text)
end

Then /^I see the '(.*)' link$/ do |link_text|
  page.should have_link(link_text)
end

Then /^I am on the '(.*)' page$/ do |page_name|
  find('h1').should have_content(/#{page_name}/i)
end

Then /I see '(.*)' as the value of the '(.*)' field$/ do |value, field|
  if page.has_field?(field, {type: 'radio'}) or page.has_field?(field, {type: 'checkbox'})
    page.find_field(field, {checked: true}).value.should == value
  else
    page.find_field(field).value.should == value
  end
end