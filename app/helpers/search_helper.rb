module SearchHelper

  def display_categories(categories)
    ret = "<ul class='treemenu'>"
    ##add all the root categories + all sub categories in ul, li
    categories.each do |category|
      if category.parent_id.blank?
        ret += "<li>"
        ret += category.name
        #ret += link_to category.title, :action => "edit", :id => category
        ret += " | "
        #ret += link_to 'Destroy', admin_category_path(category), :confirm => 'Are you sure?', :method => :delete
        ret += find_all_subcategories(category) if category.children.size > 0
        ret += "</li>"
      end
    end
    ret += "</ul>"
  end

  def find_all_subcategories(category)
    ret = "<ul class='treemenu'>"
    category.children.each do |subcat|
      if subcat.children.size > 0
        ret += "<li>"
        ret += subcat.name
       # ret += link_to subcat.title, :action => "edit", :id => subcat
        ret += "|"
        #ret += link_to 'Destroy', admin_category_path(subcat), :method => :delete, :confirm => 'Are you sure?'
        ret += find_all_subcategories(subcat)
        ret += "</li>"
      else
        ret += '<li>'
        ret += h(subcat.name)
        #ret += link_to h(subcat.title), :action => 'edit', :id => subcat
        ret += " | "
        #ret += link_to 'Destroy', admin_category_path(subcat), :confirm => 'Are you sure?', :method => :delete
        ret += '</li>'
      end
    end
    ret += '</ul>'
  end

end
