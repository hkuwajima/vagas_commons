# frozen_string_literal: true

module VagasCommons::ValidateParams
  extend ActiveSupport::Concern

  attr_reader :valid_params

  def validate_params
    action = params['action'].to_sym
    block = self.class.defined_validations[action]

    validation = block ? block.call : Dry::Validation.Form(VagasCommons::BasicSchema)

    validated = validation.call(params.to_unsafe_h)

    unless validated.success?
      render_error(validated.messages(locale: I18n.locale), 412)
      return false
    end
    @valid_params = validated.output
  end

  class << self; attr_accessor :defined_validations; end

  module ClassMethods
    def defined_validations
      @defined_validations || {}
    end

    def define_validation(action, &block)
      (@defined_validations ||= {})[action] = block
    end
  end
end
