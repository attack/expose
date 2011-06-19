RSpec::Matchers.define :expose do |attr|
  match do |subject|
    # expect {
    #   current_value = subject.send(attr.to_sym)
    #   subject.attributes = {attr.to_sym => (current_value && !current_value.blank? ? (current_value + '_new') : 'new')}
    # }.to change{ subject.send(attr.to_sym) }
    old_value = subject.send(attr.to_sym).to_s
    subject.update_attributes({attr.to_sym => (old_value && !old_value.blank? ? (old_value + '_new') : 'new')})
    subject.reload
    old_value != subject.send(attr.to_sym)
  end

  failure_message_for_should do |subject|
    "expected that #{subject} does not protect #{attr}, but it does"
  end

  failure_message_for_should_not do |subject|
    "expected that #{subject} attr_protects #{attr}, but it does not"
  end

  description do
    "NOT attr_protected :#{attr}"
  end
end

RSpec::Matchers.define :protect do |attr|
  match do |subject|
    old_value = subject.send(attr.to_sym)
    subject.attributes = {attr.to_sym => (old_value && !old_value.blank? ? (old_value + '_new') : 'new')}
    new_value = subject.send(attr.to_sym)
    
    old_value == new_value
  end
  
  failure_message_for_should do |subject|
    "expected that #{subject} attr_protects #{attr}, but it does not"
  end

  failure_message_for_should_not do |subject|
    "expected that #{subject} does not protect #{attr}, but it does"
  end
  
  description do
    "attr_protected :#{attr}"
  end
end