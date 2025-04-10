# frozen_string_literal: true
#
class Task < ApplicationRecord
  validates :title, presence: true

  default_scope { order(:sequence) }

  before_validation :set_default_sequence

  def self.next_sequence
    pluck(:sequence).compact.max.to_i + 1
  end

  def set_default_sequence
    self.sequence = self.class.next_sequence unless sequence
  end
end