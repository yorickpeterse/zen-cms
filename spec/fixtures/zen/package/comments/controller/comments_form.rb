class SpecCommentsForm < Zen::Controller::FrontendController
  map '/spec-comments-form'

  def index
    body = <<-HTML
<form action="#{Comments::Controller::CommentsForm.r(:save)}" 
method="post" id="spec_comments_form">
    <input name="csrf_token" value="#{get_csrf_token}" type="hidden" />

    <input id="section_entry" name="section_entry"  type="text" />
    <input id="user_id"       name="user_id"        type="text" />
    <input id="name"          name="name"           type="text" />
    <input id="website"       name="website"        type="text" />
    <input id="email"         name="email"          type="text" />

    <textarea id="comment" name="comment"></textarea>

    <input type="submit" value="Submit" />
</form>
HTML

    return body
  end
end
