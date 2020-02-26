class Place < ApplicationRecord
  include PlaceHelper

  STATES = [
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Maine',
    'Maryland',
    'Massachusetts',
    'New Hampshire',
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

  def capital
    CAPITALS[self.state.to_sym].gsub(' ','-')
  end

  def state_code
    STATE_ABBREVIATIONS[self.state.to_sym]
  end
end
