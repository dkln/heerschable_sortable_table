module HeerschableSortableTable
  module ActionView
    def table_header(name, column, opts = {}, table_id = 'default')
      anchor = opts[:anchor].blank? ? '' : "##{opts[:anchor]}"

      if(opts[:update] or opts[:remote])
        opts[:url] = table_header_url(table_id, column) + anchor
        opts[:method] = :get
        opts[:title] = opts[:title]

        link = link_to_remote(name, opts)
      else
        link = link_to( name,
                        table_header_url(table_id, column) + anchor,
                        :title => opts[:title] )
      end

      content_tag(:th, link, :class => table_header_classes(table_id, column, opts))
    end

    def table_header_url(table_id, column)
      url_for(params.merge("#{table_id}_sort_column" => column, "#{table_id}_sort_order" => table_header_order(table_id, column), :page => 1))
    end

    def selected_table_header_params(table_ids = ['default'])
      params = {}

      table_ids.each do |id|
        params["#{id}_sort_column"] = controller.selected_column(id)
        params["#{id}_sort_order"] = controller.selected_order_direction(id)
      end

      params
    end

    def reverse_order(order)
      order == 'asc' ? 'desc' : 'asc'
    end

    def table_header_order(table_id, column)
      if(column.to_s == controller.selected_column(table_id).to_s)
        reverse_order(controller.selected_order_direction(table_id))
      else
        'asc'
      end
    end

    def table_header_class(table_id, column)
      if(column.to_s == controller.selected_column(table_id).to_s)
        if(controller.selected_order_direction == 'asc')
          'desc'
        else
          'asc'
        end
      end
    end

    def table_header_classes(table_id, column, opts)
      class_names = []
      class_names << table_header_class(table_id, column)
      class_names << opts[:class]
      class_names.compact.blank? ? nil : class_names.compact.join(' ')
    end
  end

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
          if( table_param(table_id, 'sort_order') and
              %w(asc desc).include?(table_param(table_id, 'sort_order')) )
            table_param(table_id, 'sort_order')
          else
            unless( self.class.column_defaults and
                    self.class.column_defaults[table_id].empty? and
                    self.class.column_defaults[table_id][selected_column(table_id)] )
              self.class.column_defaults[table_id][selected_column(table_id)]
            else
              'asc'
            end
          end
        end

        def selected_column(table_id = 'default')
          if( table_param(table_id, 'sort_column') and
              self.class.column_mapping[table_id][table_param(table_id, 'sort_column')] )
            table_param(table_id, 'sort_column')
          else
            unless( self.class.column_defaults and
                    not self.class.column_defaults[table_id] and
                    self.class.column_defaults[table_id].empty? )
              self.class.column_mapping[table_id][self.class.column_defaults[table_id].keys.first]
            else
              self.class.column_mapping[table_id].values.first
            end
          end
        end

        def sorting(table_id = 'default')
          "#{self.class.column_mapping[table_id][selected_column(table_id)]} #{selected_order_direction(table_id)}"
        end

        private
          def table_param(table_id, param)
            params["#{table_id}_#{param}"]
          end
      end
    end
  end
end
