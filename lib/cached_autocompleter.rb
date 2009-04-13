class CachedAutocompleter
  
  def initialize(choices, options = {})
    @choices = choices
    @options = options.reverse_merge(:minChars => 2)
  end

  def to_field(tag_name, tag_value, tag_options)
    @tag_name, @tag_value, @tag_options = tag_name, tag_value, tag_options
    
    buf = String.new
    buf << text_field_tag(@tag_name, @tag_value, @tag_options.update(:id => tag_id))
    buf << choices_div
    buf << javascript_block
    buf    
  end
  
protected

  def choices_div
    %Q| <div class="auto_complete" id="auto_complete_for_#{tag_id}"></div> |
  end
  
  def javascript_block
    helpers.javascript_tag(<<-JS)
      var choices_for_#{tag_id} = #{choices_to_json};
      new Autocompleter.Local('#{tag_id}', 'auto_complete_for_#{tag_id}', choices_for_#{tag_id}, {#{options_to_json}});
    JS
  end
  
  def options_to_json
    @options.map do |key, val|
      "#{key}: #{val.to_json}"
    end.join(', ')
  end
  
  def choices_to_json
    @choices.map(&:tidy_utf_bytes).to_json
  end
  
  def tag_id
    if @tag_name =~ /(\w+)\[(\w+)\]/
      tag_id = "#{$1}_#{$2}"
    else
      tag_id = @tag_name
    end
    @tag_options[:id] || tag_id
  end
  
private

  def text_field_tag(*anything)
    helpers.text_field_tag(*anything)
  end
  
  def helpers
    ActionController::Base.helpers
  end

end