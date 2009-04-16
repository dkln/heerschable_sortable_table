ActionController::Base.send(:include, HeerschendeTable::ActionController::Base::InstanceMethods)
ActionController::Base.send(:extend, HeerschendeTable::ActionController::Base::ClassMethods)
