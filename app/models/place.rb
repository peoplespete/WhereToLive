class Place < ApplicationRecord
  STATES = [
    'Connecticutt',
    'Delaware',
    'Florida',
    'Georgia',
    'Maine',
    'Maryland',
    'Massachusetts',
    'New Hampsire',
    'New Jersey',
    'New York',
    'North Carolina',
    'Rhode Island',
    'South Carolina',
    'Tennessee',
    'Vermont',
    'Virginia',
    'West Virginia',
  ]

  default_scope { where(state: STATES) }
end
