require 'yaml'
require 'redcarpet'
yaml = YAML.load(File.read("in.yaml"))
md = yaml.delete "html"
puts yaml
puts "\n\n"
puts Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(no_intra_emphasis: true, tables: true, autolink: true, strikethrough: true, with_toc_data: true)).render(md)

str = "--- Hey --- # --- Hello ---"
pattern = /---.*?---/
str.sub(pattern) {|match| "yay " + match.split(" ")[1] + " no" }

