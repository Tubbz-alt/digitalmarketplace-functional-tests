@search-for-buyers
Feature: Find a buyer

Scenario Outline: Correct users can search for buyers by brief id
  Given I am logged in as the production <role> user
  And I click the 'Find a buyer by opportunity ID' link
  When I enter '5870' in the 'Find a buyer by opportunity ID' field
  And I click the 'Search' button
  Then I am on the 'Find a buyer' page
  And I see the 'User' summary table filled with:
    | Buyer Name 513ecc35174839416337590f218428e3 | 513ecc35174839416337590f218428e3@example.gov.uk |

  Examples:
    | role                    |
    | admin                   |
    | admin-ccs-category      |

Scenario Outline: Correct users cannot search for buyers by brief id
  Given I am logged in as the production <role> user
  Then I don't see the 'Find a buyer by opportunity ID' link
  When I am on the /admin/buyers page
  Then I am on the 'You don’t have permission to perform this action' page

  Examples:
    | role                    |
    | admin-framework-manager |
    | admin-ccs-sourcing      |
    | admin-manager           |