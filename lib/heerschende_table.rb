module HeerschendeTable
  module ActionController
    module Base
      module ClassMethods
        def sortable_columns(*args)
          @column_mapping = {} unless(@column_mapping)
          @column_mapping.merge!(fetch_mapping(args))
        end

        def default_sorted_column(*args)
          @column_defaults = {} unless(@column_defaults)
          @column_defaults.merge!(fetch_mapping(args))
        end

        def column_mapping
          @column_mapping
        end

        def column_defaults
          @column_defaults
        end

        private
          def fetch_mapping(args)
            columns = extract_hash(args)

            # is there a table id?
            if(columns['id'])
              table_id = columns['id']
              columns.delete('id')
            else
              table_id = 'default'
            end

            { table_id => columns }
          end

          def extract_hash(args)
            hash = {}

            if(args.last.is_a?(Hash))
              args.last.each { |i| hash[i[0].to_s] = i[1].to_s }
              args.pop
            end

            args.each { |i| hash[i.to_s] = i.to_s } unless(args.empty?)

            hash
          end
      end

      module InstanceMethods
        def selected_order_direction(table_id = 'default')
          if(table_param(table_id, 'sort_order') %w(ascending descending).include?(table_param(table_id, 'sort_order')))
            table_param(table_id, 'sort_order')
          else
            unless(self.class.column_defaults[table_id].empty? and self.class.column_defaults[table_id][selected_column(table_id)])
              self.class.column_defaults[table_id][selected_column(table_id)]
            else
              'ascending'
            end
          end
        end

        def sort_method(table_id = 'default')
        end

        def selected_column(table_id = 'default')
          if(table_param(table_id, 'sort_column') and self.class.column_mapping[table_id][table_param(table_id, 'sort_column')])
            table_param(table_id, 'sort_column')
          else
            unless(self.class.column_defaults[table_id].empty? and self.class.column_defaults[table_id].empty?)
              self.class.column_mapping[table_id][self.class.column_defaults[table_id].keys.first]
            else
              self.class.column_mapping[table_id].values.first
            end
          end
        end

        private
          def table_param(table_id, param)
            params["#{table_id}_#{param}"]
          end
      end
    end
  end
end
