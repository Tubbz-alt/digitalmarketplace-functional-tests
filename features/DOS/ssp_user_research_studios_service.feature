@not-production @functional-test @ssp @wip1
Feature: Submitting a new DOS service for User research studios
  In order to submit my services as a supplier user
  I want to answer questions about my service

  Background: Log in as a supplier
    Given I am on the 'Supplier' login page
    When I login as a 'Supplier' user
    Then I should be on the supplier home page

  Scenario: Select User research studios as a service to add
    Given I am at '/suppliers'
    When I click 'Continue your Digital Outcomes and Specialists application'
    Then I am taken to the 'Apply to Digital Outcomes and Specialists' page

    When I click 'Add, edit and delete services'
    Then I am taken to the 'Your Digital Outcomes and Specialists services' page

    When I click 'User research studios'
    Then I am taken to the 'User research studios services' page

  Scenario: Provide a service name
    Given I am at '/suppliers/frameworks/digital-outcomes-and-specialists/submissions/user-research-studios'
    When I click 'Add a service'
    Then I am taken to the 'Lab name' page

    When I fill in 'serviceName' with 'My user research studio'
    And I click 'Save and continue'
    Then I should be on the 'My user research studio' page

  Scenario: Edit service name
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Lab name' page
    When I fill in 'serviceName' with 'My user research studio service'
    And I click 'Save and continue'
    Then I should be on the 'Address' page

  Scenario: Provide Address
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Address' page
    And I fill in 'labAddressBuilding' with 'No 1 Test Street'
    And I fill in 'labAddressTown' with 'Test Town'
    And I fill in 'labAddressPostcode' with 'TE57ME'
    And I click 'Save and continue'
    Then I should be on the 'Location' page

  Scenario: Provide Location
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Location' page
    And I fill in 'labPublicTransport' with 'Take bus 786 towards the radio tower and get off at the Testlington Street'
    And I fill in 'labCarPark' with 'Customer parking available underground'
    And I click 'Save and continue'
    Then I should be on the 'Lab size' page

  Scenario: A draft service has been created
    Given I am at '/suppliers/frameworks/digital-outcomes-and-specialists/submissions'
    Then There is 'a' draft 'User research studios' service

    When I am at '/suppliers/frameworks/digital-outcomes-and-specialists/submissions/user-research-studios'
    Then There is 'a' draft 'My user research studio service' service

  Scenario: Provide Lab size
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Lab size' page
    And I fill in 'labSize' with 'Thirty 2'
    And I click 'Save and continue'
    Then I should be on the 'Viewing' page

  Scenario: Provide Viewing info
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Viewing' page
    And I choose 'Yes – included as standard' for 'labViewingArea'
    And I choose 'Yes – for an additional cost' for 'labStreaming'
    And I choose 'No' for 'labDesktopStreaming'
    And I choose 'Yes – for an additional cost' for 'labDeviceStreaming'
    And I choose 'No' for 'labEyeTracking'
    And I choose 'No' for 'labWiFi'
    And I choose 'Yes – included as standard' for 'labDesktopStreaming'
    And I click 'Save and continue'
    Then I should be on the 'Technical assistance' page

  Scenario: Provide Technical assistance info
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Technical assistance' page
    And I choose 'Yes – included as standard' for 'labTechAssistance'
    And I click 'Save and continue'
    Then I should be on the 'Hospitality' page

  Scenario: Provide Hospitality info
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Hospitality' page
    And I choose 'Yes – for an additional cost' for 'labHosting'
    And I choose 'Yes – included as standard' for 'labWaitingArea'
    And I click 'Save and continue'
    Then I should be on the 'Facilities' page

  Scenario: Provide Facilities info
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Facilities' page
    And I choose 'Yes' for 'labToilets'
    And I choose 'No' for 'labBabyChanging'
    And I click 'Save and continue'
    Then I should be on the 'Accessibility' page

  Scenario: Provide Accessibility info
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Accessibility' page
    And I fill in 'labAccessibility' with 'Wheelchair accessible, lifts and toilets accomodate wheelchairs'
    And I click 'Save and continue'
    Then I should be on the 'Price' page

  Scenario: Provide Pricing info
    Given I am on ssp page 'user-research-studios'
    When I navigate to the 'Edit' 'Price' page
    And I fill in 'input-labPrice-MinPrice' with '100'
    And I fill in 'input-labPrice-MaxPrice' with '1000'
    And I select 'Unit' from 'input-labPrice-Unit'
    And I select '6 months' from 'input-labPrice-Interval'
    And I click 'Save and continue'
    Then I should be on the 'My user research studio' page

  Scenario: Verify text on summary page
    Given I am on the summary page
    Then Summary row 'What is the name of the lab?' should contain 'My user research studio service'
    And Summary row 'Building and street' should contain 'No 1 Test Street'
    And Summary row 'Town or city' should contain 'Test Town'
    And Summary row 'Postcode' should contain 'TE57ME'
    And Summary row 'How do visitors get to your studio using public transport?' should contain 'Take bus 786 towards the radio tower and get off at the Testlington Street'
    And Summary row 'Where can visitors to your studio park?' should contain 'Customer parking available underground'
    And Summary row 'How many people can the lab accommodate?' should contain 'Thirty 2'
    And Summary row 'Do you have an viewing area?' should contain 'Yes – included as standard'
    And Summary row 'Do you provide remote streaming from the lab?' should contain 'Yes – for an additional cost'
    And Summary row 'Do you stream a view of the desktop or laptop screen?' should contain 'Yes – included as standard'
    And Summary row 'Do you stream a view of a mobile or tablet device?' should contain 'Yes – for an additional cost'
    And Summary row 'Do you provide eye-tracking?' should contain 'No'
    And Summary row 'Do you provide Wi-Fi?' should contain 'No'
    And Summary row 'Do you provide help with studio equipment and streaming?' should contain 'TE57ME'
    And Summary row 'Do you welcome and host participants?' should contain 'Yes – for an additional cost'
    And Summary row 'Do you provide a waiting area?' should contain 'Yes – included as standard'
    And Summary row 'Do you provide toilets?' should contain 'Yes'
    And Summary row 'Do you provide baby-changing facilities?' should contain 'No'
    And Summary row 'How accessible is your studio?' should contain 'Wheelchair accessible, lifts and toilets accomodate wheelchairs'
    And Summary row 'What is the minimum amount of time your studio can be booked for and how much does it cost?' should contain 'TE57ME'

  @delete_service
  Scenario: Delete the service
    Given I am on the summary page
    When I click 'Delete this service'
    And I click 'Yes, delete “My user research studio service”'
    Then I am taken to the 'User research studios services' page
    And There is 'no' draft 'My user research studio service' service

    When I am at '/suppliers/frameworks/digital-outcomes-and-specialists/submissions'
    And There is 'no' draft 'User research studios' service
