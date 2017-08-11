module PaginationHelpers
  def with_pagination(obj=nil, total_count=nil, &block)
    obj ||= block.()
    if params[:skip_pagination]
      { data: obj }
    else
      total, data = obj.is_a?(Array) ? paginate_array(obj) : paginate_query(obj)
      { total_count: (total_count || total), data: data }
    end
  end

  def paginate_array(arr)
    [ arr.length, arr[page_offset...(page_offset+page_size)] ]
  end

  def paginate_query(query)
    [ query.count, query.offset(page_offset).limit(page_size) ]
  end

  def page_size
    @page_size ||= params[:page_size].to_i <= 0 ? 20 : [params[:page_size].to_i, 500].min
  end

  def page_offset
    @offset ||= ([params[:page].to_i, 1].max - 1) * page_size
  end
end
