module Sections
  module Liquid
    ##
    # The SectionEntries tag can be used to retrieve all section entries
    # for the given section. A basic example of this looks like the following:
    #
    # bc. {% section_entries section="blog" %}
    # Do something in here
    # {% endsection_entries %}
    #
    # When using this tag you can specify the following optionally arguments:
    #
    # * section: the slug of the section for which to retrieve all entries
    # * limit: the amount of entries to retrieve
    # * offset: the offset from which to start selecting entries
    # * section_entry: the slug of the section entry to select
    # * order: the sort order type
    # * order_by: the name of the column to sort on
    # * category: retrieves all entries that are using the specified category
    #
    # These arguments can be specified as following:
    #
    # bc. {% section_entries section="blog" limit="10" offset="20" %}
    # Do something in here
    # {% endsection_entries %}
    #
    # Inside this block you can output the values of your custom fields by
    # calling the variable tag containing the name of the custom field. For example,
    # if you have a field called "body" you can output it for each entry as following:
    #
    # bc. {% section_entries section="blog" limit="10" offset="20" %}
    # {{body}}
    # {% endsection_entries %}
    #
    # The following variables are available by default:
    #
    # * id: the ID of the section entry
    # * title: the entry title
    # * slug: the entry slug
    # * status: the status of the entry
    # * created_at
    # * updated_at
    # * section_id: the ID of the section to which this entry belongs
    #
    # @example
    #  {% section_entries section="blog" limit="10" offset="20" %}
    #  <article>
    #    <header>
    #      <h1>{{title}}</h1>
    #    </header>
    #
    #    {{body}}
    #  </article>
    #  {% endsection_entries %}
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class SectionEntries < ::Liquid::Block
      include ::Ramaze::Helper::CGI
      include ::Zen::Liquid::General
      
      ##
      # Creates a new instance of the block and passes the tag name,
      # all additional arguments and the HTML to the constructor method.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] tag_name The name of the tag that was called.
      # @param  [String] arguments All additional arguments passed as a string.
      # @param  [String] html The HTML inside the block.
      #
      def initialize(tag_name ='section_entries', arguments = '', html = '')
        super

        @arguments = {
          'limit'    => 10,
          'offset'   => 0,
          'section'  => '',
          'order'    => 'desc',
          'order_by' => 'id',
          'category' => ''
        }.merge(parse_key_values(arguments))
        
        @args_parsed = false
      end
      
      ##
      # Processes the arguments set in the constructor, retrieves all data and renders 
      # the tag block. When outputting data inside the tag block you can always use the 
      # following variables regardless on whether there are any section entries:
      #
      # * total_rows: the amount of rows retrieved
      # * index: the current index
      #
      # Depending on whether you have any entries or not you can use the following
      # values as well:
      #
      # * comments: array containing all comments for each entry
      # * categories: array of all categories for each entry
      # * user: data about the author of each entry
      #
      # On top of that you can of course also use your own custom values. Each value
      # can be accessed by it's slug.
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def render(context)
        @arguments = merge_context(@arguments, context) if @args_parsed == false
                
        @args_parsed = true
        result       = []
        entries      = []
        filter_hash  = {:status => 'published'}
        
        # ------
        # Filter by a section entry's slug
        if @arguments.key?('section_entry')
          if @arguments['section_entry'].empty?
            raise(ArgumentError, "You need to specify a section entry to retrieve")
          end
          
          filter_hash[:slug] = @arguments['section_entry']

        # ------
        # Filter by a category's slug
        elsif @arguments.key?('category') and !@arguments['category'].empty?
          category = ::Categories::Models::Category[:slug => @arguments['category']]

          # Bail out of the category doesn't exist
          return result if category.nil?
    
          # Retrieve the category group
          group = category.category_group

          # Now it's time to retrieve all section IDs
          filter_hash[:section_id] = group.sections.map { |s| s.id }
        
        # ------
        # Filter by a section's slug
        else
          if @arguments['section'].empty?
            @arguments['section'] = ::Settings::Model::Setting.get_settings[:default_section]
          end
          
          section = ::Sections::Models::Section[:slug => @arguments['section']]
          
          return result if section.nil?

          filter_hash[:section_id] = section.id
        end
        
        entries = ::Sections::Models::SectionEntry
          .eager(:custom_field_values, :categories, :comments, :section, :user)
          .filter(filter_hash)
          .order(@arguments['order_by'].to_sym.send(@arguments['order']))
          .limit(@arguments['limit'], @arguments['offset'])
        
        context['total_rows'] = entries.count
        
        entries.each_with_index do |entry, index|
          entry.values.each { |k, v| context[k.to_s] = v }
          
          context['index']      = index
          context['categories'] = []
          context['comments']   = []
          context['user']       = {}
          
          # Retrieve all categories
          entry.categories.each do |c|
            values = {}
            
            c.values.each { |k, v| values[k.to_s] = v }
            context['categories'].push(values)
          end
          
          # Get the user for the current entry
          if !entry.user.nil?
            entry.user.values.each { |k, v| context['user'][k.to_s] = v }
          end
          
          # Retrieve all comments
          entry.comments.each do |c|
            values = {}
            
            c.values.each { |k, v| values[k.to_s] = v }
            
            # Pull the Email, name and website fields from the user table in case the comment
            # was posted by somebody who was logged in to the backend.
            ['email', 'name', 'website'].each do |m|
              if values[m].nil? or values[m].empty?
                values[m] = c.user.send(m)
              end
            end
            
            values['comment'] = markup_to_html(values['comment'], entry.section.comment_format)
            context['comments'].push(values)
          end
          
          # Get all our custom fields
          entry.custom_field_values.each do |field_value|
            field = field_value.custom_field
            name  = field.slug
            value = markup_to_html(field_value.value, field.format.to_sym)
            
            context[name.to_s] = value
          end
          
          result.push(render_all(@nodelist, context))
        end
        
        result.push(render_all(@nodelist, context)) if result.empty?

        return result
      end
    end
  end
end
