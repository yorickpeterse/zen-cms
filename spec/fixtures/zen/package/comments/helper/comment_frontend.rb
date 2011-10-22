class SpecCommentFrontend < Zen::Controller::FrontendController
  map '/spec-comment-frontend'

  def index
    comments = get_comments('spec', :limit => 1, :paginate => true)
    html     = ''

    comments.each do |comment|
      html += "<p>#{comment.comment}</p>"
    end

    html += comments.navigation

    return html
  end
end
