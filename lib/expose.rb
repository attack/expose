require "expose/version"

module Expose
  
  module Model
  
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        
        class_attribute :_exposures
        self._exposures = Hash.new { |h,k| h[k] = [] }
      end
    end

    module ClassMethods
      # USAGE
      # expose :attribute_name, :if => Proc.new {|model condition}
      # expose :attribute_name, :state => :new, :state => [:new,:locked]
      # - this will add :param_name to the 'attr_accessible' params if the condition is true
      #
      def expose(*config)
        options = config.extract_options!
        options.symbolize_keys!
        options.assert_valid_keys(:if, :unless, :state, :not_state)
            
        # TODO - warnings of improper use
        # :name (attribute)
        # validate in attr_protected or not in attr_accessible, otherwise no need to expose
        #
        # :state + :not_state
        # include warning if any similarities in :state and :not_state, as they would cancel each other out
        
        config.each do |name|
          if self.attribute_method?(name.to_sym)
            # if _exposures.has_key?(name.to_sym)
            #   # log duplication ?
            # end
            _exposures[name.to_sym] = options
          else
            raise "Expose: invalid attribute - #{name.to_s}"
          end
        end
      end
    
    end
     
    protected
    
    def mass_assignment_authorizer(attributes)
      attribute_list = super
      if attribute_list.is_a?(ActiveModel::MassAssignmentSecurity::WhiteList)
        attribute_list += attributes_to_expose
      else
        attribute_list -= attributes_to_expose
      end
      attribute_list
    end
    
    def attributes_to_expose
      attributes_to_expose = []
      
      # if there are exposures
      if _exposures && _exposures.respond_to?(:each)
        # go through each exposure
        _exposures.each do |k,v|
          
          # assume exposure of the attribute
          expose_attr = true
          
          # RESPOND to configuration
          #
          
          # run through both :if and :unless ... then expose attribute if applicable
          if v.key?(:if) || v.key?(:unless)
            expose_attr = (applicable?(v[:if], true) && applicable?(v[:unless], false))
          end
          
          # try to match state
          if v.key?(:state)
            # convert to Array
            allowed_states = v[:state].is_a?(Array) ? v[:state] : [v[:state].to_s]
            
            # expose attribute if the current state is in expected states
            expose_attr = ( self.respond_to?(:state) &&
                            self.state &&
                            allowed_states.include?(self.state.to_s))
          end
          
          # try to NOT match state
          if v.key?(:not_state)
            # convert to Array
            disallowed_states = v[:not_state].is_a?(Array) ? v[:not_state] : [v[:not_state].to_s]
            
            # expose attribute if the current state is NOT in expected states
            expose_attr = ( self.respond_to?(:state) &&
                            ( !self.state ||
                              !disallowed_states.include?(self.state.to_s)))
          end
      
          # if nothing is preventing this attribute from being exposed (eg. all pass, or no options)
          # then add the attribute to attr_accessible
          attributes_to_expose << k.to_s if expose_attr
        end
      end
      
      attributes_to_expose
    end

    # Evaluates the scope options :if or :unless. Returns true if the proc
    # method, or string evals to the expected value.
    def applicable?(string_proc_or_symbol, expected) #:nodoc:
      case string_proc_or_symbol
        when String
          eval(string_proc_or_symbol) == expected
        when Proc
          string_proc_or_symbol.call(self) == expected
        when Symbol
          send(string_proc_or_symbol) == expected
        else
          true
      end
    end
    
  end
  
end
ActiveRecord::Base.class_eval { include Expose::Model }