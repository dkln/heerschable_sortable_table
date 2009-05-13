ActionController::Base.send(:include, HeerschableSortableTable::ActionController::Base::InstanceMethods)
ActionController::Base.send(:extend, HeerschableSortableTable::ActionController::Base::ClassMethods)
ActionView::Base.send(:include, HeerschableSortableTable::ActionView)
