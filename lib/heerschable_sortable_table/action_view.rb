module HeerschableSortableTable
  module ActionView
    def table_header(name, column, opts = {}, table_id = 'default')
      anchor = opts[:anchor].blank? ? '' : "##{opts[:anchor]}"

      if(opts[:update] or opts[:remote])
        opts[:url] = table_header_url(table_id, column) + anchor
        opts[:method] = :get
        opts[:title] = opts[:title]

        link = link_to_remote(name, opts, :href => opts[:url])
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
end
