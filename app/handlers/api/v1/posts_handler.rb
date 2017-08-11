class Api::V1::PostsHandler < ApiHandler
  def with_comments(data)
    data&.as_json(include: :comments)
  end

  include Api::BasicCrud(
    model: -> (x) { Post.includes(:comments)},
    output_filters: [:with_comments]
  )
end
