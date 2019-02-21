module Admin::TagsHelper
  def create_deletable_button tag 
    if tag.in_use?
      link_to '#' do
        # this is cuz we can't use html in the ruby file
        content_tag(:button, 'Delete', class: 'disabled')
      end
    else
      link_to admin_tag_path(tag), method: :delete, data: { confirm: 'Are you sure?' } do
        content_tag(:button, 'Delete')
      end
    end
  end  
end
