module PostsHelper
  def markdown(text)
    markdown_help(text)
  end

  def markdown_no_html(text)
    markdown_help(text, :filter_html)
  end

  def markdown_help(text, *new_options)
    #TODO refactor using zipmap, take *new_options
    options = {:hard_wrap         => true,
               :autolink          => true,
               :filter_html       => true,
               :no_intraemphasis  => true,
               :fenced_code       => true,
               :gh_blockcode      => true}
    
    renderer = Redcarpet::Render::HTML.new
    redcarpet = Redcarpet::Markdown.new(renderer, options)
    raw(redcarpet.render(text))
  end
end
