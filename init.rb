ActionController::Base.send(:include, HeerschableTable::ActionController::Base::InstanceMethods)
ActionController::Base.send(:extend, HeerschableTable::ActionController::Base::ClassMethods)
